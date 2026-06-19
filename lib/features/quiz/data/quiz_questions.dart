import '../models/quiz_question.dart';
import '../models/tour_city.dart';

const quizQuestions = [
  QuizQuestion(
    question: 'Care este cel mai apropiat oraș mare de tine?',
    options: [
      QuizOption(label: 'Iași', preferredAreas: {CityArea.east}),
      QuizOption(label: 'Brașov', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Sibiu', preferredAreas: {CityArea.center}),
      QuizOption(label: 'București', preferredAreas: {CityArea.south}),
      QuizOption(label: 'Cluj-Napoca', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Constanța', preferredAreas: {CityArea.southeast}),
      QuizOption(label: 'Timișoara', preferredAreas: {CityArea.west}),
      QuizOption(label: 'Oradea', preferredAreas: {CityArea.west}),
      QuizOption(label: 'Alba Iulia', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Sighișoara', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Târgu Mureș', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Piatra Neamț', preferredAreas: {CityArea.east}),
      QuizOption(label: 'Suceava', preferredAreas: {CityArea.north}),
      QuizOption(label: 'Gura Humorului', preferredAreas: {CityArea.north}),
      QuizOption(label: 'Vatra Dornei', preferredAreas: {CityArea.north}),
      QuizOption(label: 'Baia Mare', preferredAreas: {CityArea.north}),
      QuizOption(label: 'Sighetu Marmației', preferredAreas: {CityArea.north}),
      QuizOption(label: 'Bistrița', preferredAreas: {CityArea.north}),
      QuizOption(label: 'Deva', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Hunedoara', preferredAreas: {CityArea.center}),
      QuizOption(label: 'Târgoviște', preferredAreas: {CityArea.south}),
      QuizOption(label: 'Curtea de Argeș', preferredAreas: {CityArea.south}),
      QuizOption(label: 'Sinaia', preferredAreas: {CityArea.south}),
      QuizOption(label: 'Bușteni', preferredAreas: {CityArea.south}),
      QuizOption(label: 'Predeal', preferredAreas: {CityArea.south}),
      QuizOption(label: 'Tulcea', preferredAreas: {CityArea.southeast}),
      QuizOption(label: 'Mangalia', preferredAreas: {CityArea.southeast}),
      QuizOption(label: 'Craiova', preferredAreas: {CityArea.south}),
      QuizOption(
        label: 'Drobeta-Turnu Severin',
        preferredAreas: {CityArea.south},
      ),
      QuizOption(label: 'Arad', preferredAreas: {CityArea.west}),
    ],
  ),
  QuizQuestion(
    question: 'Cât de departe ești dispusă să mergi pentru orașul potrivit?',
    options: [
      QuizOption(label: 'Aș prefera ceva aproape', weight: 3),
      QuizOption(label: 'Pot merge câteva ore dacă merită', weight: 1),
      QuizOption(label: 'Nu contează distanța, vreau potrivirea cea mai bună'),
    ],
  ),
  QuizQuestion(
    question: 'Cum ar arăta o zi liberă perfectă pentru tine?',
    options: [
      QuizOption(
        label: 'Plimbare lungă pe lângă apă',
        requiredTags: {CityTag.seaside},
        tags: {CityTag.water, CityTag.relaxing},
        weight: 3,
      ),
      QuizOption(
        label: 'Aer rece, priveliști și drumeție',
        requiredTags: {CityTag.mountain},
        tags: {CityTag.nature, CityTag.active},
        weight: 3,
      ),
      QuizOption(
        label: 'Cafenele, străzi frumoase și vitrine',
        tags: {CityTag.urban, CityTag.food, CityTag.shopping},
        weight: 2,
      ),
      QuizOption(
        label: 'Locuri liniștite și povești vechi',
        tags: {CityTag.history, CityTag.quiet, CityTag.culture},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Când ajungi într-un loc nou, ce faci prima dată?',
    options: [
      QuizOption(
        label: 'Caut cel mai frumos loc pentru poze',
        tags: {CityTag.photography, CityTag.architecture},
        weight: 2,
      ),
      QuizOption(
        label: 'Caut o poveste interesantă despre loc',
        tags: {CityTag.history, CityTag.culture},
        weight: 2,
      ),
      QuizOption(
        label: 'Caut ceva bun de mâncat',
        tags: {CityTag.food, CityTag.urban},
        weight: 2,
      ),
      QuizOption(
        label: 'Caut un parc, o panoramă sau natură',
        tags: {CityTag.nature, CityTag.mountain},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Cum îți imaginezi seara perfectă într-o excursie?',
    options: [
      QuizOption(
        label: 'Apus pe malul apei',
        requiredTags: {CityTag.seaside},
        tags: {CityTag.water, CityTag.photography},
        weight: 3,
      ),
      QuizOption(
        label: 'O cină bună într-un centru animat',
        tags: {CityTag.food, CityTag.urban, CityTag.nightlife},
        weight: 2,
      ),
      QuizOption(
        label: 'O plimbare liniștită prin străzi istorice',
        tags: {CityTag.history, CityTag.romantic, CityTag.quiet},
        weight: 2,
      ),
      QuizOption(
        label: 'O panorama de sus asupra orașului',
        tags: {CityTag.mountain, CityTag.photography, CityTag.nature},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce fel de povești te prind cel mai repede?',
    options: [
      QuizOption(
        label: 'Regi, palate și personaje istorice',
        tags: {CityTag.history, CityTag.museums},
        weight: 2,
      ),
      QuizOption(
        label: 'Legende medievale și mistere',
        tags: {CityTag.medieval, CityTag.history},
        weight: 2,
      ),
      QuizOption(
        label: 'Tradiții locale și oameni autentici',
        tags: {CityTag.traditions, CityTag.culture},
        weight: 2,
      ),
      QuizOption(
        label: 'Povești despre natură și locuri spectaculoase',
        tags: {CityTag.nature, CityTag.mountain},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce te face să te oprești din mers ca să te uiți mai atent?',
    options: [
      QuizOption(
        label: 'O clădire foarte frumoasă',
        tags: {CityTag.architecture, CityTag.photography},
        weight: 2,
      ),
      QuizOption(
        label: 'Un muzeu sau o expoziție',
        tags: {CityTag.museums, CityTag.culture},
        weight: 2,
      ),
      QuizOption(
        label: 'Un peisaj natural',
        tags: {CityTag.nature, CityTag.mountain},
        weight: 2,
      ),
      QuizOption(
        label: 'Valuri, lacuri sau Dunăre',
        requiredTags: {CityTag.seaside},
        tags: {CityTag.water, CityTag.relaxing},
        weight: 3,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Cu cine te vezi făcând aventura?',
    options: [
      QuizOption(
        label: 'Singură, vreau ceva de explorat în ritmul meu',
        tags: {CityTag.quiet, CityTag.culture},
        weight: 1,
      ),
      QuizOption(
        label: 'Cu prietenii, vreau energie',
        tags: {CityTag.nightlife, CityTag.urban, CityTag.festivals},
        weight: 2,
      ),
      QuizOption(
        label: 'Cu familia, vreau ceva accesibil',
        tags: {CityTag.family, CityTag.relaxing},
        weight: 2,
      ),
      QuizOption(
        label: 'Cu cineva drag, vreau atmosferă romantică',
        tags: {CityTag.romantic, CityTag.photography},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce preferi să ai mai aproape de traseu?',
    options: [
      QuizOption(
        label: 'Muzee și obiective culturale',
        tags: {CityTag.museums, CityTag.culture, CityTag.history},
        weight: 2,
      ),
      QuizOption(
        label: 'Terase, restaurante și cafenele',
        tags: {CityTag.food, CityTag.urban},
        weight: 2,
      ),
      QuizOption(
        label: 'Natură, parcuri sau trasee',
        tags: {CityTag.nature, CityTag.mountain},
        weight: 2,
      ),
      QuizOption(
        label: 'Plajă, port sau faleză',
        requiredTags: {CityTag.seaside},
        tags: {CityTag.water},
        weight: 3,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce ritm ți se potrivește?',
    options: [
      QuizOption(
        label: 'Lent, cu pauze multe',
        tags: {CityTag.relaxing, CityTag.family, CityTag.quiet},
        weight: 2,
      ),
      QuizOption(
        label: 'Echilibrat, câte puțin din toate',
        tags: {CityTag.culture, CityTag.urban, CityTag.history},
        weight: 1,
      ),
      QuizOption(
        label: 'Activ, vreau să simt că am explorat',
        tags: {CityTag.active, CityTag.mountain, CityTag.nature},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce ai alege pentru o fotografie de final?',
    options: [
      QuizOption(
        label: 'Un castel sau o cetate',
        tags: {CityTag.medieval, CityTag.history, CityTag.photography},
        weight: 2,
      ),
      QuizOption(
        label: 'O stradă colorată sau o piață frumoasă',
        tags: {CityTag.architecture, CityTag.urban, CityTag.photography},
        weight: 2,
      ),
      QuizOption(
        label: 'Un vârf, o pădure sau o panoramă',
        requiredTags: {CityTag.mountain},
        tags: {CityTag.nature, CityTag.photography},
        weight: 3,
      ),
      QuizOption(
        label: 'Marea sau apa în fundal',
        requiredTags: {CityTag.seaside},
        tags: {CityTag.water, CityTag.photography},
        weight: 3,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce te-ar face să recomanzi orașul altcuiva?',
    options: [
      QuizOption(
        label: 'Are atmosferă aparte',
        tags: {CityTag.romantic, CityTag.culture},
        weight: 2,
      ),
      QuizOption(
        label: 'Are multe lucruri de făcut',
        tags: {CityTag.urban, CityTag.nightlife, CityTag.festivals},
        weight: 2,
      ),
      QuizOption(
        label: 'Are povești și tradiții',
        tags: {CityTag.traditions, CityTag.history, CityTag.spiritual},
        weight: 2,
      ),
      QuizOption(
        label: 'Are peisaje care rămân în minte',
        tags: {CityTag.nature, CityTag.mountain, CityTag.water},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'Ce ai prefera să eviți?',
    options: [
      QuizOption(
        label: 'Prea multă agitație',
        blockedTags: {CityTag.nightlife},
        tags: {CityTag.quiet, CityTag.relaxing},
        weight: 2,
      ),
      QuizOption(
        label: 'Trasee prea solicitante',
        blockedTags: {CityTag.mountain, CityTag.active},
        tags: {CityTag.family, CityTag.relaxing},
        weight: 2,
      ),
      QuizOption(
        label: 'Prea multe muzee',
        blockedTags: {CityTag.museums},
        tags: {CityTag.nature, CityTag.urban},
        weight: 1,
      ),
      QuizOption(label: 'Nimic, sunt deschisă la orice', weight: 0),
    ],
  ),
  QuizQuestion(
    question: 'Ce cuvânt descrie cel mai bine excursia ta ideală?',
    options: [
      QuizOption(
        label: 'Relaxare',
        tags: {CityTag.relaxing, CityTag.family, CityTag.quiet},
        weight: 2,
      ),
      QuizOption(
        label: 'Aventură',
        tags: {CityTag.active, CityTag.mountain, CityTag.nature},
        weight: 2,
      ),
      QuizOption(
        label: 'Descoperire',
        tags: {CityTag.history, CityTag.culture, CityTag.museums},
        weight: 2,
      ),
      QuizOption(
        label: 'Energie',
        tags: {CityTag.urban, CityTag.nightlife, CityTag.festivals},
        weight: 2,
      ),
    ],
  ),
  QuizQuestion(
    question: 'La final, ce ai vrea să simți?',
    options: [
      QuizOption(
        label: 'Că am învățat ceva nou',
        tags: {CityTag.history, CityTag.museums, CityTag.culture},
        weight: 2,
      ),
      QuizOption(
        label: 'Că m-am deconectat complet',
        tags: {CityTag.relaxing, CityTag.nature, CityTag.water},
        weight: 2,
      ),
      QuizOption(
        label: 'Că am văzut ceva spectaculos',
        tags: {CityTag.photography, CityTag.mountain, CityTag.architecture},
        weight: 2,
      ),
      QuizOption(
        label: 'Că am trăit un oraș viu',
        tags: {CityTag.urban, CityTag.food, CityTag.nightlife},
        weight: 2,
      ),
    ],
  ),
];
