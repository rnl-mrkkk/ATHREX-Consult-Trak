CREATE DATABASE IF NOT EXISTS consulttrak CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE consulttrak;

CREATE TABLE IF NOT EXISTS USER_ACCOUNT (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    role ENUM('Student','Faculty','Admin') NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    student_number VARCHAR(50) DEFAULT NULL,
    course VARCHAR(100) DEFAULT NULL,
    year_level INT DEFAULT NULL,
    employee_number VARCHAR(50) DEFAULT NULL,
    department VARCHAR(100) DEFAULT NULL,
    account_status ENUM('Active','Inactive','Suspended') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_role (role),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS AVAILABILITY (
    availability_id INT AUTO_INCREMENT PRIMARY KEY,
    faculty_id INT NOT NULL,
    day_of_week ENUM('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday') NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (faculty_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS CONSULTATION_REQUEST (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    faculty_id INT NOT NULL,
    subject VARCHAR(255) DEFAULT NULL,
    message TEXT DEFAULT NULL,
    status ENUM('Pending','Accepted','Rejected','Completed') DEFAULT 'Pending',
    request_date DATE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE,
    INDEX idx_student (student_id),
    INDEX idx_faculty (faculty_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS APPOINTMENT (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    student_id INT NOT NULL,
    faculty_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    status ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    notes TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES CONSULTATION_REQUEST(request_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS CONSULTATION_RECORD (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    faculty_id INT NOT NULL,
    request_id INT DEFAULT NULL,
    consultation_date DATE NOT NULL,
    recommendations TEXT DEFAULT NULL,
    notes TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE,
    FOREIGN KEY (faculty_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE,
    FOREIGN KEY (request_id) REFERENCES CONSULTATION_REQUEST(request_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS NOTIFICATION (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(500) NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USER_ACCOUNT(user_id) ON DELETE CASCADE,
    INDEX idx_user_read (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
