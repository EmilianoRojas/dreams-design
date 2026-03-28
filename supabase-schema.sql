-- Jewelry Studio - Supabase Schema
-- Run this in your Supabase SQL editor

CREATE TABLE materials (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'other',
  unit TEXT NOT NULL DEFAULT 'pieces',
  cost_per_unit DECIMAL(10,4) NOT NULL DEFAULT 0,
  stock_quantity DECIMAL(10,4) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE designs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'bracelet',
  notes TEXT,
  labor_cost DECIMAL(10,2) DEFAULT 0,
  sale_price DECIMAL(10,2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE design_materials (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  design_id UUID REFERENCES designs(id) ON DELETE CASCADE NOT NULL,
  material_id UUID REFERENCES materials(id) ON DELETE RESTRICT NOT NULL,
  quantity DECIMAL(10,4) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE designs ENABLE ROW LEVEL SECURITY;
ALTER TABLE design_materials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own materials"
  ON materials FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own designs"
  ON designs FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users manage own design_materials"
  ON design_materials FOR ALL
  USING (design_id IN (SELECT id FROM designs WHERE user_id = auth.uid()))
  WITH CHECK (design_id IN (SELECT id FROM designs WHERE user_id = auth.uid()));
