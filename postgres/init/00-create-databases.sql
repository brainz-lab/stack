-- Create databases for each service
CREATE DATABASE platform;
CREATE DATABASE recall;
CREATE DATABASE reflex;
CREATE DATABASE pulse;

-- Grant permissions (user is already created by POSTGRES_USER env var)
-- These grants happen automatically for the superuser
