use std::io;

use redis::Commands;

fn set_token(conn: &mut redis::Connection, user_id: i64, token: String) -> anyhow::Result<()> {
    conn.set(token, user_id)?;
    Ok(())
}

pub(crate) fn new_token(conn: &mut redis::Connection, user_id: i64) -> anyhow::Result<String> {
    let token = uuid::Uuid::new_v4().to_string();
    set_token(conn, user_id, token.clone())?;
    Ok(token)
}

fn get_user_id(conn: &mut redis::Connection, token: String) -> Result<i64, tonic::Status> {
    let ret: i64 = conn
        .get(token)
        .map_err(|err| tonic::Status::aborted(err.to_string()))?;
    Ok(ret)
}
pub fn verify_token(
    conn: &redis::Client,
    token: String,
    user_id: i64,
) -> Result<(), tonic::Status> {
    let ret_user_id = get_user_id(&mut conn.get_connection().unwrap(), token)?;
    if ret_user_id == user_id {
        Ok(())
    } else {
        let err = io::Error::new(std::io::ErrorKind::PermissionDenied, "invalid token");
        Err(err.into())
    }
}
