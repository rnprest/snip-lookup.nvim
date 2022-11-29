// lib.rs
use nvim_oxi as oxi;
use oxi::conversion::{self, FromObject, ToObject};
use oxi::serde::{Deserializer, Serializer};
use oxi::{lua, print, Dictionary, Function, Object};
use serde::{Deserialize, Serialize};
use std::{collections::HashMap, path::Path};

// I can map structs into lua objects perfectly fine, but hashmaps? Absolutely not.
// Thus, this wrapper struct was born.
// NOTE: I tried to have 2 separate structs (with one being a HashMap of <i32, String>), and the
// Dictionary::from_iter at the bottom kept complaining about expecting whatever struct was passed
// in first... Using the same wrapper struct for both hashmaps was the only way I could get around
// this error

#[derive(Debug, Serialize, Deserialize)]
struct NeovimWrapper {
    pub contents: HashMap<String, String>,
}

//------------------------------------------------------------------//
//           I'm yoinking these impl's straight from the            //
//                          example here:                           //
//        https://github.com/noib3/nvim-oxi/blob/master/exam        //
//                         ples/mechanic.rs                         //
//------------------------------------------------------------------//

impl FromObject for NeovimWrapper {
    fn from_object(obj: Object) -> Result<Self, conversion::Error> {
        Self::deserialize(Deserializer::new(obj)).map_err(Into::into)
    }
}

impl ToObject for NeovimWrapper {
    fn to_object(self) -> Result<Object, conversion::Error> {
        self.serialize(Serializer::new()).map_err(Into::into)
    }
}

impl lua::Poppable for NeovimWrapper {
    unsafe fn pop(lstate: *mut lua::ffi::lua_State) -> Result<Self, lua::Error> {
        let obj = Object::pop(lstate)?;
        Self::from_object(obj).map_err(lua::Error::pop_error_from_err::<Self, _>)
    }
}

impl lua::Pushable for NeovimWrapper {
    unsafe fn push(self, lstate: *mut lua::ffi::lua_State) -> Result<std::ffi::c_int, lua::Error> {
        self.to_object()
            .map_err(lua::Error::push_error_from_err::<Self, _>)?
            .push(lstate)
    }
}

//------------------------------------------------------------------//
//              Used for deserializing our yaml config              //
//------------------------------------------------------------------//

#[derive(Debug, Serialize, Deserialize)]
struct Category {
    pub icon: String, // TODO: make this an option or default it
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
fn snip_lookup_rust() -> oxi::Result<Dictionary> {
    let get_categories = Function::from_fn::<_, oxi::Error>(move |path: String| {
        let mut category_names: HashMap<String, String> = HashMap::new();

        let sc = SnippetConfig::load(path).unwrap();
        for (category_name, category_contents) in sc.categories.into_iter() {
            print!(
                "inserting {},{} into the category_names!",
                category_name.to_string(),
                category_contents.icon.to_string()
            );
            category_names.insert(
                category_name.to_string(),
                category_contents.icon.to_string(),
            );
        }

        let nvim_categories = NeovimWrapper {
            contents: category_names,
        };
        Ok(nvim_categories)
    });

    // TODO: figure out a way to pass 2 closures to this function..
    // Currently, I'm having to combine both arguments into a comma-separated string
    let get_snippets = Function::from_fn::<_, oxi::Error>(move |path_and_category: String| {
        let args: Vec<&str> = path_and_category.split(",").collect();
        let path = args[0].to_string();
        let category = args[1].to_string();
        print!("path = {}", path);
        print!("category = {}", category);

        let mut snippets: HashMap<String, String> = HashMap::new();

        let sc = SnippetConfig::load(path).unwrap();
        if let Some(category) = sc.categories.get(&category) {
            for snippet in &category.snippets {
                for (name, value) in snippet.iter() {
                    snippets.insert(name.to_string(), value.to_string());
                }
            }
        }

        let nvim_snippets = NeovimWrapper { contents: snippets };
        Ok(nvim_snippets)
    });

    Ok(Dictionary::from_iter([
        ("get_categories", get_categories),
        ("get_snippets", get_snippets),
    ]))
}
