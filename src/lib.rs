// lib.rs
use nvim_oxi as oxi;
use oxi::print;
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, path::Path};

#[derive(Debug, Serialize, Deserialize)]
struct Category {
    pub icon: String, // TODO: make this an option
    pub snippets: Vec<HashMap<String, String>>,
}

#[derive(Debug, Serialize, Deserialize)]
struct SnippetConfig {
    pub categories: HashMap<String, Category>,
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

    // ---------------------------------------------
    let mut category_names: HashMap<i32, String> = HashMap::new();
    let mut index = 0;
    for category_name in sc.categories.keys() {
        category_names.insert(index, category_name.to_string());
        index = index + 1;
    }
    print!("category_names = {:#?}", &category_names);
    // ---------------------------------------------

    // ---------------------------------------------
    let chosen_category = "phone_numbers";
    let mut snippets: HashMap<String, String> = HashMap::new();
    if let Some(category) = sc.categories.get(chosen_category) {
        for snippet in &category.snippets {
            for (name, value) in snippet.iter() {
                snippets.insert(name.to_string(), value.to_string());
            }
        }
    }
    print!("snippets = {:#?}", &snippets);
    // ---------------------------------------------

    Ok(format!("sc = {:#?}", sc))
    // Ok(42)
}
