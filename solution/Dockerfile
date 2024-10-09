FROM postgres:14-alpine

ENV POSTGRES_DB=climate_db
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres

RUN mkdir -p /app
WORKDIR /app
COPY query_script.py /app/query_script.py
COPY DailyDelhiClimateTrain.csv /docker-entrypoint-initdb.d/DailyDelhiClimateTrain.csv
COPY init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 5432

CMD ["python3", "/app/query_script.py"]
