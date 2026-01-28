use crate::types::{Class, Field};
use anyhow::Result;
use tree_sitter::{Parser, Tree, TreeCursor};
use tree_sitter_dart::language;

pub fn get_tree(code: &str) -> Result<Tree> {
    let mut parser = Parser::new();
    parser.set_language(&language())?;
    let tree = parser
        .parse(code, None)
        .ok_or(anyhow::anyhow!("Error parsing Dart code"))?;
    Ok(tree)
}

/// Check if a class definition is preceded by a comment containing the magic token.
/// Returns the class name (with $ prefix) and the class body node if found.
fn check_and_handle_class_definition<'a, 'b>(
    cursor: &'b mut TreeCursor<'a>,
    prev_node: tree_sitter::Node<'a>,
    code: &'a str,
    magic_token: &'a str,
) -> Result<Option<(&'a str, tree_sitter::Node<'a>)>> {
    if cursor.node().kind() == "class_definition" {
        if prev_node.kind() != "comment" {
            return Ok(None);
        };
        let comment = prev_node.utf8_text(code.as_bytes()).unwrap();
        if !comment.contains(magic_token) {
            return Ok(None);
        };
        let class_name = cursor
            .node()
            .child_by_field_name("name")
            .unwrap()
            .utf8_text(code.as_bytes())
            .unwrap();
        // Only process classes that start with $
        if !class_name.starts_with('$') {
            return Ok(None);
        }
        let class_body = cursor.node().child_by_field_name("body").unwrap();
        return Ok(Some((class_name, class_body)));
    }
    Ok(None)
}

/// Parse a type string and extract map information if it's a Map type.
fn parse_type_info(type_str: &str) -> (bool, Option<String>, Option<String>) {
    // Check if it's a Map type
    if type_str.starts_with("Map<") && type_str.ends_with(">") {
        let inner = &type_str[4..type_str.len() - 1];
        // Split by comma, handling nested generics
        let mut depth = 0;
        let mut split_pos = None;
        for (i, c) in inner.chars().enumerate() {
            match c {
                '<' => depth += 1,
                '>' => depth -= 1,
                ',' if depth == 0 => {
                    split_pos = Some(i);
                    break;
                }
                _ => {}
            }
        }
        if let Some(pos) = split_pos {
            let key_type = inner[..pos].trim().to_string();
            let value_type = inner[pos + 1..].trim().to_string();
            return (true, Some(key_type), Some(value_type));
        }
    }
    (false, None, None)
}

/// Extract the full type string from a formal parameter node.
fn extract_type_from_formal_parameter(node: tree_sitter::Node, code: &str) -> Option<String> {
    let mut cursor = node.walk();
    let mut type_parts = Vec::new();
    let mut is_nullable = false;

    for child in node.named_children(&mut cursor) {
        match child.kind() {
            "type_identifier" => {
                type_parts.push(child.utf8_text(code.as_bytes()).unwrap().to_string());
            }
            "type_arguments" => {
                // Get the full type arguments text
                let args_text = child.utf8_text(code.as_bytes()).unwrap();
                if let Some(last) = type_parts.last_mut() {
                    *last = format!("{}{}", last, args_text);
                }
            }
            "nullable_type" => {
                // Handle nullable types - extract the inner type
                is_nullable = true;
                let inner_text = child.utf8_text(code.as_bytes()).unwrap();
                // Remove the trailing ? to get the base type
                let base_type = inner_text.trim_end_matches('?');
                type_parts.push(base_type.to_string());
            }
            _ => {}
        }
    }

    if type_parts.is_empty() {
        return None;
    }

    let mut result = type_parts.join("");
    if is_nullable {
        result.push('?');
    }
    Some(result)
}

/// Extract the parameter name from a formal parameter node.
fn extract_name_from_formal_parameter(node: tree_sitter::Node, code: &str) -> Option<String> {
    let mut cursor = node.walk();
    for child in node.named_children(&mut cursor) {
        if child.kind() == "identifier" {
            return Some(child.utf8_text(code.as_bytes()).unwrap().to_string());
        }
    }
    None
}

pub fn parse(code: &str, magic_token: &str) -> Result<Vec<Class>> {
    let tree = get_tree(code)?;
    let root_node = tree.root_node();
    let mut cursor = root_node.walk();

    // go into program
    cursor.goto_first_child();

    // now get the class definitions marked with magic token
    let mut classes_to_parse = Vec::new();
    let mut prev_node = root_node;
    loop {
        let new_class = check_and_handle_class_definition(&mut cursor, prev_node, code, magic_token)?;
        if let Some(new_class) = new_class {
            classes_to_parse.push(new_class);
        }
        prev_node = cursor.node();
        if !cursor.goto_next_sibling() {
            break;
        }
    }

    // now get the fields from constructor parameters in these classes
    let mut classes_with_fields = Vec::new();
    for (class_name, class_body) in classes_to_parse {
        let mut fields = Vec::new();
        let mut cursor = class_body.walk();

        // Find constructor declarations in the class body
        for child in class_body.named_children(&mut cursor) {
            if child.kind() == "declaration" {
                // Look for constant_constructor_signature or constructor_signature
                let mut decl_cursor = child.walk();
                for decl_child in child.named_children(&mut decl_cursor) {
                    if decl_child.kind() == "constant_constructor_signature"
                        || decl_child.kind() == "constructor_signature"
                    {
                        // Find formal_parameter_list
                        let mut sig_cursor = decl_child.walk();
                        for sig_child in decl_child.named_children(&mut sig_cursor) {
                            if sig_child.kind() == "formal_parameter_list" {
                                // Look for optional_formal_parameters or named formal parameters
                                let mut param_list_cursor = sig_child.walk();
                                for param_container in sig_child.named_children(&mut param_list_cursor) {
                                    if param_container.kind() == "optional_formal_parameters" {
                                        // Iterate over formal_parameter children
                                        let mut opt_cursor = param_container.walk();
                                        for formal_param in param_container.named_children(&mut opt_cursor) {
                                            if formal_param.kind() == "formal_parameter" {
                                                if let (Some(type_str), Some(name_str)) = (
                                                    extract_type_from_formal_parameter(formal_param, code),
                                                    extract_name_from_formal_parameter(formal_param, code),
                                                ) {
                                                    let is_nullable = type_str.ends_with('?');
                                                    let base_type = if is_nullable {
                                                        type_str.trim_end_matches('?').to_string()
                                                    } else {
                                                        type_str.clone()
                                                    };
                                                    let (is_map, map_key_type, map_value_type) =
                                                        parse_type_info(&base_type);
                                                    fields.push(Field {
                                                        name_str,
                                                        type_str: base_type,
                                                        is_nullable,
                                                        is_map,
                                                        map_key_type,
                                                        map_value_type,
                                                    });
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Strip the $ prefix from class name for the output
        let output_class_name = class_name.strip_prefix('$').unwrap_or(class_name);
        classes_with_fields.push(Class {
            name_str: output_class_name.to_string(),
            fields,
        });
    }

    Ok(classes_with_fields)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_ff_state() {
        let code = r#"
// ff-state
class $TestState {
  const $TestState({
    required String name,
    required int count,
    required Map<String, bool> flags,
  });
}
"#;
        let classes = parse(code, "ff-state").unwrap();
        assert_eq!(classes.len(), 1);
        assert_eq!(classes[0].name_str, "TestState");
        assert_eq!(classes[0].fields.len(), 3);
        assert_eq!(classes[0].fields[0].name_str, "name");
        assert_eq!(classes[0].fields[0].type_str, "String");
        assert_eq!(classes[0].fields[1].name_str, "count");
        assert_eq!(classes[0].fields[1].type_str, "int");
        assert_eq!(classes[0].fields[2].name_str, "flags");
        assert_eq!(classes[0].fields[2].type_str, "Map<String, bool>");
        assert!(classes[0].fields[2].is_map);
        assert_eq!(classes[0].fields[2].map_key_type, Some("String".to_string()));
        assert_eq!(classes[0].fields[2].map_value_type, Some("bool".to_string()));
    }
}
