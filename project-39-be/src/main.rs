use project_39_be::obj_store::{
    get_display_object_status, init_display_object_status, SIMPLE_LOCAL_STORE_URL,
};
use project_39_be::user;
use project_39_be::{
    obj_store::simple_local_batch,
    project_39_pb::{
        project39_service_server::{Project39Service, Project39ServiceServer},
        *,
    },
};
use sqlx::{sqlite::SqlitePoolOptions, Pool, Sqlite};
use tonic::{
    service::{self},
    transport::Server,
    Request, Response, Status,
};
use tonic_web::GrpcWebLayer;

const SERVER_ADDR: &str = "127.0.0.1:3250";
const SQLITE_URL: &str = "sqlite://../data/db/test_db.db";
const REDIS_URL: &str = "redis://127.0.0.1/";

fn grpc_web_interceptor(mut req: Request<()>) -> Result<Request<()>, Status> {
    req.metadata_mut().insert(
        "content-type",
        tonic::metadata::AsciiMetadataValue::from_static("application/grpc-web"),
    );
    Ok(req)
}

#[tokio::main]
async fn main() {
    env_logger::init();

    let miku_server = MikuServer::new().await;
    init_display_object_status(&miku_server.sqlite_pool).await;

    let miku_server = Project39ServiceServer::new(miku_server);

    log::info!("Server will start listening at `{SERVER_ADDR}`");

    Server::builder()
        .accept_http1(true)
        .layer(GrpcWebLayer::new())
        .layer(service::interceptor(grpc_web_interceptor))
        .add_service(tonic_web::enable(miku_server))
        .serve(SERVER_ADDR.parse().unwrap())
        .await
        .unwrap();

    log::info!("server shutdown")
}

type GrpcResult<T> = std::result::Result<Response<T>, Status>;

struct MikuServer {
    sqlite_pool: Pool<Sqlite>,
    redis_client: redis::Client,
}

impl MikuServer {
    async fn new() -> Self {
        log::info!("try connect to sqlite: `{SQLITE_URL}`");
        let sqlite_pool = SqlitePoolOptions::new()
            .max_connections(1)
            .connect(SQLITE_URL)
            .await
            .unwrap();

        log::info!("try connect to redis: `{REDIS_URL}`");
        let redis_client = redis::Client::open(REDIS_URL).unwrap();

        Self {
            sqlite_pool,
            redis_client,
        }
    }
}

#[tonic::async_trait]
impl Project39Service for MikuServer {
    async fn get_user_info(
        &self,
        request: Request<GetUserInfoRequest>,
    ) -> GrpcResult<GetUserInfoResponse> {
        user::get_user_info(&self.sqlite_pool, request.into_inner().user_id)
            .await
            .map_err(|err| Status::aborted(err.to_string()))
            .map(Response::new)
    }
    async fn put_user_info(
        &self,
        request: Request<PutUserInfoRequest>,
    ) -> GrpcResult<PutUserInfoResponse> {
        let request = request.into_inner();
        let user_name: String = request.user_name;
        let user_email: String = request.user_email;
        let profile_picture_bin = request.profile_picture_bin;
        let profile_picture_bin = if profile_picture_bin.is_empty() {
            None
        } else {
            Some(profile_picture_bin)
        };
        let password: String = request.password;

        user::put_user_info(
            &self.sqlite_pool,
            user_name,
            user_email,
            profile_picture_bin,
            password,
        )
        .await
        .map_err(|err| Status::aborted(err.to_string()))
        .map(Response::new)
    }
    async fn del_user_info(
        &self,
        _request: Request<DelUserInfoRequest>,
    ) -> GrpcResult<DelUserInfoResponse> {
        todo!()
    }

    async fn log_in(&self, request: Request<LogInRequest>) -> GrpcResult<LogInResponse> {
        let LogInRequest { user_id, password } = request.into_inner();

        user::log_in(
            &self.sqlite_pool,
            &mut self.redis_client.get_connection().unwrap(),
            user_id,
            password,
        )
        .await
        .map_err(|err| Status::aborted(err.to_string()))
        .map(Response::new)
    }
    async fn log_out(&self, request: Request<LogOutRequest>) -> GrpcResult<LogOutResponse> {
        todo!()
    }

    async fn get_display_object_batch(
        &self,
        _request: Request<GetDisplayObjectBatchRequest>,
    ) -> GrpcResult<GetDisplayObjectBatchResponse> {
        Ok(Response::new(simple_local_batch(SIMPLE_LOCAL_STORE_URL)))
    }
    async fn put_display_object_batch(
        &self,
        request: Request<PutDisplayObjectBatchRequest>,
    ) -> GrpcResult<PutDisplayObjectBatchResponse> {
        todo!()
    }
    async fn del_display_object(
        &self,
        request: Request<DelDisplayObjectRequest>,
    ) -> GrpcResult<DelDisplayObjectResponse> {
        todo!()
    }

    async fn get_display_object_status(
        &self,
        request: Request<GetDisplayObjectStatusRequest>,
    ) -> GrpcResult<GetDisplayObjectStatusResponse> {
        get_display_object_status(&self.sqlite_pool, request.into_inner().obj_id)
            .await
            .map_err(|err| Status::aborted(err.to_string()))
            .map(Response::new)
    }
    async fn put_display_object_status(
        &self,
        request: Request<PutDisplayObjectStatusRequest>,
    ) -> GrpcResult<PutDisplayObjectStatusResponse> {
        todo!()
    }
}
