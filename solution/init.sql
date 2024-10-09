CREATE TABLE delhi_climate (
    date DATE PRIMARY KEY,
    meantemp FLOAT,
    humidity FLOAT,
    wind_speed FLOAT,
    meanpressure FLOAT
);
-- Load CSV 
COPY delhi_climate (date, meantemp, humidity, wind_speed, meanpressure)
FROM '/docker-entrypoint-initdb.d/DailyDelhiClimateTrain.csv'
DELIMITER ',' CSV HEADER;

