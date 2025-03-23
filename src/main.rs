use dioxus::{
    logger::tracing::{self, info},
    prelude::*,
};

const FAVICON: Asset = asset!("assets/favicon.ico");
const CSS: Asset = asset!("assets/main.css");
const HEADER_SVG: Asset = asset!("/assets/header.svg");

fn main() {
    dioxus::launch(App);
}

#[component]
fn App() -> Element {
    rsx! {
        document::Stylesheet { href: CSS }
        Title {}
        DogView {}
    }
}

#[component]
fn Title() -> Element {
    rsx! {
        div { id: "title",
            h1 { "HotDog! 🌭" }
        }
    }
}
#[derive(serde::Deserialize)]
struct DogApi {
    message: String,
}
#[component]
fn DogView() -> Element {
    let mut img_src = use_signal(|| "".to_string());
    let fetch_new = move |_| async move {
        let reponse = reqwest::get("https://dog.ceo/api/breeds/image/random")
            .await
            .unwrap()
            .json::<DogApi>()
            .await
            .unwrap();
        img_src.set(reponse.message);
    };
    rsx! {
        div { id: "dogview",
            img { src: "{img_src}" }
        }
        div { id: "buttons",
            // ..
            button { onclick: fetch_new, id: "save", "save!" }
        }
    }
}
