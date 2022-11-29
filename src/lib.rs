// lib.rs
use nvim_oxi as oxi;
use oxi::conversion::{self, FromObject, ToObject};
use oxi::serde::{Deserializer, Serializer};
use oxi::{lua, print, Dictionary, Function, Object};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, path::Path};

#[derive(Debug, Serialize, Deserialize)]

struct Cat {
    pub names: HashMap<String, String>,
}

impl FromObject for Cat {
    fn from_object(obj: Object) -> Result<Self, conversion::Error> {
        Self::deserialize(Deserializer::new(obj)).map_err(Into::into)
    }
}

impl ToObject for Cat {
    fn to_object(self) -> Result<Object, conversion::Error> {
        self.serialize(Serializer::new()).map_err(Into::into)
    }
}

impl lua::Poppable for Cat {
    unsafe fn pop(lstate: *mut lua::ffi::lua_State) -> Result<Self, lua::Error> {
        let obj = Object::pop(lstate)?;
        Self::from_object(obj).map_err(lua::Error::pop_error_from_err::<Self, _>)
    }
}

impl lua::Pushable for Cat {
    unsafe fn push(self, lstate: *mut lua::ffi::lua_State) -> Result<std::ffi::c_int, lua::Error> {
        self.to_object()
            .map_err(lua::Error::push_error_from_err::<Self, _>)?
            .push(lstate)
    }
}
// ----------

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

// fn get_categories(path: String) -> oxi::Result<HashMap<i32, String>> {
//     let sc = SnippetConfig::load(path).unwrap();

//     let mut category_names: HashMap<i32, String> = HashMap::new();
//     let mut index = 0;
//     for category_name in sc.categories.keys() {
//         category_names.insert(index, category_name.to_string());
//         index = index + 1;
//     }
//     print!("category_names = {:#?}", &category_names);
//     Ok(category_names)
// }

// fn get_snippets(path: String, category: String) -> oxi::Result<HashMap<String, String>> {
//     let sc = SnippetConfig::load(path).unwrap();

//     let mut snippets: HashMap<String, String> = HashMap::new();
//     if let Some(category) = sc.categories.get(&category) {
//         for snippet in &category.snippets {
//             for (name, value) in snippet.iter() {
//                 snippets.insert(name.to_string(), value.to_string());
//             }
//         }
//     }
//     let object: nvim_oxi::Dictionary = snippets;
//     Ok(snippets)
// }

#[oxi::module]
fn snip_lookup_rust() -> oxi::Result<Dictionary> {
    // fn something() -> String {
    //     "something".to_string()
    // }
    // fn something_else() -> String {
    //     "something".to_string()
    // }
    // let mut result = something();

    // let sc_path = "/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml";
    // let sc = SnippetConfig::load(sc_path).unwrap();
    // result = format!("sc = {:#?}", &sc);

    // // ---------------------------------------------
    // let mut category_names: HashMap<i32, String> = HashMap::new();
    // let mut index = 0;
    // for category_name in sc.categories.keys() {
    //     category_names.insert(index, category_name.to_string());
    //     index = index + 1;
    // }
    // print!("category_names = {:#?}", &category_names);
    // // ---------------------------------------------

    // ---------------------------------------------
    // let chosen_category = "phone_numbers";
    // let mut snippets: HashMap<String, String> = HashMap::new();
    // if let Some(category) = sc.categories.get(chosen_category) {
    //     for snippet in &category.snippets {
    //         for (name, value) in snippet.iter() {
    //             snippets.insert(name.to_string(), value.to_string());
    //         }
    //     }
    // }
    // print!("snippets = {:#?}", &snippets);
    // ---------------------------------------------

    // fn get_categories(path: String) -> oxi::Result<HashMap<i32, String>> {
    //     let sc = SnippetConfig::load(path).unwrap();

    //     let mut category_names: HashMap<i32, String> = HashMap::new();
    //     let mut index = 0;
    //     for category_name in sc.categories.keys() {
    //         category_names.insert(index, category_name.to_string());
    //         index = index + 1;
    //     }
    //     print!("category_names = {:#?}", &category_names);
    //     Ok(category_names)
    // }

    // let sc_path = "/Users/rpreston/personal/plugins/snip-lookup.nvim/snippets.yaml";
    // let sc = SnippetConfig::load(sc_path).unwrap();

    let get_categories = Function::from_fn::<_, oxi::Error>(move |()| {
        print!("hello from get_categories");

        let mut snippets: HashMap<String, String> = HashMap::new();
        snippets.insert("testing".to_string(), "aoeuaoeu".to_string());

        let aoeu = Cat { names: snippets };
        // let lol = nvim_oxi::Object::from(snippets)

        Ok(aoeu)
    });

    Ok(Dictionary::from_iter([
        ("get_categories", get_categories),
        // ("get_snippets", Function::from(get_snippets)),
    ]))
    // Ok(42)
}
