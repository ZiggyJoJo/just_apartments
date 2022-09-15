-- Dumping structure for table es_extended.apartments
CREATE TABLE IF NOT EXISTS `apartments` (
  `Name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `Price` int(11) DEFAULT 5000,
  `rentLength` int(11) DEFAULT 30
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping data for table es_extended.apartments: ~6 rows (approximately)
/*!40000 ALTER TABLE `apartments` DISABLE KEYS */;
INSERT INTO `apartments` (`Name`, `Price`, `rentLength`) VALUES
	('4IntegrityWay', 5000, 30),
	('DelPerroHeights', 5000, 30),
	('EclipseTowers', 7500, 30),
	('RichardsMajestic', 5000, 30),
	('TinselTowers', 5000, 30),
	('WeazelPlazaApartments', 5000, 30);
/*!40000 ALTER TABLE `apartments` ENABLE KEYS */;

-- Dumping structure for table es_extended.apartment_keys
CREATE TABLE IF NOT EXISTS `apartment_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `appt_id` int(11) NOT NULL DEFAULT 0,
  `appt_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `player` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `player_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `appt_owner` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Dumping structure for table es_extended.owned_apartments
CREATE TABLE IF NOT EXISTS `owned_apartments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(46) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `apartment` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `renew` tinyint(4) NOT NULL DEFAULT 1,
  `expired` tinyint(4) NOT NULL DEFAULT 0,
  `lastPayment` int(11) DEFAULT NULL,
  `renewDate` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `users`
	ADD `last_property` varchar(50) DEFAULT NULL,
;
