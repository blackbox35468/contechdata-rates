-- Estimate Search Tools Migration
-- Functions for Claude tool-based estimate generation
-- Optimized for AI tool calls: minimal output, fast search, batch operations

-- =============================================================================
-- FUNCTION 1: search_productivity_for_estimate
-- =============================================================================
-- Simplified search for Claude tool calls - returns only essential fields
-- Combines FTS + trigram for best matching, prioritizes unit match

CREATE OR REPLACE FUNCTION search_productivity_for_estimate(
    p_trade_category TEXT DEFAULT NULL,
    p_activity_text TEXT DEFAULT NULL,
    p_output_unit TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    label TEXT,              -- "Bricklaying/face-brick"
    hours_per_unit NUMERIC,
    output_unit TEXT,
    confidence_score NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        lpc.id,
        (lpc.trade_category || '/' || lpc.activity_type)::TEXT AS label,
        lpc.hours_per_unit,
        lpc.output_unit,
        CASE
            -- Boost confidence if unit matches exactly
            WHEN p_output_unit IS NOT NULL AND lpc.output_unit = p_output_unit THEN
                lpc.confidence_score * 1.1
            ELSE lpc.confidence_score
        END AS confidence_score
    FROM labour_productivity_constants lpc
    WHERE lpc.is_active = true
        -- Organization filter: global items or user's org
        AND (
            lpc.organization_id IS NULL
            OR lpc.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        -- Trade category filter (optional, fuzzy)
        AND (p_trade_category IS NULL OR lpc.trade_category ILIKE '%' || p_trade_category || '%')
        -- Must match either FTS or trigram if activity_text provided
        AND (
            p_activity_text IS NULL
            OR lpc.search_vector @@ websearch_to_tsquery('english', p_activity_text)
            OR (lpc.activity_pattern IS NOT NULL AND similarity(lpc.activity_pattern, p_activity_text) > 0.25)
            OR similarity(lpc.description, p_activity_text) > 0.25
        )
    ORDER BY
        -- Prioritize unit matches
        CASE WHEN p_output_unit IS NOT NULL AND lpc.output_unit = p_output_unit THEN 0 ELSE 1 END,
        -- Then by search relevance
        CASE
            WHEN p_activity_text IS NOT NULL AND lpc.search_vector @@ websearch_to_tsquery('english', p_activity_text) THEN
                ts_rank(lpc.search_vector, websearch_to_tsquery('english', p_activity_text))
            ELSE 0
        END DESC,
        -- Then by confidence
        lpc.confidence_score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION search_productivity_for_estimate IS 'Simplified productivity search for Claude tool calls - returns only essential fields with unit-prioritized ranking';


-- =============================================================================
-- FUNCTION 2: calculate_labour_hours_batch
-- =============================================================================
-- Batch calculation for multiple items - calls existing calculate_adjusted_labour_hours

CREATE OR REPLACE FUNCTION calculate_labour_hours_batch(
    p_items JSONB  -- [{"productivity_id": "uuid", "quantity": 100, "conditions": {...}}]
)
RETURNS TABLE(
    item_index INTEGER,
    productivity_id UUID,
    base_hours NUMERIC,
    setup_hours NUMERIC,
    packup_hours NUMERIC,
    total_hours NUMERIC,
    condition_factor NUMERIC,
    gang_efficiency NUMERIC,
    scale_factor NUMERIC,
    minimum_applied BOOLEAN,
    calculation_notes TEXT
) AS $$
DECLARE
    v_item JSONB;
    v_idx INTEGER := 0;
    v_prod_id UUID;
    v_quantity NUMERIC;
    v_conditions JSONB;
BEGIN
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        v_prod_id := (v_item->>'productivity_id')::UUID;
        v_quantity := COALESCE((v_item->>'quantity')::NUMERIC, 1);
        v_conditions := COALESCE(v_item->'conditions', '{}'::JSONB);

        -- Skip if no productivity_id
        IF v_prod_id IS NULL THEN
            v_idx := v_idx + 1;
            CONTINUE;
        END IF;

        -- Call existing calculation function and return results
        RETURN QUERY
        SELECT
            v_idx AS item_index,
            v_prod_id AS productivity_id,
            calc.base_hours,
            calc.setup_hours,
            calc.packup_hours,
            calc.total_hours,
            calc.condition_factor,
            calc.gang_efficiency,
            calc.scale_factor,
            calc.minimum_applied,
            calc.calculation_notes
        FROM calculate_adjusted_labour_hours(
            v_prod_id,
            v_quantity,
            NULL,  -- Use optimal gang size from constant
            v_conditions
        ) calc;

        v_idx := v_idx + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION calculate_labour_hours_batch IS 'Batch labour hours calculation - processes multiple items in single call for efficiency';


-- =============================================================================
-- FUNCTION 3: search_composites_for_estimate
-- =============================================================================
-- Enhanced composite search for estimate generation - includes component summary

CREATE OR REPLACE FUNCTION search_composites_for_estimate(
    p_query TEXT,
    p_unit TEXT DEFAULT NULL,
    p_category TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    code TEXT,
    description TEXT,
    category TEXT,
    unit TEXT,
    total_rate NUMERIC,
    labour_component NUMERIC,
    material_component NUMERIC,
    plant_component NUMERIC,
    confidence NUMERIC
) AS $$
DECLARE
    normalized_query TEXT;
    ts_query tsquery;
BEGIN
    normalized_query := lower(trim(p_query));

    -- Skip if query too short
    IF length(normalized_query) < 2 THEN
        RETURN;
    END IF;

    -- Build tsquery
    BEGIN
        ts_query := websearch_to_tsquery('english', normalized_query);
    EXCEPTION WHEN OTHERS THEN
        ts_query := plainto_tsquery('english', normalized_query);
    END;

    RETURN QUERY
    SELECT
        c.id,
        c.code::TEXT,
        c.description::TEXT,
        c.category::TEXT,
        c.unit::TEXT,
        c.total_rate,
        c.labour_cost AS labour_component,
        c.material_cost AS material_component,
        c.plant_cost AS plant_component,
        -- Confidence based on match quality and unit alignment
        (
            CASE
                WHEN p_unit IS NOT NULL AND c.unit = p_unit THEN 0.9
                ELSE 0.7
            END *
            GREATEST(
                ts_rank(c.search_vector, ts_query),
                COALESCE(similarity(c.description, normalized_query) * 0.6, 0)
            )
        )::NUMERIC AS confidence
    FROM composites c
    WHERE c.is_active = true
        -- Organization filter
        AND (
            c.organization_id IS NULL
            OR c.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        -- Category filter
        AND (p_category IS NULL OR c.category ILIKE '%' || p_category || '%')
        -- Search match
        AND (
            c.search_vector @@ ts_query
            OR similarity(c.description, normalized_query) > 0.25
            OR similarity(c.code, normalized_query) > 0.4
        )
    ORDER BY
        -- Prioritize unit matches
        CASE WHEN p_unit IS NOT NULL AND c.unit = p_unit THEN 0 ELSE 1 END,
        -- Then by search relevance
        ts_rank(c.search_vector, ts_query) DESC,
        c.total_rate DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION search_composites_for_estimate IS 'Enhanced composite search for estimate generation - includes component breakdown and unit-prioritized ranking';


-- =============================================================================
-- FUNCTION 4: search_labour_rates_for_estimate
-- =============================================================================
-- Simplified labour rate search for tool calls

CREATE OR REPLACE FUNCTION search_labour_rates_for_estimate(
    p_query TEXT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    description TEXT,
    base_rate NUMERIC,
    unit TEXT,
    award_reference TEXT,
    confidence NUMERIC
) AS $$
DECLARE
    normalized_query TEXT;
    ts_query tsquery;
BEGIN
    normalized_query := lower(trim(p_query));
    IF length(normalized_query) < 2 THEN RETURN; END IF;

    BEGIN
        ts_query := websearch_to_tsquery('english', normalized_query);
    EXCEPTION WHEN OTHERS THEN
        ts_query := plainto_tsquery('english', normalized_query);
    END;

    RETURN QUERY
    SELECT
        l.id,
        l.description::TEXT,
        l.base_rate,
        COALESCE(l.unit, 'hr')::TEXT AS unit,
        l.award_reference::TEXT,
        GREATEST(
            ts_rank(l.search_vector, ts_query),
            COALESCE(similarity(l.description, normalized_query) * 0.5, 0)
        )::NUMERIC AS confidence
    FROM labour_base_rates l
    WHERE l.is_active = true
        AND (
            l.organization_id IS NULL
            OR l.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        AND (
            l.search_vector @@ ts_query
            OR similarity(l.description, normalized_query) > 0.25
        )
    ORDER BY
        ts_rank(l.search_vector, ts_query) DESC,
        l.base_rate DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION search_labour_rates_for_estimate IS 'Labour rate search for Claude tool calls';


-- =============================================================================
-- FUNCTION 5: search_materials_for_estimate
-- =============================================================================
-- Simplified material search for tool calls

CREATE OR REPLACE FUNCTION search_materials_for_estimate(
    p_query TEXT,
    p_unit TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    description TEXT,
    base_rate NUMERIC,
    unit TEXT,
    supplier TEXT,
    confidence NUMERIC
) AS $$
DECLARE
    normalized_query TEXT;
    ts_query tsquery;
BEGIN
    normalized_query := lower(trim(p_query));
    IF length(normalized_query) < 2 THEN RETURN; END IF;

    BEGIN
        ts_query := websearch_to_tsquery('english', normalized_query);
    EXCEPTION WHEN OTHERS THEN
        ts_query := plainto_tsquery('english', normalized_query);
    END;

    RETURN QUERY
    SELECT
        m.id,
        m.description::TEXT,
        m.base_rate,
        m.unit::TEXT,
        m.supplier::TEXT,
        (
            CASE
                WHEN p_unit IS NOT NULL AND m.unit = p_unit THEN 0.9
                ELSE 0.7
            END *
            GREATEST(
                ts_rank(m.search_vector, ts_query),
                COALESCE(similarity(m.description, normalized_query) * 0.5, 0)
            )
        )::NUMERIC AS confidence
    FROM materials m
    WHERE m.is_active = true
        AND (
            m.organization_id IS NULL
            OR m.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        AND (
            m.search_vector @@ ts_query
            OR similarity(m.description, normalized_query) > 0.25
        )
    ORDER BY
        CASE WHEN p_unit IS NOT NULL AND m.unit = p_unit THEN 0 ELSE 1 END,
        ts_rank(m.search_vector, ts_query) DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION search_materials_for_estimate IS 'Material search for Claude tool calls with unit prioritization';


-- =============================================================================
-- FUNCTION 6: search_plant_for_estimate
-- =============================================================================
-- Simplified plant/equipment search for tool calls

CREATE OR REPLACE FUNCTION search_plant_for_estimate(
    p_query TEXT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE(
    id UUID,
    description TEXT,
    base_rate NUMERIC,
    unit TEXT,
    supplier TEXT,
    confidence NUMERIC
) AS $$
DECLARE
    normalized_query TEXT;
    ts_query tsquery;
BEGIN
    normalized_query := lower(trim(p_query));
    IF length(normalized_query) < 2 THEN RETURN; END IF;

    BEGIN
        ts_query := websearch_to_tsquery('english', normalized_query);
    EXCEPTION WHEN OTHERS THEN
        ts_query := plainto_tsquery('english', normalized_query);
    END;

    RETURN QUERY
    SELECT
        p.id,
        p.description::TEXT,
        p.base_rate,
        COALESCE(p.unit, 'day')::TEXT AS unit,
        p.supplier::TEXT,
        GREATEST(
            ts_rank(p.search_vector, ts_query),
            COALESCE(similarity(p.description, normalized_query) * 0.5, 0)
        )::NUMERIC AS confidence
    FROM plant_base_rates p
    WHERE p.is_active = true
        AND (
            p.organization_id IS NULL
            OR p.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        AND (
            p.search_vector @@ ts_query
            OR similarity(p.description, normalized_query) > 0.25
        )
    ORDER BY
        ts_rank(p.search_vector, ts_query) DESC,
        p.base_rate DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION search_plant_for_estimate IS 'Plant/equipment search for Claude tool calls';


-- =============================================================================
-- FUNCTION 7: lookup_rate_by_id
-- =============================================================================
-- Lookup a rate by ID and type - for post-processing validation

CREATE OR REPLACE FUNCTION lookup_rate_by_id(
    p_rate_id UUID,
    p_rate_type TEXT  -- 'labour', 'material', 'plant', 'composite'
)
RETURNS TABLE(
    id UUID,
    description TEXT,
    rate NUMERIC,
    unit TEXT,
    effective_date DATE,
    found BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    CASE p_rate_type
        WHEN 'labour' THEN
            SELECT l.id, l.description::TEXT, l.base_rate, COALESCE(l.unit, 'hr')::TEXT, l.effective_date, true
            FROM labour_base_rates l WHERE l.id = p_rate_id AND l.is_active = true
        WHEN 'material' THEN
            SELECT m.id, m.description::TEXT, m.base_rate, m.unit::TEXT, m.effective_date, true
            FROM materials m WHERE m.id = p_rate_id AND m.is_active = true
        WHEN 'plant' THEN
            SELECT p.id, p.description::TEXT, p.base_rate, COALESCE(p.unit, 'day')::TEXT, p.effective_date, true
            FROM plant_base_rates p WHERE p.id = p_rate_id AND p.is_active = true
        WHEN 'composite' THEN
            SELECT c.id, c.description::TEXT, c.total_rate, c.unit::TEXT, c.effective_date, true
            FROM composites c WHERE c.id = p_rate_id AND c.is_active = true
        ELSE
            SELECT NULL::UUID, NULL::TEXT, NULL::NUMERIC, NULL::TEXT, NULL::DATE, false
    END;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION lookup_rate_by_id IS 'Lookup rate details by ID and type for post-processing validation';


-- =============================================================================
-- FUNCTION 8: validate_productivity_unit
-- =============================================================================
-- Validate that an item's unit matches the productivity constant's output_unit

CREATE OR REPLACE FUNCTION validate_productivity_unit(
    p_productivity_id UUID,
    p_expected_unit TEXT
)
RETURNS TABLE(
    productivity_id UUID,
    actual_unit TEXT,
    expected_unit TEXT,
    units_match BOOLEAN,
    hours_per_unit NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p_productivity_id,
        lpc.output_unit::TEXT,
        p_expected_unit::TEXT,
        lpc.output_unit = p_expected_unit,
        lpc.hours_per_unit
    FROM labour_productivity_constants lpc
    WHERE lpc.id = p_productivity_id AND lpc.is_active = true;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION validate_productivity_unit IS 'Validate unit compatibility between estimate item and productivity constant';


-- =============================================================================
-- GRANTS
-- =============================================================================

-- Grant execute permissions to authenticated users
GRANT EXECUTE ON FUNCTION search_productivity_for_estimate TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_labour_hours_batch TO authenticated;
GRANT EXECUTE ON FUNCTION search_composites_for_estimate TO authenticated;
GRANT EXECUTE ON FUNCTION search_labour_rates_for_estimate TO authenticated;
GRANT EXECUTE ON FUNCTION search_materials_for_estimate TO authenticated;
GRANT EXECUTE ON FUNCTION search_plant_for_estimate TO authenticated;
GRANT EXECUTE ON FUNCTION lookup_rate_by_id TO authenticated;
GRANT EXECUTE ON FUNCTION validate_productivity_unit TO authenticated;

-- Grant to service_role for edge functions
GRANT EXECUTE ON FUNCTION search_productivity_for_estimate TO service_role;
GRANT EXECUTE ON FUNCTION calculate_labour_hours_batch TO service_role;
GRANT EXECUTE ON FUNCTION search_composites_for_estimate TO service_role;
GRANT EXECUTE ON FUNCTION search_labour_rates_for_estimate TO service_role;
GRANT EXECUTE ON FUNCTION search_materials_for_estimate TO service_role;
GRANT EXECUTE ON FUNCTION search_plant_for_estimate TO service_role;
GRANT EXECUTE ON FUNCTION lookup_rate_by_id TO service_role;
GRANT EXECUTE ON FUNCTION validate_productivity_unit TO service_role;


-- Log completion
DO $$
BEGIN
    RAISE NOTICE '=== Estimate Search Tools Migration Complete ===';
    RAISE NOTICE 'Created functions:';
    RAISE NOTICE '  - search_productivity_for_estimate() - Simplified productivity search for Claude tools';
    RAISE NOTICE '  - calculate_labour_hours_batch() - Batch hours calculation';
    RAISE NOTICE '  - search_composites_for_estimate() - Enhanced composite search with component breakdown';
    RAISE NOTICE '  - search_labour_rates_for_estimate() - Labour rate search';
    RAISE NOTICE '  - search_materials_for_estimate() - Material search with unit prioritization';
    RAISE NOTICE '  - search_plant_for_estimate() - Plant/equipment search';
    RAISE NOTICE '  - lookup_rate_by_id() - Rate lookup for post-processing';
    RAISE NOTICE '  - validate_productivity_unit() - Unit compatibility validation';
END $$;
