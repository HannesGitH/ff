#[derive(Debug)]
pub struct Field {
    pub type_str: String,
    pub name_str: String,
    pub is_nullable: bool,
    pub is_map: bool,
    pub map_key_type: Option<String>,
    pub map_value_type: Option<String>,
}

#[derive(Debug)]
pub struct Class {
    pub name_str: String,
    pub fields: Vec<Field>,
}
