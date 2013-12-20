-- phpMyAdmin SQL Dump
-- version 3.5.8.1deb1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Ven 20 Décembre 2013 à 16:12
-- Version du serveur: 5.5.34-0ubuntu0.13.04.1
-- Version de PHP: 5.4.9-4ubuntu2.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `traderbot`
--

-- --------------------------------------------------------

--
-- Structure de la table `bots`
--

CREATE TABLE IF NOT EXISTS `bots` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `desc` varchar(255) DEFAULT NULL,
  `market` varchar(255) NOT NULL DEFAULT 'btc-e',
  `pair` varchar(255) NOT NULL DEFAULT 'ltc_usd',
  `algo` varchar(255) NOT NULL DEFAULT 'staticRange',
  `algo_params` varchar(4096) NOT NULL,
  `simu` tinyint(1) NOT NULL DEFAULT '1',
  `max_invest` int(11) NOT NULL DEFAULT '0',
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `balances` varchar(4096) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=37 ;

-- --------------------------------------------------------

--
-- Structure de la table `markets`
--

CREATE TABLE IF NOT EXISTS `markets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `markets`
--

INSERT INTO `markets` (`id`, `name`) VALUES
(1, 'btc-e'),
(2, 'mt-gox');

-- --------------------------------------------------------

--
-- Structure de la table `market_pairs`
--

CREATE TABLE IF NOT EXISTS `market_pairs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `market_id` int(11) NOT NULL,
  `pair_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `market_id` (`market_id`),
  KEY `pair_id` (`pair_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=5 ;

--
-- Contenu de la table `market_pairs`
--

INSERT INTO `market_pairs` (`id`, `market_id`, `pair_id`) VALUES
(1, 1, 1),
(2, 1, 2),
(4, 2, 2);

-- --------------------------------------------------------

--
-- Structure de la table `market_pair_values`
--

CREATE TABLE IF NOT EXISTS `market_pair_values` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `market_pair_id` int(11) NOT NULL,
  `time` int(11) NOT NULL,
  `value` varchar(4096) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `orders`
--

CREATE TABLE IF NOT EXISTS `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `order` varchar(255) NOT NULL,
  `amount` int(11) NOT NULL,
  `rate` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `pairs`
--

CREATE TABLE IF NOT EXISTS `pairs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pair` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

--
-- Contenu de la table `pairs`
--

INSERT INTO `pairs` (`id`, `pair`) VALUES
(1, 'ltc_usd'),
(2, 'btc_usd');

-- --------------------------------------------------------

--
-- Structure de la table `trades`
--

CREATE TABLE IF NOT EXISTS `trades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bot_id` int(11) NOT NULL,
  `order` varchar(255) NOT NULL,
  `amount` float NOT NULL,
  `rate` float NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `group` int(11) NOT NULL,
  `settings` varchar(4096) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=10 ;

--
-- Contraintes pour les tables exportées
--

--
-- Contraintes pour la table `market_pairs`
--
ALTER TABLE `market_pairs`
  ADD CONSTRAINT `market_pairs_ibfk_1` FOREIGN KEY (`market_id`) REFERENCES `markets` (`id`),
  ADD CONSTRAINT `market_pairs_ibfk_2` FOREIGN KEY (`pair_id`) REFERENCES `pairs` (`id`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
