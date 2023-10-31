pub mod obj_store;
pub mod token;
pub mod user;
mod utils;

pub mod project_39_pb {
    tonic::include_proto!("project_39.v1");
}

#[cfg(test)]
mod test_utils {
    use sqlx::sqlite::SqlitePoolOptions;

    const SQLITE_URL: &str = "sqlite://../data/db/test_db.db";
    const REDIS_URL: &str = "redis://127.0.0.1/";

    pub(crate) async fn new_test_sqlite_connection() -> sqlx::Pool<sqlx::Sqlite> {
        SqlitePoolOptions::new()
            .max_connections(1)
            .connect(SQLITE_URL)
            .await
            .unwrap()
    }

    pub(crate) fn new_test_redis_client() -> redis::Client {
        redis::Client::open(REDIS_URL).unwrap()
    }
}
