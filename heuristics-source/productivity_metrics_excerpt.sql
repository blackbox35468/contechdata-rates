    name TEXT NOT NULL,
    category TEXT,
    contact JSONB DEFAULT '{}',
    specialties JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 16. Productivity metrics table
CREATE TABLE productivity_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    metric_name TEXT NOT NULL,
    metric_value NUMERIC NOT NULL,
    unit TEXT,
    effective_date DATE DEFAULT CURRENT_DATE,
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 17. Project duration data table
CREATE TABLE project_duration_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_type TEXT NOT NULL,
    avg_duration_days INTEGER,
    complexity_factor NUMERIC DEFAULT 1.0,
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 18. Duration scenarios table
CREATE TABLE duration_scenarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scenario_name TEXT NOT NULL,
    base_duration INTEGER NOT NULL,
    adjustment_factor NUMERIC DEFAULT 1.0,
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- 19. AI suggestions table
CREATE TABLE ai_suggestions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    suggestion_type TEXT NOT NULL,
    suggestion_text TEXT NOT NULL,
    confidence_score NUMERIC DEFAULT 0.0,
    context_data JSONB DEFAULT '{}',
    is_applied BOOLEAN DEFAULT false,
    organization_id UUID REFERENCES organizations(id),
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create production views to match schema
CREATE VIEW composite_components_with_total AS
SELECT 
    cc.*,
    (cc.quantity * cc.rate) as total_cost
FROM composite_components cc;

CREATE VIEW gang_composition AS
SELECT 
    gl.gang_id,
    g.gang_code,
    gl.labour_base_id,
    lb.code as labour_code,
    lb.description as labour_description,
    gl.quantity,
    gl.daily_bare_cost,
    gl.daily_incl_op_cost
FROM gang_labour gl
JOIN gangs g ON gl.gang_id = g.gang_id
JOIN labour_base lb ON gl.labour_base_id = lb.id;

CREATE VIEW gang_composition_with_rates AS
SELECT 
    gc.*,
    lb.base_rate,
    (gc.quantity * lb.base_rate) as calculated_cost
FROM gang_composition gc
JOIN labour_base lb ON gc.labour_base_id = lb.id;

CREATE VIEW gang_summary AS
