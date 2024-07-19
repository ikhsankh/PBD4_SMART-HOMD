-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 19 Jul 2024 pada 08.45
-- Versi server: 10.4.11-MariaDB
-- Versi PHP: 7.4.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smart_home`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetSensorValue` (`sensor_id` INT, `sensor_type` VARCHAR(50))  BEGIN
    DECLARE sensor_value DECIMAL(10,2);
    
    SELECT sensor_value INTO sensor_value
    FROM Sensors
    WHERE id = sensor_id AND sensor_type = sensor_type
    LIMIT 1;
    
    SELECT sensor_value;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ShowUserDevices` ()  BEGIN
    DECLARE user_count INT;
    SELECT COUNT(*) INTO user_count FROM Users;
    
    IF user_count > 1 THEN
        SELECT u.name AS User_Name, d.device_name AS Device_Name, d.device_type AS Device_Type
        FROM Users u
        JOIN Homes h ON u.id = h.user_id
        JOIN Devices d ON h.id = d.home_id;
    ELSE
        SELECT 'Jumlah pengguna kurang dari atau sama dengan 1. Tidak ada perangkat yang ditampilkan.' AS Message;
    END IF;
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CountUsers` () RETURNS INT(11) BEGIN
    DECLARE total_users INT;
    SELECT COUNT(*) INTO total_users FROM Users;
    RETURN total_users;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `GetUserHomeAddress` (`user_id` INT) RETURNS VARCHAR(255) CHARSET utf8mb4 BEGIN
    DECLARE home_address VARCHAR(255);
    
    SELECT MAX(address) INTO home_address FROM Homes WHERE user_id = user_id;
    
    RETURN home_address;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `devicelogs`
--

CREATE TABLE `devicelogs` (
  `log_id` int(11) NOT NULL,
  `device_id` int(11) DEFAULT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `action_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktur dari tabel `devices`
--

CREATE TABLE `devices` (
  `id` int(11) NOT NULL,
  `home_id` int(11) DEFAULT NULL,
  `device_name` varchar(100) DEFAULT NULL,
  `device_type` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `devices`
--

INSERT INTO `devices` (`id`, `home_id`, `device_name`, `device_type`) VALUES
(1, 1, 'Thermostat', 'Temperature Control'),
(2, 2, 'Smart Light', 'Lighting'),
(3, 3, 'Security Camera', 'Surveillance'),
(4, 4, 'Smart Lock', 'Security'),
(5, 5, 'Smoke Detector', 'Safety'),
(6, 1, 'SMART THERMOSTAT', 'Temperature Control');

--
-- Trigger `devices`
--
DELIMITER $$
CREATE TRIGGER `after_delete_device` AFTER DELETE ON `devices` FOR EACH ROW BEGIN
    INSERT INTO DeviceLogs (device_id, action_type, action_time)
    VALUES (OLD.id, 'DELETE', NOW());
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_device` BEFORE INSERT ON `devices` FOR EACH ROW BEGIN
    SET NEW.device_name = UPPER(NEW.device_name);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `homes`
--

CREATE TABLE `homes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `homes`
--

INSERT INTO `homes` (`id`, `user_id`, `address`) VALUES
(1, 1, '123 Main St'),
(2, 2, '456 elm street'),
(3, 3, '789 Oak St'),
(4, 4, '101 Pine St'),
(5, 5, '202 Maple St');

--
-- Trigger `homes`
--
DELIMITER $$
CREATE TRIGGER `before_update_home_address` BEFORE UPDATE ON `homes` FOR EACH ROW BEGIN
    SET NEW.address = CONCAT(UPPER(SUBSTRING(NEW.address, 1, 1)), LOWER(SUBSTRING(NEW.address, 2)));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `horizontalview`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `horizontalview` (
`User_Name` varchar(100)
,`Home_Address` varchar(255)
,`Device_Name` varchar(100)
,`Sensor_Type` varchar(100)
,`Sensor_Value` float
);

-- --------------------------------------------------------

--
-- Struktur dari tabel `sensordata`
--

CREATE TABLE `sensordata` (
  `id` int(11) NOT NULL,
  `device_id` int(11) DEFAULT NULL,
  `sensor_type` varchar(50) DEFAULT NULL,
  `sensor_value` float DEFAULT NULL,
  `reading_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sensorlogs`
--

CREATE TABLE `sensorlogs` (
  `log_id` int(11) NOT NULL,
  `sensor_id` int(11) DEFAULT NULL,
  `log_message` varchar(255) DEFAULT NULL,
  `log_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktur dari tabel `sensors`
--

CREATE TABLE `sensors` (
  `id` int(11) NOT NULL,
  `device_id` int(11) DEFAULT NULL,
  `sensor_type` varchar(100) DEFAULT NULL,
  `sensor_value` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `sensors`
--

INSERT INTO `sensors` (`id`, `device_id`, `sensor_type`, `sensor_value`) VALUES
(1, 1, 'Temperature', 22.5),
(2, 2, 'Brightness', 75),
(3, 3, 'Motion', 1),
(4, 4, 'Lock Status', 0);

--
-- Trigger `sensors`
--
DELIMITER $$
CREATE TRIGGER `before_delete_sensor` BEFORE DELETE ON `sensors` FOR EACH ROW BEGIN
    DECLARE log_message VARCHAR(255);
    
    SET log_message = CONCAT('Sensor dengan ID ', OLD.id, ' akan segera dihapus.');
    
    INSERT INTO SensorLogs (sensor_id, log_message)
    VALUES (OLD.id, log_message);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `underlyingtable`
--

CREATE TABLE `underlyingtable` (
  `Data_Type` varchar(50) DEFAULT NULL,
  `Data_ID` int(11) DEFAULT NULL,
  `Data_Value` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `underlyingtable`
--

INSERT INTO `underlyingtable` (`Data_Type`, `Data_ID`, `Data_Value`) VALUES
('User', 10, 'John Doe'),
('User', 10, 'John Doe');

-- --------------------------------------------------------

--
-- Struktur dari tabel `useractivities`
--

CREATE TABLE `useractivities` (
  `activity_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `activity_type` varchar(255) DEFAULT NULL,
  `activity_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `useractivities`
--

INSERT INTO `useractivities` (`activity_id`, `user_id`, `activity_type`, `activity_time`) VALUES
(1, 7, 'New user created', '2024-07-18 16:00:49');

-- --------------------------------------------------------

--
-- Struktur dari tabel `userdevices`
--

CREATE TABLE `userdevices` (
  `user_id` int(11) NOT NULL,
  `device_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `userdevices`
--

INSERT INTO `userdevices` (`user_id`, `device_id`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- --------------------------------------------------------

--
-- Struktur dari tabel `userlogs`
--

CREATE TABLE `userlogs` (
  `log_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `old_name` varchar(255) DEFAULT NULL,
  `new_name` varchar(255) DEFAULT NULL,
  `change_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`) VALUES
(1, 'Alice', 'alice@example.com', 'password1'),
(2, 'Bob', 'bob@example.com', 'password2'),
(3, 'Charlie', 'charlie@example.com', 'password3'),
(4, 'David', 'david@example.com', 'password4'),
(5, 'Eva', 'eva@example.com', 'password5'),
(7, 'Frank', 'frank@example.com', 'password6');

--
-- Trigger `users`
--
DELIMITER $$
CREATE TRIGGER `after_insert_user` AFTER INSERT ON `users` FOR EACH ROW BEGIN
    INSERT INTO UserActivities (user_id, activity_type)
    VALUES (NEW.id, 'New user created');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_user_name` AFTER UPDATE ON `users` FOR EACH ROW BEGIN
    IF OLD.name <> NEW.name THEN
        INSERT INTO UserLogs (user_id, old_name, new_name, change_time)
        VALUES (NEW.id, OLD.name, NEW.name, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `verticalview`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `verticalview` (
`Data_Type` varchar(50)
,`Data_ID` int(11)
,`Data_Value` varchar(255)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `viewinsideview`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `viewinsideview` (
`User_ID` int(11)
,`Device_ID` int(11)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `horizontalview`
--
DROP TABLE IF EXISTS `horizontalview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontalview`  AS  select `u`.`name` AS `User_Name`,`h`.`address` AS `Home_Address`,`d`.`device_name` AS `Device_Name`,`s`.`sensor_type` AS `Sensor_Type`,`s`.`sensor_value` AS `Sensor_Value` from (((`users` `u` join `homes` `h` on(`u`.`id` = `h`.`user_id`)) join `devices` `d` on(`h`.`id` = `d`.`home_id`)) join `sensors` `s` on(`d`.`id` = `s`.`device_id`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `verticalview`
--
DROP TABLE IF EXISTS `verticalview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `verticalview`  AS  select `underlyingtable`.`Data_Type` AS `Data_Type`,`underlyingtable`.`Data_ID` AS `Data_ID`,`underlyingtable`.`Data_Value` AS `Data_Value` from `underlyingtable` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `viewinsideview`
--
DROP TABLE IF EXISTS `viewinsideview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `viewinsideview`  AS  with recursive UserDevicesRec as (select `u`.`id` AS `User_ID`,`d`.`id` AS `Device_ID` from ((`users` `u` join `userdevices` `ud` on(`u`.`id` = `ud`.`user_id`)) join `devices` `d` on(`ud`.`device_id` = `d`.`id`)) union all select `u`.`id` AS `id`,`d`.`id` AS `id` from (((`users` `u` join `userdevices` `ud` on(`u`.`id` = `ud`.`user_id`)) join `devices` `d` on(`ud`.`device_id` = `d`.`id`)) join `userdevicesrec` `udr` on(`udr`.`User_ID` = `u`.`id`)))select `userdevicesrec`.`User_ID` AS `User_ID`,`userdevicesrec`.`Device_ID` AS `Device_ID` from `userdevicesrec` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `devicelogs`
--
ALTER TABLE `devicelogs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `device_id` (`device_id`);

--
-- Indeks untuk tabel `devices`
--
ALTER TABLE `devices`
  ADD PRIMARY KEY (`id`),
  ADD KEY `home_id` (`home_id`);

--
-- Indeks untuk tabel `homes`
--
ALTER TABLE `homes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `sensordata`
--
ALTER TABLE `sensordata`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_device_sensor` (`device_id`,`sensor_type`);

--
-- Indeks untuk tabel `sensorlogs`
--
ALTER TABLE `sensorlogs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `sensorlogs_ibfk_1` (`sensor_id`);

--
-- Indeks untuk tabel `sensors`
--
ALTER TABLE `sensors`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sensors_ibfk_1` (`device_id`);

--
-- Indeks untuk tabel `useractivities`
--
ALTER TABLE `useractivities`
  ADD PRIMARY KEY (`activity_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `userdevices`
--
ALTER TABLE `userdevices`
  ADD PRIMARY KEY (`user_id`,`device_id`),
  ADD KEY `idx_device_user` (`device_id`,`user_id`);

--
-- Indeks untuk tabel `userlogs`
--
ALTER TABLE `userlogs`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `idx_user_change_time` (`user_id`,`change_time`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `devicelogs`
--
ALTER TABLE `devicelogs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `devices`
--
ALTER TABLE `devices`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `homes`
--
ALTER TABLE `homes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `sensordata`
--
ALTER TABLE `sensordata`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `sensorlogs`
--
ALTER TABLE `sensorlogs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `sensors`
--
ALTER TABLE `sensors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `useractivities`
--
ALTER TABLE `useractivities`
  MODIFY `activity_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `userlogs`
--
ALTER TABLE `userlogs`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `devicelogs`
--
ALTER TABLE `devicelogs`
  ADD CONSTRAINT `devicelogs_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`);

--
-- Ketidakleluasaan untuk tabel `devices`
--
ALTER TABLE `devices`
  ADD CONSTRAINT `devices_ibfk_1` FOREIGN KEY (`home_id`) REFERENCES `homes` (`id`);

--
-- Ketidakleluasaan untuk tabel `homes`
--
ALTER TABLE `homes`
  ADD CONSTRAINT `homes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `sensorlogs`
--
ALTER TABLE `sensorlogs`
  ADD CONSTRAINT `sensorlogs_ibfk_1` FOREIGN KEY (`sensor_id`) REFERENCES `sensors` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `sensors`
--
ALTER TABLE `sensors`
  ADD CONSTRAINT `sensors_ibfk_1` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `useractivities`
--
ALTER TABLE `useractivities`
  ADD CONSTRAINT `useractivities_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Ketidakleluasaan untuk tabel `userdevices`
--
ALTER TABLE `userdevices`
  ADD CONSTRAINT `userdevices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `userdevices_ibfk_2` FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`);

--
-- Ketidakleluasaan untuk tabel `userlogs`
--
ALTER TABLE `userlogs`
  ADD CONSTRAINT `userlogs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
