import '../models/treasure_hunt.dart';

const iasiTreasureHunt = TreasureHunt(
  id: 'iasi_tainele_vechi',
  cityId: 'iasi',
  cityName: 'Iași',
  title: 'Pe urmele Iașului cultural',
  startPoint: 'Parcul Copou',
  estimatedTime: '3 - 4 ore',
  rewardName: 'Medalia culturală a Iașului',
  story:
      'Traseul pornește din Copou, acolo unde Iașul își arată partea liniștită, literară și plină de verdeață. De aici, aventura coboară treptat spre centrul orașului, trecând prin locuri legate de istorie, artă, spiritualitate și cultură. Fiecare oprire păstrează o bucată din identitatea orașului, iar scopul tău este să le descoperi în ordinea potrivită și să confirmi fiecare locație printr-o fotografie.',
  objectives: [
    HuntObjective(
      name: 'Parcul Copou',
      story:
          'Aventura începe într-o zonă verde și liniștită, unde orașul pare să respire mai încet. Aleile, copacii și atmosfera veche dau impresia că timpul se mișcă altfel aici. Prima piesă a traseului se ascunde într-un loc potrivit pentru începutul unei explorări culturale, legat de poezie, plimbări și de partea mai calmă a orașului.',
      hints: [
        'Caută un loc verde, cunoscut pentru alei largi și atmosferă liniștită.',
        'Este un parc important al orașului, asociat cu Eminescu și cu plimbările prin Copou.',
        'Locația este Parcul Copou.',
      ],
      reward: 'Frunza de Copou',
      photoInstruction:
          'Fă poza din fața zonei indicate, cu reperul principal în centru și fără zoom exagerat.',
      latitude: 47.1786,
      longitude: 27.5691,
      officialImageAsset: 'assets/official_images/iasi/Parcul_copou/',
    ),
    HuntObjective(
      name: 'Piata Unirii',
      story:
          'După zona verde de la început, traseul coboară spre un spațiu mai deschis și mai agitat, unde orașul își arată energia centrală. Este un loc de întâlnire, de trecere și de evenimente, legat de memoria istorică și de momentele în care oamenii se adună împreună. Aici se simte trecerea de la liniștea parcului la pulsul urban al Iașului.',
      hints: [
        'Caută un spațiu central, larg, unde se întâlnesc mai multe drumuri.',
        'Locul este cunoscut pentru statui, clădiri importante și evenimente publice.',
        'Locația este Piața Unirii.',
      ],
      reward: 'Insigna Unirii',
      photoInstruction:
          'Fă poza din fața locației, cu reperul principal în mijloc și cât mai puține obstacole în cadru.',
      latitude: 47.1667,
      longitude: 27.5808,
      officialImageAsset: 'assets/official_images/iasi/Piata_unirii/',
    ),
    HuntObjective(
      name: 'Teatrul National Vasile Alecsandri',
      story:
          'Următoarea oprire te apropie de o clădire elegantă, legată de artă, emoție și povești spuse în fața publicului. După locurile deschise și aglomerate, traseul capătă aici o notă mai artistică. Este un punct în care orașul nu mai este doar privit, ci imaginat prin cortine, lumini, voci și momente care prind viață pe scenă.',
      hints: [
        'Următorul loc are legătură cu arta scenică și spectacolele.',
        'Clădirea este una dintre cele mai elegante instituții culturale ale orașului.',
        'Locația este Teatrul Național Vasile Alecsandri.',
      ],
      reward: 'Masca de teatru',
      photoInstruction:
          'Fă poza din fața locației, de la distanță medie, astfel încât intrarea și partea superioară să încapă în cadru.',
      latitude: 47.1632,
      longitude: 27.5848,
      officialImageAsset: 'assets/official_images/iasi/Teatrul_national/',
    ),
    HuntObjective(
      name: 'Catedrala Mitropolitana',
      story:
          'De aici, traseul ajunge într-un loc în care atmosfera se schimbă din nou. Zgomotul orașului pare să se reducă, iar spațiul devine mai solemn și mai așezat. Următorul punct are o prezență impunătoare și este legat de liniște, tradiție și spiritualitate. Fotografia trebuie să surprindă cât mai clar clădirea și verticalitatea ei.',
      hints: [
        'Caută un loc spiritual important, aproape de centrul orașului.',
        'Este o clădire impunătoare, asociată cu slujbe, pelerini și sărbători.',
        'Locația este Catedrala Mitropolitană.',
      ],
      reward: 'Medalion spiritual',
      photoInstruction:
          'Fă poza din fața locației, cu telefonul drept și partea superioară vizibilă în cadru.',
      latitude: 47.1613,
      longitude: 27.5846,
      officialImageAsset:
          'assets/official_images/iasi/Catedrala_mitropolitana/',
    ),
    HuntObjective(
      name: 'Palatul Culturii',
      story:
          'Ultima oprire te conduce spre o clădire monumentală, care adună foarte bine imaginea orașului: istorie, arhitectură, muzee și fotografii memorabile. După locurile parcurse până acum, finalul traseului are rolul de a închide aventura într-un punct spectaculos, ușor de recunoscut prin silueta lui și prin prezența puternică în centrul orașului.',
      hints: [
        'Caută o clădire foarte mare, cu aspect de palat.',
        'Este unul dintre cele mai fotografiate obiective turistice din Iași.',
        'Locația este Palatul Culturii.',
      ],
      reward: 'Coroana culturala',
      photoInstruction:
          'Fă poza din fața locației, de la distanță, astfel încât reperul principal să fie vizibil cât mai complet.',
      latitude: 47.1577,
      longitude: 27.5869,
      officialImageAsset: 'assets/official_images/iasi/Palatul_culturii/',
    ),
  ],
);
