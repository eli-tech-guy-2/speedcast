import psycopg2
import pandas as pd
import matplotlib.pyplot as plt

# Database 
conn = psycopg2.connect(
    dbname="postgres",
    user="postgres",
    password="postgres",
    host="postgres_container"
)

cur = conn.cursor()


create_table_query = """
CREATE TABLE IF NOT EXISTS delhi_climate (
    date DATE PRIMARY KEY,
    meantemp FLOAT,
    humidity FLOAT,
    wind_speed FLOAT,
    meanpressure FLOAT
);
"""
cur.execute(create_table_query)


copy_csv_query = """
COPY delhi_climate (date, meantemp, humidity, wind_speed, meanpressure)
FROM '/docker-entrypoint-initdb.d/DailyDelhiClimateTrain.csv'
DELIMITER ',' CSV HEADER;

-- Handle duplicate rows by ignoring conflicts on the primary key (date)
"""
try:
    cur.execute(copy_csv_query)
except psycopg2.errors.UniqueViolation:
    conn.rollback()  # Rollback in case of unique constraint violation

conn.commit()

query = """
SELECT 
    EXTRACT(YEAR FROM date) as year,
    MIN(humidity) as min_humidity,
    MAX(humidity) as max_humidity
FROM 
    delhi_climate
GROUP BY 
    EXTRACT(YEAR FROM date);
"""
cur.execute(query)

# pd data frame
rows = cur.fetchall()
df = pd.DataFrame(rows, columns=['year', 'min_humidity', 'max_humidity'])


print(df)

df.to_csv('/app/humidity_analysis.csv', index=False)


plt.figure(figsize=(10, 6))
plt.plot(df['year'], df['min_humidity'], label='Min Humidity', marker='o')
plt.plot(df['year'], df['max_humidity'], label='Max Humidity', marker='o')

plt.title('Min and Max Humidity per Year')
plt.xlabel('Year')
plt.ylabel('Humidity')
plt.legend()
plt.grid(True)


plt.savefig('/app/humidity_plot.png')
plt.show()


cur.close()
conn.close()
