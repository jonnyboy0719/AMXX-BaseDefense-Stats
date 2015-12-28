CREATE TABLE IF NOT EXISTS `bdef_stats` (
  `authid` varchar(50) NOT NULL,
  `name` text,
  `online` varchar(50) DEFAULT 'false',
  `country` varchar(50) DEFAULT '00',
  `lvl` int(11) DEFAULT '1',
  `exp` int(11) DEFAULT '0',
  `exp_max` int(11) DEFAULT '300',
  `money` int(11) DEFAULT '300',
  `item_health` int(11) DEFAULT '0',
  `item_mana` int(11) DEFAULT '0',
  `skill_legerity` int(11) DEFAULT NULL,
  `skill_precision` int(11) DEFAULT NULL,
  `skill_toughness` int(11) DEFAULT NULL,
  `skill_sorcery` int(11) DEFAULT NULL,
  `points` int(11) DEFAULT '5',
  `date` int(11) DEFAULT NULL,
  PRIMARY KEY (`authid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS `bdef_stats_rank` (
  `lvl` int(11) NOT NULL,
  `title` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

INSERT INTO `bdef_stats_rank` (`lvl`, `title`) VALUES
	(1, 'Abasdarhon'),
	(5, 'Abraxos'),
	(10, 'Naaririel'),
	(15, 'Kemuel'),
	(20, 'Kokabiel'),
	(25, 'Rogziel'),
	(35, 'Rahmiel'),
	(50, 'Raziel'),
	(80, 'Sabrathan'),
	(90, 'Yerachmiel'),
	(100, 'Zuriel');