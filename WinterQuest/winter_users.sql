CREATE TABLE `winter_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'Standard',
  `dailyGift` int(11) NOT NULL DEFAULT 0,
  `candy` int(255) NOT NULL DEFAULT 0,
  `bmwm5touring` int(11) NOT NULL DEFAULT 0,
  `mkcdodgeb` int(11) NOT NULL DEFAULT 0,
  `ugcthdeer` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;