-- phpMyAdmin SQL Dump
-- version 4.8.5
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Apr 07, 2019 at 08:29 PM
-- Server version: 10.1.38-MariaDB-0ubuntu0.18.04.1
-- PHP Version: 7.2.15-0ubuntu0.18.04.2

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `imta_server`
--

-- Table structure for table `imta_organisation`
--

CREATE TABLE `imta_organisation` (
  `id` mediumint(7) UNSIGNED NOT NULL,
  `org_type` enum('default','business','organisation','project') COLLATE utf8_unicode_ci NOT NULL DEFAULT 'default',
  `name` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `icon_id` tinyint(3) UNSIGNED NOT NULL,
  `max_pay` smallint(5) UNSIGNED NOT NULL COMMENT 'per hour',
  `max_pay_daily` int(11) UNSIGNED NOT NULL COMMENT '--salary limit for org per day',
  `member_limit` mediumint(8) UNSIGNED NOT NULL DEFAULT '0',
  `leader_id` int(11) UNSIGNED NOT NULL,
  `money` int(11) NOT NULL DEFAULT '0' COMMENT 'in bank account',
  `leader_note` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `color` varchar(16) COLLATE utf8_unicode_ci NOT NULL,
  `magazine` mediumtext COLLATE utf8_unicode_ci,
  `robbing` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imta_organisation_groups`
--

CREATE TABLE `imta_organisation_groups` (
  `id` int(11) UNSIGNED NOT NULL,
  `organisation_id` mediumint(7) UNSIGNED NOT NULL,
  `internal_id` tinyint(3) NOT NULL COMMENT '1-8, 9 is leader',
  `skin_id` smallint(5) UNSIGNED DEFAULT NULL,
  `payout` mediumint(7) NOT NULL DEFAULT '0' COMMENT 'per hour',
  `name` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'brak'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imta_organisation_group_members`
--

CREATE TABLE `imta_organisation_group_members` (
  `char_id` int(11) NOT NULL,
  `group_id` int(11) UNSIGNED NOT NULL,
  `skin_id` smallint(5) UNSIGNED DEFAULT NULL,
  `payout` mediumint(7) NOT NULL DEFAULT '-1' COMMENT '-1 = use group value',
  `join_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `use_individual_rights` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imta_organisation_member_playtime`
--

CREATE TABLE `imta_organisation_member_playtime` (
  `char_id` int(11) NOT NULL,
  `org_id` int(4) NOT NULL,
  `playtime` smallint(3) NOT NULL DEFAULT '0',
  `payment_run` tinyint(1) NOT NULL DEFAULT '0',
  `start_time` date NOT NULL,
  `payment_size` int(11) NOT NULL DEFAULT '0',
  `org_multiplier` float NOT NULL DEFAULT '0',
  `payment_base` mediumint(9) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imta_organisation_permissions`
--

CREATE TABLE `imta_organisation_permissions` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `namePL` varchar(128) COLLATE utf8_unicode_ci NOT NULL,
  `category` set('basic','law_enforcment','criminal','business') COLLATE utf8_unicode_ci NOT NULL,
  `is_economic` tinyint(3) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imta_organisation_permission_list`
--

CREATE TABLE `imta_organisation_permission_list` (
  `id` bigint(11) UNSIGNED NOT NULL,
  `permission_id` bigint(12) UNSIGNED NOT NULL,
  `type` set('faction','group','player','') COLLATE utf8_unicode_ci NOT NULL,
  `margin` smallint(5) UNSIGNED DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `imta_organisation_permisson_categories`
--

CREATE TABLE `imta_organisation_permisson_categories` (
  `category` set('basic','law_enforcment','criminal','business') COLLATE utf8_unicode_ci NOT NULL,
  `rank` tinyint(3) NOT NULL,
  `categoryNamePL` varchar(64) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

--
-- Table structure for table `imta_weapons_indices`
--

CREATE TABLE `imta_weapons_indices` (
  `weapon_id` int(11) NOT NULL,
  `current_id` int(10) UNSIGNED NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Indexes for table `imta_organisation`
--
ALTER TABLE `imta_organisation`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `imta_organisation_groups`
--
ALTER TABLE `imta_organisation_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`);

--
-- Indexes for table `imta_organisation_group_members`
--
ALTER TABLE `imta_organisation_group_members`
  ADD UNIQUE KEY `char_id` (`char_id`,`group_id`) USING BTREE;

--
-- Indexes for table `imta_organisation_member_playtime`
--
ALTER TABLE `imta_organisation_member_playtime`
  ADD UNIQUE KEY `char_id` (`char_id`,`org_id`,`start_time`);

--
-- Indexes for table `imta_organisation_permissions`
--
ALTER TABLE `imta_organisation_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `id_2` (`id`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `imta_organisation_permission_list`
--
ALTER TABLE `imta_organisation_permission_list`
  ADD UNIQUE KEY `permission_id` (`permission_id`,`id`,`type`) USING BTREE;

--
-- Indexes for table `imta_organisation_permisson_categories`
--
ALTER TABLE `imta_organisation_permisson_categories`
  ADD UNIQUE KEY `rank` (`rank`);

--
-- Indexes for table `imta_weapons_indices`
--
ALTER TABLE `imta_weapons_indices`
  ADD UNIQUE KEY `weapon_id` (`weapon_id`);

--
-- AUTO_INCREMENT for table `imta_organisation`
--
ALTER TABLE `imta_organisation`
  MODIFY `id` mediumint(7) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `imta_organisation_concessions`
--
ALTER TABLE `imta_organisation_concessions`
  MODIFY `con_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `imta_organisation_groups`
--
ALTER TABLE `imta_organisation_groups`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `imta_organisation_permissions`
--
ALTER TABLE `imta_organisation_permissions`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

  
INSERT INTO `imta_organisation_permissions` (`id`, `name`, `namePL`, `category`, `is_economic`) VALUES
(1, 'allow_recruiting', 'Rekrutacja', 'basic', 0),
(2, 'allow_building_managing', 'Zarządzanie budynkiem', 'basic', 0),
(3, 'allow_warehouse', 'Magazyn', 'basic', 0),
(4, 'allow_safe', 'Sejf', 'basic', 0),
(5, 'allow_safe_searching', 'Przeszukiwanie sejfu', 'basic', 0),
(7, 'allow_mdc', 'MDC', 'basic', 0),
(8, 'allow_radio_internal', 'Radio wewnętrzne', 'basic', 0),
(9, 'allow_duty_over_head', 'Widoczna służba nad głową', 'basic', 0),
(10, 'allow_duty_outside_buildings', 'Służba poza budynkiem', 'basic', 0),
(11, 'allow_radio_external', 'Radio międzyoddziałowe', 'law_enforcment', 0),
(12, 'allow_captives', 'Przetrzymywanie', 'law_enforcment', 0),
(13, 'allow_weapons_ordering', 'Zamawianie broni', 'law_enforcment', 0),
(14, 'allow_handcuffing', 'Zakuwanie rąk', 'law_enforcment', 0),
(15, 'allow_legscuffing', 'Zakuwanie nóg', 'law_enforcment', 0),
(16, 'allow_captives_leading', 'Prowadzenie zakutych', 'law_enforcment', 0),
(17, 'allow_tickets', 'Mandaty', 'law_enforcment', 0),
(18, 'allow_advanced_door_breaching', 'Wyważanie wszystkich drzwi', 'law_enforcment', 0),
(19, 'allow_documents_confiscation', 'Zabranie dokumentów', 'law_enforcment', 0),
(21, 'allow_weapon_allowance_issuing', 'Wydawanie pozwoleń na broń', 'law_enforcment', 1),
(22, 'allow_heal_offering', 'Leczenie', 'law_enforcment', 1),
(23, 'allow_number_targeting', 'Namierzanie numerów', 'law_enforcment', 0),
(24, 'allow_car_managing', 'Zarządzanie autami grupowymi', 'law_enforcment', 0),
(25, 'allow_door_closing', 'Zamykanie i otwieranie drzwi', 'law_enforcment', 0),
(26, ' allow_interior_managing', 'Zarządzanie wnętrzem', 'law_enforcment', 0),
(27, 'vehicle_searching', 'Przeszukiwanie pojazdów', 'law_enforcment', 0),
(28, 'allow_gate_opening', 'Otwieranie bram', 'law_enforcment', 0),
(29, 'allow_towing', 'Holowanie pojazdów', 'law_enforcment', 0),
(30, 'allow_narcotics_trading', 'Handlowanie narkotykami', 'criminal', 0),
(31, 'allow_narcotics_ordering', 'Zamawianie narkotyków', 'criminal', 0),
(32, 'allow_weapons_ordering', 'Zamawianie broni palnej', 'criminal', 0),
(33, 'allow_weapon_parts_ordering', 'Zamawianie części do broni', 'criminal', 0),
(34, 'allow_basic_stock_door_breaching', 'Wyważanie drzwi z podstawowym zamkiem', 'criminal', 0),
(35, 'allow_interior_captives', 'Przetrzymywanie wewnątrz budynku', 'criminal', 0),
(36, 'allow_graffiti', 'Tworzenie graffiti', 'criminal', 0),
(37, 'allow_robbing', 'Napady', 'criminal', 0),
(38, 'limit_ordering', 'Limit w zamawianiu przedmiotów - 10', 'criminal', 0),
(39, 'allow_racing', 'Oferowanie wyścigów', 'criminal', 0),
(40, 'allow_gang_areas', 'Widoczność stref gangowych', 'criminal', 0),
(41, 'allow_food_ordering', 'Zamawianie żywności', 'business', 0),
(42, 'allow_carparts_ordering', 'Zamawianie kompomentów mechanicznych pojazdów', 'business', 0),
(43, 'allow_common_goods_ordering', 'Zamawianie środków powszechnego użytku', 'business', 1),
(44, 'allow_gym_ordering', 'Karnety, odżywki i siłownia', 'business', 1),
(45, 'allow_courier', 'System kuriera', 'business', 0),
(46, 'allow_vehicle_shop', 'Koncesja i sprzedaż nowych pojazdów', 'business', 1),
(47, 'allow_taxi', 'Taksometry taksówkarskie', 'business', 0),
(48, 'allow_casino', 'System kasyna', 'business', 1),
(49, 'allow_vehicle_fixing', 'Warsztat', 'business', 1),
(50, 'allow_driving', 'Prowadzenie pojazdów', 'basic', 0),
(51, 'allow_driving_special_a', 'Prowadzenie pojazdów specjalnych A', 'basic', 0),
(52, 'allow_driving_special_b', 'Prowadzenie pojazdów specjalnych B', 'basic', 0),
(53, 'allow_vehicle_paint', 'Malowanie pojazdów, lakierowanie.', 'business', 1),
(54, 'allow_vehicle_tunning_install', 'Montaż komponentów do pojazdów.', 'business', 1),
(55, 'allow_gang_areasPD', 'Wyświetlanie stref na mapie', 'law_enforcment', 0),
(56, 'allow_vehicle_taxi', 'Poruszanie się taksówkami', 'business', 1),
(57, 'limit_ordering_15', 'Limit w zamawianiu przedmiotów - 15', 'basic', 0),
(58, 'limit_ordering_20', 'Limit w zamawianiu przedmiotów - 20', 'basic', 0),
(59, 'allow_vehicle_manage', 'zarządzanie autami używanymi', 'business', 0),
(60, 'allow_wearable_objects', 'Zakładanie dodatkowych przedmiotów organizacji', 'basic', 0),
(61, 'allow_food_shop', 'Uprawnienie do sprzedawania żywności ', 'business', 1),
(62, 'allow_atm', 'Wypłacanie/wpłacanie do grupy', 'business', 0),
(63, 'allow_driving_licence', 'Oferta praktyki prawa jazdy', 'business', 0),
(64, 'allow_special_weapon', 'Używanie broni oflagowanych', 'law_enforcment', 0),
(65, 'allow_special_vest', 'Używanie kamizelek oflagowanych.', 'law_enforcment', 0),
(66, 'allow_emergency_lights', 'Używanie świateł alarmowych ELS', 'law_enforcment', 0),
(67, 'allow_megaphone', 'Używanie megafonu', 'law_enforcment', 0),
(68, 'allow_dispatcher', 'Używanie systemu zgłoszeń', 'law_enforcment', 0),
(69, 'allow_wear', 'Uprawnienie do ubrań.', 'business', 0),
(70, 'allow_dispatcher_taxi', 'Używanie systemu zgłoszeń TAXI', 'business', 0),
(71, 'allow_radio_internal_ooc', 'Radio wewnętrzne OOC', 'basic', 0),
(72, 'search_player', 'Przeszukiwanie osób', 'law_enforcment', 0),
(74, 'limit_ordering_50', 'Limit w zamawianiu przedmiotów - 50', 'basic', 0),
(75, 'allow_ordering_weapon_light', 'Uprawnienia do zamawiania broni lekkich', 'basic', 0),
(76, 'allow_ordering_weapon_heavy', 'Uprawnienia do zamawiania broni ciężkich', 'basic', 0),
(77, 'allow_ordering_drugs_heavy', 'Uprawnienia do zamawiania twardych narkotyków', 'basic', 0),
(78, 'allow_ordering_drugs_light', 'Uprawnienia do zamawiania narkotyków miękkich', 'basic', 0);

--
-- Dumping data for table `imta_organisation_permisson_categories`
--

INSERT INTO `imta_organisation_permisson_categories` (`category`, `rank`, `categoryNamePL`) VALUES
('basic', 1, 'Uprawnienia podstawowe'),
('law_enforcment', 2, 'Uprawnienia służb porządkowych'),
('criminal', 3, 'Uprawnienia organizacji przestępczych'),
('business', 4, 'Uprawnienia gospodarcze');

--
-- Dumping data for table `imta_weapons_indices`
--

INSERT INTO `imta_weapons_indices` (`weapon_id`, `current_id`) VALUES
(3, 0),
(6, 0),
(9, 0),
(22, 0),
(23, 0),
(24, 0),
(25, 0),
(27, 0),
(28, 0),
(29, 0),
(30, 0),
(31, 0),
(32, 0),
(33, 0),
(34, 0),
(41, 0),
(42, 0),
(43, 0);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
