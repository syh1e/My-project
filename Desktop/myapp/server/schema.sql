CREATE TABLE IF NOT EXISTS attendance_verification (
    id SERIAL PRIMARY KEY,
    study_id INTEGER REFERENCES studies(id),
    code VARCHAR(4) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS attendance (
    id SERIAL PRIMARY KEY,
    study_id INTEGER REFERENCES studies(id),
    user_id VARCHAR(50) REFERENCES users(id),
    status VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    attendance_verification_id INTEGER REFERENCES attendance_verification(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 