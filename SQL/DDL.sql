
DROP DATABASE IF EXISTS airport_management;
CREATE DATABASE airport_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE airport_management;

CREATE TABLE PlaneModel (
    model_id        INT             AUTO_INCREMENT,
    model_name      VARCHAR(100)    NOT NULL,
    manufacturer    VARCHAR(100)    NOT NULL,
    category        VARCHAR(50)     NOT NULL,
    max_range_km    INT             NOT NULL CHECK (max_range_km > 0),
    engine_type     VARCHAR(50)     NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_planemodel PRIMARY KEY (model_id),
    CONSTRAINT uq_planemodel_name UNIQUE (manufacturer, model_name)
);

CREATE TABLE Airplane (
    plane_no            VARCHAR(20)     NOT NULL,
    model_id            INT             NOT NULL,
    capacity            INT             NOT NULL CHECK (capacity > 0),
    year_manufactured   YEAR            NOT NULL,
    status              ENUM('Active','Maintenance','Retired','Grounded')
                                        NOT NULL DEFAULT 'Active',
    last_service_date   DATE,
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_airplane PRIMARY KEY (plane_no),
    CONSTRAINT fk_airplane_model FOREIGN KEY (model_id)
        REFERENCES PlaneModel(model_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Hangar (
    hangar_no       VARCHAR(10)     NOT NULL,
    location        VARCHAR(200)    NOT NULL,
    capacity        INT             NOT NULL CHECK (capacity > 0),
    hangar_type     ENUM('Maintenance','Storage','Both')
                                    NOT NULL DEFAULT 'Both',
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    CONSTRAINT pk_hangar PRIMARY KEY (hangar_no)
);

CREATE TABLE HangarStay (
    stay_id         INT             AUTO_INCREMENT,
    plane_no        VARCHAR(20)     NOT NULL,
    hangar_no       VARCHAR(10)     NOT NULL,
    in_datetime     DATETIME        NOT NULL,
    out_datetime    DATETIME        NULL,
    notes           TEXT,
    CONSTRAINT pk_hangarstay PRIMARY KEY (stay_id),
    CONSTRAINT fk_stay_plane FOREIGN KEY (plane_no)
        REFERENCES Airplane(plane_no)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_stay_hangar FOREIGN KEY (hangar_no)
        REFERENCES Hangar(hangar_no)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_stay_dates CHECK (
        out_datetime IS NULL OR out_datetime > in_datetime
    )
);

CREATE TABLE Test (
    test_id         INT             AUTO_INCREMENT,
    test_name       VARCHAR(100)    NOT NULL,
    description     TEXT,
    max_score       DECIMAL(5,2)    NOT NULL CHECK (max_score > 0),
    pass_threshold  DECIMAL(5,2)    NOT NULL,
    frequency_days  INT             NOT NULL,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_test PRIMARY KEY (test_id),
    CONSTRAINT uq_test_name UNIQUE (test_name),
    CONSTRAINT chk_threshold CHECK (pass_threshold <= max_score AND pass_threshold >= 0)
);

CREATE TABLE UnionInfo (
    union_id        INT             AUTO_INCREMENT,
    union_name      VARCHAR(150)    NOT NULL,
    union_code      VARCHAR(20)     NOT NULL,
    contact_email   VARCHAR(150),
    CONSTRAINT pk_union PRIMARY KEY (union_id),
    CONSTRAINT uq_union_code UNIQUE (union_code)
);

CREATE TABLE Employee (
    ssn                 CHAR(11)        NOT NULL,
    full_name           VARCHAR(150)    NOT NULL,
    union_membership_no VARCHAR(30)     NOT NULL,
    union_id            INT             NOT NULL,
    phone               VARCHAR(20),
    email               VARCHAR(150),
    hire_date           DATE            NOT NULL,
    salary              DECIMAL(10,2)   NOT NULL CHECK (salary >= 0),
    department          VARCHAR(100),
    created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_employee PRIMARY KEY (ssn),
    CONSTRAINT uq_employee_union UNIQUE (union_membership_no),
    CONSTRAINT uq_employee_email UNIQUE (email),
    CONSTRAINT fk_employee_union FOREIGN KEY (union_id)
        REFERENCES UnionInfo(union_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_ssn_format CHECK (ssn REGEXP '^[0-9]{3}-[0-9]{2}-[0-9]{4}$')
);

CREATE TABLE Technician (
    ssn             CHAR(11)        NOT NULL,
    certification   VARCHAR(100),
    cert_expiry     DATE,
    specialty_note  VARCHAR(255),
    CONSTRAINT pk_technician PRIMARY KEY (ssn),
    CONSTRAINT fk_technician_employee FOREIGN KEY (ssn)
        REFERENCES Employee(ssn)
        ON UPDATE CASCADE ON DELETE CASCADE
);


CREATE TABLE TechnicianExpertise (
    ssn             CHAR(11)        NOT NULL,
    model_id        INT             NOT NULL,
    proficiency     ENUM('Junior','Senior','Lead') NOT NULL DEFAULT 'Junior',
    certified_date  DATE,
    CONSTRAINT pk_techexpertise PRIMARY KEY (ssn, model_id),
    CONSTRAINT fk_expertise_tech FOREIGN KEY (ssn)
        REFERENCES Technician(ssn)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_expertise_model FOREIGN KEY (model_id)
        REFERENCES PlaneModel(model_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TrafficController (
    ssn                 CHAR(11)        NOT NULL,
    last_medical_exam   DATE            NOT NULL,
    license_no          VARCHAR(50)     NOT NULL,
    license_expiry      DATE            NOT NULL,
    tower_assignment    VARCHAR(50),
    CONSTRAINT pk_trafficcontroller PRIMARY KEY (ssn),
    CONSTRAINT uq_tc_license UNIQUE (license_no),
    CONSTRAINT fk_tc_employee FOREIGN KEY (ssn)
        REFERENCES Employee(ssn)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TestEvent (
    event_id        INT             AUTO_INCREMENT,
    plane_no        VARCHAR(20)     NOT NULL,
    ssn             CHAR(11)        NOT NULL,
    test_id         INT             NOT NULL,
    event_date      DATE            NOT NULL,
    hours_spent     DECIMAL(5,2)    NOT NULL CHECK (hours_spent > 0),
    score           DECIMAL(5,2)    NOT NULL CHECK (score >= 0),
    passed          TINYINT(1)      NOT NULL DEFAULT 0,
    remarks         TEXT,
    created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_testevent PRIMARY KEY (event_id),
    CONSTRAINT fk_event_plane FOREIGN KEY (plane_no)
        REFERENCES Airplane(plane_no)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_event_tech FOREIGN KEY (ssn)
        REFERENCES Technician(ssn)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_event_test FOREIGN KEY (test_id)
        REFERENCES Test(test_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Flight (
    flight_id       INT             AUTO_INCREMENT,
    flight_no       VARCHAR(10)     NOT NULL,
    plane_no        VARCHAR(20)     NOT NULL,
    origin          VARCHAR(100)    NOT NULL,
    destination     VARCHAR(100)    NOT NULL,
    scheduled_dep   DATETIME        NOT NULL,
    scheduled_arr   DATETIME        NOT NULL,
    actual_dep      DATETIME,
    actual_arr      DATETIME,
    status          ENUM('Scheduled','Boarding','Departed','Arrived','Cancelled','Delayed')
                                    NOT NULL DEFAULT 'Scheduled',
    CONSTRAINT pk_flight PRIMARY KEY (flight_id),
    CONSTRAINT uq_flight_no_dep UNIQUE (flight_no, scheduled_dep),
    CONSTRAINT fk_flight_plane FOREIGN KEY (plane_no)
        REFERENCES Airplane(plane_no)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_flight_times CHECK (scheduled_arr > scheduled_dep)
);

CREATE INDEX idx_airplane_model     ON Airplane(model_id);
CREATE INDEX idx_airplane_status    ON Airplane(status);
CREATE INDEX idx_hangarstay_plane   ON HangarStay(plane_no);
CREATE INDEX idx_hangarstay_hangar  ON HangarStay(hangar_no);
CREATE INDEX idx_hangarstay_in      ON HangarStay(in_datetime);
CREATE INDEX idx_testevent_plane    ON TestEvent(plane_no);
CREATE INDEX idx_testevent_tech     ON TestEvent(ssn);
CREATE INDEX idx_testevent_date     ON TestEvent(event_date);
CREATE INDEX idx_employee_name      ON Employee(full_name);
CREATE INDEX idx_tc_exam            ON TrafficController(last_medical_exam);
CREATE INDEX idx_flight_dep         ON Flight(scheduled_dep);
CREATE INDEX idx_flight_plane       ON Flight(plane_no);
