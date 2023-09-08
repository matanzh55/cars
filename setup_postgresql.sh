#!/bin/bash

# Install PostgreSQL
sudo apt-get update
sudo apt-get install -y postgresql

# Start PostgreSQL service and wait for it to initialize
sudo service postgresql start
sleep 5

# Log in to the PostgreSQL server as the default superuser and create the database
sudo -u postgres psql -c "CREATE DATABASE cars;"

# Connect to the 'cars' database and create the 'cars' table
sudo -u postgres psql -d cars -c "CREATE TABLE cars (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(255) NOT NULL,
    car_number INTEGER NOT NULL,
    manufacturing_date TIMESTAMP NOT NULL
);"

# Create a user for your Flask application
sudo -u postgres psql -c "CREATE USER matanzh WITH PASSWORD 'matanzh';"

# Grant privileges to the user on the 'cars' database
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE library TO matanzh;"

# Grant privileges on the 'cars' table to the user
sudo -u postgres psql -d cars -c "GRANT ALL PRIVILEGES ON TABLE books TO matanzh;"

echo "listen_addresses = '*'" | sudo tee -a /etc/postgresql/*/main/postgresql.conf

echo "host   all    all    "10.0.1.0/24"     md5" | sudo tee -a /etc/postgresql/*/main/pg_hba.conf

sudo service postgresql restart


