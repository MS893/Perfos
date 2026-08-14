import 'dart:convert';
import '../../../lib/performance_logic.dart';

AircraftWithMultiTables _getWT9LSA() {
  const double mass = 600.0;
  
  final takeoffDurData = <double, Map<double, Map<double, PerformanceEntry>>>{
    0.0: {
      -30.0: {mass: PerformanceEntry(109, 211)}, -20.0: {mass: PerformanceEntry(118, 228)}, -10.0: {mass: PerformanceEntry(127, 245)}, 0.0: {mass: PerformanceEntry(136, 263)}, 10.0: {mass: PerformanceEntry(146, 282)}, 20.0: {mass: PerformanceEntry(156, 301)}, 30.0: {mass: PerformanceEntry(166, 321)},
    },
    2000.0: {
      -30.0: {mass: PerformanceEntry(122, 237)}, -20.0: {mass: PerformanceEntry(132, 256)}, -10.0: {mass: PerformanceEntry(142, 275)}, 0.0: {mass: PerformanceEntry(153, 296)}, 10.0: {mass: PerformanceEntry(164, 317)}, 20.0: {mass: PerformanceEntry(175, 339)}, 30.0: {mass: PerformanceEntry(187, 362)},
    },
    4000.0: {
      -30.0: {mass: PerformanceEntry(138, 266)}, -20.0: {mass: PerformanceEntry(149, 288)}, -10.0: {mass: PerformanceEntry(160, 310)}, 0.0: {mass: PerformanceEntry(172, 334)}, 10.0: {mass: PerformanceEntry(185, 358)}, 20.0: {mass: PerformanceEntry(198, 383)}, 30.0: {mass: PerformanceEntry(211, 409)},
    },
    6000.0: {
      -30.0: {mass: PerformanceEntry(155, 299)}, -20.0: {mass: PerformanceEntry(167, 324)}, -10.0: {mass: PerformanceEntry(181, 350)}, 0.0: {mass: PerformanceEntry(195, 376)}, 10.0: {mass: PerformanceEntry(209, 404)}, 20.0: {mass: PerformanceEntry(224, 433)}, 30.0: {mass: PerformanceEntry(239, 463)},
    },
    8000.0: {
      -30.0: {mass: PerformanceEntry(174, 337)}, -20.0: {mass: PerformanceEntry(189, 365)}, -10.0: {mass: PerformanceEntry(204, 395)}, 0.0: {mass: PerformanceEntry(220, 425)}, 10.0: {mass: PerformanceEntry(236, 457)}, 20.0: {mass: PerformanceEntry(253, 490)}, 30.0: {mass: PerformanceEntry(271, 524)},
    },
    10000.0: {
      -30.0: {mass: PerformanceEntry(197, 380)}, -20.0: {mass: PerformanceEntry(213, 413)}, -10.0: {mass: PerformanceEntry(231, 447)}, 0.0: {mass: PerformanceEntry(249, 482)}, 10.0: {mass: PerformanceEntry(268, 519)}, 20.0: {mass: PerformanceEntry(288, 557)}, 30.0: {mass: PerformanceEntry(308, 596)},
    },
  };

  final takeoffHerbeData = <double, Map<double, Map<double, PerformanceEntry>>>{
    0.0: {
      -30.0: {mass: PerformanceEntry(123, 229)}, -20.0: {mass: PerformanceEntry(132, 247)}, -10.0: {mass: PerformanceEntry(143, 266)}, 0.0: {mass: PerformanceEntry(153, 285)}, 10.0: {mass: PerformanceEntry(164, 305)}, 20.0: {mass: PerformanceEntry(175, 326)}, 30.0: {mass: PerformanceEntry(187, 347)},
    },
    2000.0: {
      -30.0: {mass: PerformanceEntry(138, 257)}, -20.0: {mass: PerformanceEntry(149, 277)}, -10.0: {mass: PerformanceEntry(160, 298)}, 0.0: {mass: PerformanceEntry(172, 321)}, 10.0: {mass: PerformanceEntry(184, 344)}, 20.0: {mass: PerformanceEntry(197, 367)}, 30.0: {mass: PerformanceEntry(210, 392)},
    },
    4000.0: {
      -30.0: {mass: PerformanceEntry(155, 288)}, -20.0: {mass: PerformanceEntry(167, 312)}, -10.0: {mass: PerformanceEntry(180, 336)}, 0.0: {mass: PerformanceEntry(194, 361)}, 10.0: {mass: PerformanceEntry(208, 388)}, 20.0: {mass: PerformanceEntry(223, 415)}, 30.0: {mass: PerformanceEntry(238, 443)},
    },
    6000.0: {
      -30.0: {mass: PerformanceEntry(174, 324)}, -20.0: {mass: PerformanceEntry(188, 351)}, -10.0: {mass: PerformanceEntry(203, 379)}, 0.0: {mass: PerformanceEntry(219, 408)}, 10.0: {mass: PerformanceEntry(235, 438)}, 20.0: {mass: PerformanceEntry(252, 469)}, 30.0: {mass: PerformanceEntry(269, 501)},
    },
    8000.0: {
      -30.0: {mass: PerformanceEntry(196, 365)}, -20.0: {mass: PerformanceEntry(212, 396)}, -10.0: {mass: PerformanceEntry(230, 428)}, 0.0: {mass: PerformanceEntry(247, 461)}, 10.0: {mass: PerformanceEntry(266, 495)}, 20.0: {mass: PerformanceEntry(285, 531)}, 30.0: {mass: PerformanceEntry(305, 568)},
    },
    10000.0: {
      -30.0: {mass: PerformanceEntry(221, 412)}, -20.0: {mass: PerformanceEntry(240, 447)}, -10.0: {mass: PerformanceEntry(260, 484)}, 0.0: {mass: PerformanceEntry(280, 522)}, 10.0: {mass: PerformanceEntry(302, 562)}, 20.0: {mass: PerformanceEntry(324, 603)}, 30.0: {mass: PerformanceEntry(347, 646)},
    },
  };

  final landingDurData = <double, Map<double, Map<double, PerformanceEntry>>>{
    0.0: {
      -30.0: {mass: PerformanceEntry(99, 332)}, -20.0: {mass: PerformanceEntry(107, 359)}, -10.0: {mass: PerformanceEntry(115, 386)}, 0.0: {mass: PerformanceEntry(123, 414)}, 10.0: {mass: PerformanceEntry(132, 443)}, 20.0: {mass: PerformanceEntry(141, 473)}, 30.0: {mass: PerformanceEntry(150, 505)},
    },
    2000.0: {
      -30.0: {mass: PerformanceEntry(111, 373)}, -20.0: {mass: PerformanceEntry(120, 403)}, -10.0: {mass: PerformanceEntry(129, 434)}, 0.0: {mass: PerformanceEntry(138, 466)}, 10.0: {mass: PerformanceEntry(148, 499)}, 20.0: {mass: PerformanceEntry(159, 534)}, 30.0: {mass: PerformanceEntry(169, 569)},
    },
    4000.0: {
      -30.0: {mass: PerformanceEntry(124, 419)}, -20.0: {mass: PerformanceEntry(135, 453)}, -10.0: {mass: PerformanceEntry(145, 488)}, 0.0: {mass: PerformanceEntry(156, 525)}, 10.0: {mass: PerformanceEntry(167, 563)}, 20.0: {mass: PerformanceEntry(179, 603)}, 30.0: {mass: PerformanceEntry(191, 643)},
    },
    6000.0: {
      -30.0: {mass: PerformanceEntry(140, 471)}, -20.0: {mass: PerformanceEntry(151, 510)}, -10.0: {mass: PerformanceEntry(164, 550)}, 0.0: {mass: PerformanceEntry(176, 593)}, 10.0: {mass: PerformanceEntry(189, 636)}, 20.0: {mass: PerformanceEntry(202, 681)}, 30.0: {mass: PerformanceEntry(216, 728)},
    },
    8000.0: {
      -30.0: {mass: PerformanceEntry(158, 530)}, -20.0: {mass: PerformanceEntry(171, 575)}, -10.0: {mass: PerformanceEntry(185, 621)}, 0.0: {mass: PerformanceEntry(199, 670)}, 10.0: {mass: PerformanceEntry(214, 720)}, 20.0: {mass: PerformanceEntry(229, 772)}, 30.0: {mass: PerformanceEntry(245, 825)},
    },
    10000.0: {
      -30.0: {mass: PerformanceEntry(178, 599)}, -20.0: {mass: PerformanceEntry(193, 650)}, -10.0: {mass: PerformanceEntry(209, 703)}, 0.0: {mass: PerformanceEntry(225, 759)}, 10.0: {mass: PerformanceEntry(243, 816)}, 20.0: {mass: PerformanceEntry(260, 876)}, 30.0: {mass: PerformanceEntry(279, 938)},
    },
  };

  final landingHerbeData = <double, Map<double, Map<double, PerformanceEntry>>>{
    0.0: {
      -30.0: {mass: PerformanceEntry(185, 421)}, -20.0: {mass: PerformanceEntry(199, 454)}, -10.0: {mass: PerformanceEntry(214, 488)}, 0.0: {mass: PerformanceEntry(230, 524)}, 10.0: {mass: PerformanceEntry(246, 561)}, 20.0: {mass: PerformanceEntry(263, 599)}, 30.0: {mass: PerformanceEntry(280, 639)},
    },
    2000.0: {
      -30.0: {mass: PerformanceEntry(207, 472)}, -20.0: {mass: PerformanceEntry(224, 509)}, -10.0: {mass: PerformanceEntry(241, 549)}, 0.0: {mass: PerformanceEntry(259, 590)}, 10.0: {mass: PerformanceEntry(277, 632)}, 20.0: {mass: PerformanceEntry(296, 675)}, 30.0: {mass: PerformanceEntry(316, 721)},
    },
    4000.0: {
      -30.0: {mass: PerformanceEntry(233, 530)}, -20.0: {mass: PerformanceEntry(252, 573)}, -10.0: {mass: PerformanceEntry(271, 618)}, 0.0: {mass: PerformanceEntry(292, 665)}, 10.0: {mass: PerformanceEntry(313, 713)}, 20.0: {mass: PerformanceEntry(335, 763)}, 30.0: {mass: PerformanceEntry(357, 814)},
    },
    6000.0: {
      -30.0: {mass: PerformanceEntry(262, 596)}, -20.0: {mass: PerformanceEntry(283, 645)}, -10.0: {mass: PerformanceEntry(306, 697)}, 0.0: {mass: PerformanceEntry(329, 750)}, 10.0: {mass: PerformanceEntry(353, 805)}, 20.0: {mass: PerformanceEntry(379, 862)}, 30.0: {mass: PerformanceEntry(405, 922)},
    },
    8000.0: {
      -30.0: {mass: PerformanceEntry(295, 671)}, -20.0: {mass: PerformanceEntry(319, 728)}, -10.0: {mass: PerformanceEntry(345, 787)}, 0.0: {mass: PerformanceEntry(372, 848)}, 10.0: {mass: PerformanceEntry(400, 911)}, 20.0: {mass: PerformanceEntry(429, 977)}, 30.0: {mass: PerformanceEntry(459, 1045)},
    },
    10000.0: {
      -30.0: {mass: PerformanceEntry(333, 758)}, -20.0: {mass: PerformanceEntry(361, 823)}, -10.0: {mass: PerformanceEntry(391, 890)}, 0.0: {mass: PerformanceEntry(422, 960)}, 10.0: {mass: PerformanceEntry(454, 1033)}, 20.0: {mass: PerformanceEntry(487, 1109)}, 30.0: {mass: PerformanceEntry(521, 1187)},
    },
  };

  return AircraftWithMultiTables(
    name: "WT9 LSA",
    takeoffDur: AircraftPerformance(takeoffDurData),
    takeoffHerbe: AircraftPerformance(takeoffHerbeData),
    landing: AircraftPerformance(landingDurData),
    landingHerbe: AircraftPerformance(landingHerbeData),
  );
}

void main() {
  final wt9 = _getWT9LSA();
  print(jsonEncode(wt9.toJson()));
}
