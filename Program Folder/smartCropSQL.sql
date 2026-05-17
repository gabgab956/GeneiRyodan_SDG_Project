USE agri_dss;

-- This removes the 14 mismatched records and resets the ID count
TRUNCATE TABLE daily_records;

-- This inserts the 22 records to match your database.txt perfectly
INSERT INTO daily_records (temperature, rainfall_mm, daily_gdd) VALUES 
(31.5, 0.0, 21.5), (32.0, 5.0, 22.0), (33.5, 0.0, 23.5), 
(34.0, 12.5, 24.0), (30.0, 45.0, 20.0), (29.5, 20.0, 19.5), 
(31.0, 0.0, 21.0), (32.5, 0.0, 22.5), (33.0, 2.5, 23.0), 
(34.5, 0.0, 24.5), (35.0, 0.0, 25.0), (35.5, 0.0, 25.5), 
(34.0, 10.0, 24.0), (31.5, 30.5, 21.5), (30.5, 15.0, 20.5), 
(32.0, 0.0, 22.0), (33.5, 0.0, 23.5), (34.0, 0.0, 24.0), 
(35.0, 5.5, 25.0), (33.0, 18.0, 23.0), (31.0, 22.5, 21.0), 
(32.5, 0.0, 22.5);