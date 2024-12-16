CREATE TABLE `winter_cars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `hash` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `stock` int(255) NOT NULL DEFAULT 0,
  `price` int(255) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;