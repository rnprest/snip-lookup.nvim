// lib.rs
use nvim_oxi as oxi;
use oxi::print;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, path::Path};

#[derive(Debug, Serialize, Deserialize)]
struct Category {
    pub name: String,
    pub icon: String, // TODO: make this an option
    pub snippets: Vec<HashMap<String, String>>,
}

#[derive(Debug, Serialize, Deserialize)]
struct SnippetConfig {
    pub categories: Vec<Category>,
}

impl SnippetConfig {
    fn load<P: AsRef<Path>>(p: P) -> Result<SnippetConfig, serde_yaml::Error> {
        let data = std::fs::read_to_string(p).ok().unwrap();
        let config: SnippetConfig = serde_yaml::from_str(&data).unwrap();

        Ok(config)
    }
}

#[oxi::module]
fn snip_lookup_rust() -> oxi::Result<String> {
    fn something() -> String {
        "something".to_string()
    }
    fn something_else() -> String {
        "something".to_string()
    }
    let mut result = something();

    let sc_path = "/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml";
    let sc = SnippetConfig::load(sc_path).unwrap();
    result = format!("sc = {:#?}", &sc);

    print!("sc = {:#?}", &sc);

    // ---------------------------------------------
    let mut category_names = Vec::new();
    for category in &sc.categories {
        category_names.push(category.name.clone());
        // catogories.push(category)
    }
    print!("category_names = {:#?}", &category_names);
    // ---------------------------------------------

    let chosen_category = "Phone Numbers";
    let mut snippet_names = Vec::new();
    let mut snippet_values = Vec::new();
    // TODO: this definitely needs to be a hashmap... not a vector
    for category in &sc.categories {
        if category.name == chosen_category {
            for snippet in &category.snippets {
                for (snippet_name, snippet_value) in snippet.iter() {
                    snippet_names.push(snippet_name);
                    snippet_values.push(snippet_value);
                }
            }
        }
    }
    print!("snippet_names = {:#?}", &snippet_names);
    print!("snippet_values = {:#?}", &snippet_values);

    Ok(format!("sc = {:#?}", sc))
    // Ok(42)
}
