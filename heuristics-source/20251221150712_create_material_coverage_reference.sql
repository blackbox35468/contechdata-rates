-- Material Coverage Reference Knowledge Base
-- Stores standard coverage values for material types with semantic search support

-- Enable required extensions if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Create the material_coverage_reference table
CREATE TABLE IF NOT EXISTS material_coverage_reference (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Organization scope: NULL = global (visible to all), UUID = org-specific
    organization_id UUID REFERENCES organizations(id) ON DELETE CASCADE,

    -- Material identification
    material_type TEXT NOT NULL,           -- e.g., 'paint', 'sealant', 'adhesive', 'grout'
    material_subtype TEXT,                 -- e.g., 'interior_primer', 'silicone', 'tile_adhesive'
    product_pattern TEXT NOT NULL,         -- Pattern for matching: "interior primer%", "silicone sealant%"
    description TEXT,                      -- Human-readable description

    -- Coverage specification
    coverage_value NUMERIC(10,4) NOT NULL, -- e.g., 12.0 (the coverage rate)
    coverage_unit TEXT NOT NULL,           -- e.g., 'm2', 'LM' (what the coverage is measured in)
    package_unit TEXT NOT NULL,            -- e.g., 'L', 'tube', '20kg bag' (what you buy)
    package_size NUMERIC(10,4),            -- e.g., 4 (for 4L tin), 300 (for 300ml tube)
    package_size_unit TEXT,                -- e.g., 'L', 'ml', 'kg'

    -- Application details
    coats INTEGER DEFAULT 1,               -- Number of coats (for paints)
    thickness_mm NUMERIC(6,2),             -- Application thickness (for renders, membranes)
    bead_size TEXT,                        -- e.g., '6mm x 6mm' (for sealants)

    -- Source and confidence
    source_type TEXT NOT NULL DEFAULT 'industry_standard'
        CHECK (source_type IN ('manufacturer', 'industry_standard', 'ai_researched', 'user_defined')),
    source_url TEXT,                       -- Link to manufacturer spec sheet
    source_manufacturer TEXT,              -- e.g., 'Dulux', 'Selleys', 'Sika'
    source_product_name TEXT,              -- Specific product name if applicable
    confidence_score NUMERIC(3,2) DEFAULT 0.80 CHECK (confidence_score >= 0 AND confidence_score <= 1),

    -- Coverage range and conditions
    coverage_range JSONB DEFAULT '{}',     -- {"min": 10, "max": 14, "typical": 12}
    application_conditions JSONB DEFAULT '{}', -- {"substrate": "concrete", "gap_width_mm": 6}
    notes TEXT,                            -- Additional notes

    -- Search support
    embedding vector(1024),                -- Voyage AI embedding for semantic search
    embedding_model TEXT,                  -- Model used: 'voyage-3.5-lite'
    embedding_updated_at TIMESTAMPTZ,
    search_vector tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(material_type, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(material_subtype, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(product_pattern, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
        setweight(to_tsvector('english', coalesce(source_manufacturer, '')), 'C')
    ) STORED,

    -- Status and verification
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,    -- Human verified
    verified_by UUID REFERENCES auth.users(id),
    verified_at TIMESTAMPTZ,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id)
);

-- Add comment for documentation
COMMENT ON TABLE material_coverage_reference IS 'Knowledge base of standard material coverage values for automatic matching and unit conversion';

-- Indexes for efficient querying

-- Organization filtering
CREATE INDEX idx_coverage_ref_org ON material_coverage_reference(organization_id);

-- Material type filtering
CREATE INDEX idx_coverage_ref_type ON material_coverage_reference(material_type);
CREATE INDEX idx_coverage_ref_subtype ON material_coverage_reference(material_subtype) WHERE material_subtype IS NOT NULL;

-- Full-text search
CREATE INDEX idx_coverage_ref_fts ON material_coverage_reference USING GIN(search_vector);

-- Trigram index for fuzzy matching on product pattern
CREATE INDEX idx_coverage_ref_pattern_trgm ON material_coverage_reference USING GIN(product_pattern gin_trgm_ops);

-- Vector search (HNSW for fast similarity search)
CREATE INDEX idx_coverage_ref_embedding ON material_coverage_reference
    USING hnsw(embedding vector_cosine_ops)
    WITH (m = 16, ef_construction = 64);

-- Active items filter
CREATE INDEX idx_coverage_ref_active ON material_coverage_reference(is_active) WHERE is_active = true;

-- Composite index for common queries
CREATE INDEX idx_coverage_ref_type_active ON material_coverage_reference(material_type, is_active) WHERE is_active = true;

-- Enable Row Level Security
ALTER TABLE material_coverage_reference ENABLE ROW LEVEL SECURITY;

-- RLS Policies (following library_items pattern)

-- Users can view global items (org_id IS NULL) + their org's custom items
CREATE POLICY "coverage_ref_select_policy" ON material_coverage_reference
    FOR SELECT
    USING (
        organization_id IS NULL
        OR organization_id IN (SELECT organization_id FROM profiles WHERE id = auth.uid())
    );

-- Users can only insert items for their own organization (not global)
CREATE POLICY "coverage_ref_insert_policy" ON material_coverage_reference
    FOR INSERT
    WITH CHECK (
        organization_id IS NOT NULL
        AND organization_id IN (SELECT organization_id FROM profiles WHERE id = auth.uid())
    );

-- Users can only update their org's items (not global items)
CREATE POLICY "coverage_ref_update_policy" ON material_coverage_reference
    FOR UPDATE
    USING (
        organization_id IS NOT NULL
        AND organization_id IN (SELECT organization_id FROM profiles WHERE id = auth.uid())
    );

-- Users can only delete their org's items (not global items)
CREATE POLICY "coverage_ref_delete_policy" ON material_coverage_reference
    FOR DELETE
    USING (
        organization_id IS NOT NULL
        AND organization_id IN (SELECT organization_id FROM profiles WHERE id = auth.uid())
    );

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_coverage_ref_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_coverage_ref_updated_at
    BEFORE UPDATE ON material_coverage_reference
    FOR EACH ROW
    EXECUTE FUNCTION update_coverage_ref_updated_at();

-- Semantic search function for coverage matching
CREATE OR REPLACE FUNCTION search_coverage_reference_semantic(
    query_embedding vector(1024),
    match_threshold REAL DEFAULT 0.5,
    result_limit INTEGER DEFAULT 10,
    type_filter TEXT DEFAULT NULL,
    subtype_filter TEXT DEFAULT NULL
)
RETURNS TABLE(
    id uuid,
    material_type text,
    material_subtype text,
    product_pattern text,
    description text,
    coverage_value numeric,
    coverage_unit text,
    package_unit text,
    package_size numeric,
    package_size_unit text,
    coats integer,
    source_type text,
    source_manufacturer text,
    confidence_score numeric,
    coverage_range jsonb,
    similarity real
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cr.id,
        cr.material_type,
        cr.material_subtype,
        cr.product_pattern,
        cr.description,
        cr.coverage_value,
        cr.coverage_unit,
        cr.package_unit,
        cr.package_size,
        cr.package_size_unit,
        cr.coats,
        cr.source_type,
        cr.source_manufacturer,
        cr.confidence_score,
        cr.coverage_range,
        (1 - (cr.embedding <=> query_embedding))::real as similarity
    FROM material_coverage_reference cr
    WHERE cr.is_active = true
        AND cr.embedding IS NOT NULL
        AND (1 - (cr.embedding <=> query_embedding)) > match_threshold
        AND (
            cr.organization_id IS NULL
            OR cr.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        AND (type_filter IS NULL OR cr.material_type = type_filter)
        AND (subtype_filter IS NULL OR cr.material_subtype = subtype_filter)
    ORDER BY cr.embedding <=> query_embedding
    LIMIT result_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Full-text search function with fuzzy matching
CREATE OR REPLACE FUNCTION search_coverage_reference_text(
    search_query TEXT,
    result_limit INTEGER DEFAULT 20,
    type_filter TEXT DEFAULT NULL
)
RETURNS TABLE(
    id uuid,
    material_type text,
    material_subtype text,
    product_pattern text,
    description text,
    coverage_value numeric,
    coverage_unit text,
    package_unit text,
    source_manufacturer text,
    confidence_score numeric,
    rank real
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cr.id,
        cr.material_type,
        cr.material_subtype,
        cr.product_pattern,
        cr.description,
        cr.coverage_value,
        cr.coverage_unit,
        cr.package_unit,
        cr.source_manufacturer,
        cr.confidence_score,
        GREATEST(
            ts_rank(cr.search_vector, websearch_to_tsquery('english', search_query)),
            similarity(cr.product_pattern, search_query) * 0.5
        )::real as rank
    FROM material_coverage_reference cr
    WHERE cr.is_active = true
        AND (
            cr.organization_id IS NULL
            OR cr.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
        AND (type_filter IS NULL OR cr.material_type = type_filter)
        AND (
            cr.search_vector @@ websearch_to_tsquery('english', search_query)
            OR similarity(cr.product_pattern, search_query) > 0.3
        )
    ORDER BY rank DESC
    LIMIT result_limit;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Function to get distinct material types
CREATE OR REPLACE FUNCTION get_coverage_material_types()
RETURNS TABLE(
    material_type text,
    count bigint
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cr.material_type,
        COUNT(*)::bigint
    FROM material_coverage_reference cr
    WHERE cr.is_active = true
        AND (
            cr.organization_id IS NULL
            OR cr.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
    GROUP BY cr.material_type
    ORDER BY cr.material_type;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- Function to get subtypes for a given type
CREATE OR REPLACE FUNCTION get_coverage_subtypes(p_material_type TEXT)
RETURNS TABLE(
    material_subtype text,
    count bigint
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cr.material_subtype,
        COUNT(*)::bigint
    FROM material_coverage_reference cr
    WHERE cr.is_active = true
        AND cr.material_type = p_material_type
        AND cr.material_subtype IS NOT NULL
        AND (
            cr.organization_id IS NULL
            OR cr.organization_id IN (SELECT organization_id FROM profiles WHERE profiles.id = auth.uid())
        )
    GROUP BY cr.material_subtype
    ORDER BY cr.material_subtype;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
