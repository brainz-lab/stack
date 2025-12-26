-- Create databases for each service
-- TimescaleDB extension is enabled on each database

CREATE DATABASE recall;
CREATE DATABASE reflex;
CREATE DATABASE pulse;
CREATE DATABASE flux;
CREATE DATABASE signal;
CREATE DATABASE vault;
CREATE DATABASE beacon;
CREATE DATABASE vision;
CREATE DATABASE sentinel;

-- Enable extensions on each database
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
