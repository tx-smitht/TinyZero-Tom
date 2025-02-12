create database tinyzero;
create or replace schema experiment;
use database tinyzero;
use schema experiment;
grant usage on database tinyzero to role sysadmin;
grant usage on schema experiment to role sysadmin;
grant all privileges on schema experiment to role sysadmin;
grant all privileges on stage tinyzero_stage to role sysadmin;
grant read on image repository tinyzero_image_repo to role sysadmin;
grant write on image repository tinyzero_image_repo to role sysadmin;

CREATE STAGE tinyzero_stage;

-- Run snowsql then PUT file://C:\model_files\* @tinyzero_stage/models/Qwen2.5-3b AUTO_COMPRESS=FALSE;

GRANT BIND SERVICE ENDPOINT ON ACCOUNT TO ROLE accountadmin;

CREATE IMAGE REPOSITORY IF NOT EXISTS tinyzero_image_repo;

SHOW IMAGE REPOSITORIES;

-- Execute the command below
-- docker build --rm --platform linux/amd64 -t szgqdbu-bhb45377.registry.snowflakecomputing.com/tinyzero/experiment/tinyzero_image_repo/tinyzero_image:latest .

-- Authenticate with docker: using creds in user/.snowflake/connections.toml
-- snow spcs image-registry login

-- Push the image to the Snowflake container registry
-- docker push szgqdbu-bhb45377.registry.snowflakecomputing.com/tinyzero/experiment/tinyzero_image_repo/tinyzero_image:latest
drop compute pool tinyzero_compute_pool;
CREATE COMPUTE POOL tinyzero_compute_pool
  MIN_NODES = 2
  MAX_NODES = 2
  INSTANCE_FAMILY = GPU_NV_M
  initially_suspended=true;
GRANT USAGE, MONITOR, modify ON COMPUTE POOL tinyzero_compute_pool TO ROLE sysadmin;
describe compute pool tinyzero_compute_pool;
use role accountadmin;
alter compute pool tinyzero_compute_pool suspend;
alter compute pool tinyzero_compute_pool resume;


-- Put service spec into stage with the following command
-- snowsql then PUT 'file://C:/Users/txsmi/Documents/Local Programming/Snowflake/spcs/TinyZero/service_spec.yaml' @tinyzero_stage AUTO_COMPRESS=FALSE OVERWRITE=TRUE;
-- Link to put command considerations: https://docs.snowflake.com/en/sql-reference/sql/put

use role sysadmin;

create service tinyzero_training_service
IN COMPUTE POOL tinyzero_compute_pool
FROM @tinyzero_stage
SPEC='service_spec.yaml';
drop service tinyzero_training_service;

describe service tinyzero_training_service;
SELECT SYSTEM$GET_SERVICE_LOGS('tinyzero_training_service', '0', 'training-container', 1000);