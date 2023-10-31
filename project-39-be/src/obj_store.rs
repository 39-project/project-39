use std::{env, fs, path::Path};

use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use sqlx::{Pool, Sqlite};
use uuid::Uuid;

use crate::project_39_pb::{
    DisplayObject, GetDisplayObjectBatchResponse, GetDisplayObjectStatusResponse,
};

static STORE_PATH_PREFIX: Lazy<String> = Lazy::new(|| {
    let store_path_prefix = env::var("STORE_PATH_PREFIX").unwrap();
    log::info!("STORE_PATH_PREFIX: `{store_path_prefix}`");
    store_path_prefix
});

pub(crate) fn save_user_profile_picture_bin(user_profile_picture_bin: Vec<u8>) -> String {
    let file_name = Uuid::new_v4().to_string();
    let path = format!("{}/{file_name}", *STORE_PATH_PREFIX);
    log::info!("save user profile picture bin to `{path}`");
    std::fs::write(&path, user_profile_picture_bin).unwrap();
    path
}

pub const SIMPLE_LOCAL_STORE_URL: &str = "../data/objs";

pub const SIMPLE_OBJ_STORE_URL: &str = "http://127.0.0.1:8000";

fn scan_objs_id(path: &Path) -> usize {
    let path = fs::canonicalize(path).unwrap();
    log::info!("scan_objs_id: path = `{path:?}`");
    let dir = path.read_dir().unwrap();
    let ret = dir.count() - 2;
    log::info!("scan_objs_id: len = {ret}");
    ret
}

#[derive(Serialize, Deserialize)]
struct MetaObj {
    obj_name: String,
    category: String,
    desc: String,
    location: String,
}

pub fn simple_local_batch(url: &str) -> GetDisplayObjectBatchResponse {
    let path = Path::new(url);
    let path = fs::canonicalize(path).unwrap();
    let objs = (1..=scan_objs_id(&path))
        .map(|i| {
            let path = path.join(format!("{i}")).join("meta.json");
            log::info!("read_to_string: `{path:?}`");
            let json = fs::read_to_string(path).unwrap();
            let MetaObj {
                obj_name,
                category,
                desc,
                location,
            } = serde_json::from_str(&json).unwrap();

            let path = Path::new(url);
            let path = fs::canonicalize(path).unwrap();
            let dir = path.join(format!("{i}")).read_dir().unwrap();

            let mut obj_profile_picture_url = None;
            for x in dir {
                let file_name = x.unwrap().file_name();
                let file_name = file_name.to_str().unwrap();
                if file_name.starts_with("profile") {
                    obj_profile_picture_url = Some({
                        let uri: tonic::transport::Uri = SIMPLE_OBJ_STORE_URL.parse().unwrap();
                        let path = file_name.to_string();
                        let path = Path::new(&path).to_str().unwrap();

                        format!("{uri}objs/{i}/{path}")
                    });
                }
            }
            let obj_profile_picture_url = obj_profile_picture_url.unwrap_or_default();

            DisplayObject {
                obj_id: i as i64,
                obj_profile_picture_url,
                obj_profile_picture_bin: Vec::new(),
                obj_name,
                category,
                desc,
                location,
                ownership: String::new(),
            }
        })
        .collect();

    GetDisplayObjectBatchResponse { objs }
}

pub async fn init_display_object_status(sql_executor: &Pool<Sqlite>) {
    let path = Path::new(SIMPLE_LOCAL_STORE_URL);
    let path = fs::canonicalize(path).unwrap();
    for _ in 1..scan_objs_id(&path) {
        sqlx::query!("insert into objs (ownership) values ('')")
            .execute(sql_executor)
            .await
            .unwrap();
    }
}

pub async fn get_display_object_status(
    sql_executor: &Pool<Sqlite>,
    i: i64,
) -> anyhow::Result<GetDisplayObjectStatusResponse> {
    let obj = simple_local_batch(SIMPLE_LOCAL_STORE_URL).objs;
    let mut obj = obj[(i - 1) as usize].clone();

    let ownership = sqlx::query!("select ownership from objs where obj_id = ?", i)
        .fetch_one(sql_executor)
        .await
        .unwrap()
        .ownership;

    obj.ownership = ownership.unwrap_or_default();

    let obj = Some(obj);
    Ok(GetDisplayObjectStatusResponse { obj })
}

#[cfg(test)]
mod tests {
    use super::simple_local_batch;
    use super::SIMPLE_LOCAL_STORE_URL;

    #[test]
    fn test_simple_local_batch() {
        assert!(!simple_local_batch(SIMPLE_LOCAL_STORE_URL).objs.is_empty())
    }
}
