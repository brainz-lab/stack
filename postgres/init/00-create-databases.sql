-- Create primary databases for each service
CREATE DATABASE recall;
CREATE DATABASE reflex;
CREATE DATABASE pulse;
CREATE DATABASE flux;
CREATE DATABASE signal;
CREATE DATABASE vault;
CREATE DATABASE beacon;
CREATE DATABASE vision;
CREATE DATABASE sentinel;

-- Create queue, cache, cable databases for each service
-- Rails 8.x multi-database: Solid Queue, Solid Cache, Action Cable
CREATE DATABASE recall_queue;
CREATE DATABASE recall_cache;
CREATE DATABASE recall_cable;
CREATE DATABASE reflex_queue;
CREATE DATABASE reflex_cache;
CREATE DATABASE reflex_cable;
CREATE DATABASE pulse_queue;
CREATE DATABASE pulse_cache;
CREATE DATABASE pulse_cable;
CREATE DATABASE flux_queue;
CREATE DATABASE flux_cache;
CREATE DATABASE flux_cable;
CREATE DATABASE signal_queue;
CREATE DATABASE signal_cache;
CREATE DATABASE signal_cable;
CREATE DATABASE vault_queue;
CREATE DATABASE vault_cache;
CREATE DATABASE vault_cable;
CREATE DATABASE beacon_queue;
CREATE DATABASE beacon_cache;
CREATE DATABASE beacon_cable;
CREATE DATABASE vision_queue;
CREATE DATABASE vision_cache;
CREATE DATABASE vision_cable;
CREATE DATABASE sentinel_queue;
CREATE DATABASE sentinel_cache;
CREATE DATABASE sentinel_cable;

-- Enable extensions on primary databases
\c recall
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c reflex
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c pulse
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c flux
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c signal
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c vault
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c beacon
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c vision
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

\c sentinel
CREATE EXTENSION IF NOT EXISTS timescaledb;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
