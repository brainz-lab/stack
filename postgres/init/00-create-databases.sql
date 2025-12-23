-- Create databases for each service
-- TimescaleDB extension is enabled on each database

CREATE DATABASE recall;
CREATE DATABASE reflex;
CREATE DATABASE pulse;

-- Enable TimescaleDB extension on each database
\c recall
CREATE EXTENSION IF NOT EXISTS timescaledb;

\c reflex
CREATE EXTENSION IF NOT EXISTS timescaledb;

\c pulse
CREATE EXTENSION IF NOT EXISTS timescaledb;
