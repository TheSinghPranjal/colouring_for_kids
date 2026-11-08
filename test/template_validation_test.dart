import 'dart:convert';
import 'dart:io';

import 'package:colouring_for_kids/data/coloring_catalog.dart';
import 'package:colouring_for_kids/data/template_repository.dart';
import 'package:colouring_for_kids/engines/region_coloring/coloring_controller.dart';
import 'package:colouring_for_kids/models/coloring_artwork.dart';
import 'package:colouring_for_kids/models/coloring_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// The 100 sketches the product requires, by category.
const expected = {
  'flowers_garden': [
    'flower',
    'flower_pot',
    'tree',
    'mushroom',
    'leaf',
    'tulip',
    'sunflower',
    'cactus',
    'rose',
    'daisy',
    'dandelion',
    'lotus',
    'poppy',
    'bluebell',
    'cherry_blossom',
    'bouquet',
    'watering_can',
    'wheelbarrow',
    'birdhouse',
    'garden_gnome',
    'pine_tree',
    'palm_tree',
    'acorn',
    'clover',
    'seedling',
    'shovel',
    'garden_bench',
    'beehive',
    'lily_pad',
    'lavender',
  ],
  'pets_farm': [
    'cat',
    'dog',
    'cow',
    'pig',
    'chicken',
    'horse',
    'sheep',
    'rabbit',
    'goat',
    'mouse',
    'hamster',
    'guinea_pig',
    'fish_bowl',
    'donkey',
    'llama',
    'rooster',
    'chick',
    'turkey',
    'goose',
    'lamb',
    'piglet',
    'puppy',
    'kitten',
    'pony',
    'calf',
    'tractor',
    'scarecrow',
    'dog_house',
    'hay_bale',
    'hen_house',
  ],
  'wild_animals': [
    'elephant',
    'turtle',
    'lion',
    'monkey',
    'giraffe',
    'zebra',
    'panda',
    'fox',
    'hippo',
    'koala',
    'tiger',
    'bear',
    'rhino',
    'kangaroo',
    'crocodile',
    'camel',
    'deer',
    'wolf',
    'raccoon',
    'squirrel',
    'hedgehog',
    'sloth',
    'gorilla',
    'cheetah',
    'polar_bear',
    'frog',
    'snake',
    'moose',
    'beaver',
    'skunk',
  ],
  'birds_insects': [
    'bird',
    'duck',
    'owl',
    'butterfly',
    'bee',
    'ladybug',
    'snail',
    'parrot',
    'penguin',
    'dragonfly',
    'flamingo',
    'peacock',
    'swan',
    'eagle',
    'toucan',
    'hummingbird',
    'woodpecker',
    'pigeon',
    'ostrich',
    'stork',
    'puffin',
    'crow',
    'ant',
    'caterpillar',
    'grasshopper',
    'spider',
    'firefly',
    'beetle',
    'moth',
    'worm',
  ],
  'underwater_world': [
    'fish',
    'octopus',
    'whale',
    'crab',
    'seahorse',
    'starfish',
    'dolphin',
    'jellyfish',
    'shark',
    'clam',
    'sea_turtle',
    'squid',
    'lobster',
    'shrimp',
    'stingray',
    'pufferfish',
    'clownfish',
    'angelfish',
    'swordfish',
    'seal',
    'walrus',
    'narwhal',
    'eel',
    'coral',
    'sea_urchin',
    'conch',
    'anchor',
    'treasure_chest',
    'sea_otter',
    'seaweed',
  ],
  'vehicles': [
    'car',
    'bus',
    'train',
    'airplane',
    'boat',
    'bicycle',
    'truck',
    'helicopter',
    'motorcycle',
    'submarine',
    'fire_truck',
    'police_car',
    'ambulance',
    'taxi',
    'digger',
    'cement_mixer',
    'race_car',
    'van',
    'jeep',
    'garbage_truck',
    'ice_cream_truck',
    'tow_truck',
    'sailboat',
    'ship',
    'canoe',
    'scooter',
    'skateboard',
    'tram',
    'cable_car',
    'blimp',
  ],
  'buildings_places': [
    'house',
    'school',
    'castle',
    'shop',
    'windmill',
    'barn',
    'lighthouse',
    'igloo',
    'tent',
    'bridge',
    'hospital',
    'fire_station',
    'skyscraper',
    'apartment',
    'cottage',
    'treehouse',
    'pyramid',
    'library',
    'bakery',
    'cafe',
    'wishing_well',
    'fountain',
    'gazebo',
    'log_cabin',
    'clock_tower',
    'hut',
    'playground_slide',
    'swing_set',
    'carousel',
    'ferris_wheel',
  ],
  'fruits_vegetables': [
    'apple',
    'banana',
    'strawberry',
    'carrot',
    'corn',
    'grapes',
    'watermelon',
    'pear',
    'tomato',
    'broccoli',
    'orange',
    'lemon',
    'cherry',
    'pineapple',
    'peach',
    'plum',
    'kiwi',
    'mango',
    'coconut',
    'avocado',
    'blueberries',
    'pumpkin',
    'eggplant',
    'potato',
    'onion',
    'peas',
    'bell_pepper',
    'cucumber',
    'radish',
    'lettuce',
  ],
  'sky_weather': [
    'sun',
    'cloud',
    'rainbow',
    'moon',
    'snowman',
    'star_sky',
    'lightning',
    'umbrella',
    'hot_air_balloon',
    'raincloud',
    'snowflake',
    'tornado',
    'windsock',
    'planet',
    'comet',
    'earth',
    'raindrop',
    'rain_boots',
    'raincoat',
    'thermometer',
    'mountain',
    'volcano',
    'sunset',
    'parachute',
    'weather_vane',
    'sun_cloud',
    'snow_cloud',
    'sunglasses',
    'mittens',
    'satellite',
  ],
  'toys_imagination': [
    'teddy_bear',
    'ball',
    'kite',
    'toy_robot',
    'toy_rocket',
    'drum',
    'blocks',
    'doll',
    'yo_yo',
    'puzzle',
    'spinning_top',
    'rubber_duck',
    'toy_train',
    'rocking_horse',
    'xylophone',
    'balloons',
    'jack_in_the_box',
    'sandcastle',
    'magic_wand',
    'unicorn',
    'dragon',
    'dinosaur',
    'wizard_hat',
    'crown',
    'pirate_ship',
    'ufo',
    'alien',
    'astronaut',
    'toy_piano',
    'paper_plane',
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = TemplateRepository();
  final loaded = <String, ColoringTemplate>{};

  setUpAll(() async {
    for (final info in ColoringCatalog.allTemplates) {
      loaded[info.id] = await repo.load(info.id);
    }
  });

  test('exactly ten categories with exactly thirty sketches each', () {
    expect(ColoringCatalog.categories.map((c) => c.id).toList(), expected.keys.toList());
    for (final c in ColoringCatalog.categories) {
      expect(c.templateIds, expected[c.id], reason: c.id);
      expect(c.templateIds, contains(c.coverTemplateId));
    }
    expect(ColoringCatalog.allTemplates, hasLength(300));
    expect(ColoringCatalog.allTemplates.map((t) => t.id).toSet(), hasLength(300));
  });

  for (final info in ColoringCatalog.allTemplates) {
    group(info.id, () {
      test('all asset files are bundled and metadata matches the catalogue', () {
        for (final path in [info.outlineAsset, info.regionsAsset, info.thumbnailAsset, info.metadataAsset]) {
          expect(File(path).existsSync(), isTrue, reason: path);
        }
        final meta = jsonDecode(File(info.metadataAsset).readAsStringSync()) as Map<String, dynamic>;
        expect(meta['id'], info.id);
        expect(meta['title'], info.title);
        expect(meta['categoryId'], info.categoryId);
        // Thumbnail is a real PNG.
        expect(File(info.thumbnailAsset).readAsBytesSync().sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      });

      test('regions have unique ids, valid geometry and child-sized targets', () {
        final t = loaded[info.id]!;
        expect(t.regions.length, inInclusiveRange(4, 16));
        expect(t.regions.map((r) => r.id).toSet(), hasLength(t.regions.length));
        expect(t.outline.where((s) => s.isStroke), isNotEmpty);
        final vb = t.viewBox.inflate(1);
        for (final r in t.regions) {
          expect(r.bounds.isEmpty, isFalse, reason: r.id);
          expect(vb.contains(r.bounds.topLeft) && vb.contains(r.bounds.bottomRight), isTrue, reason: r.id);
          // ~ 40 x 40 units minimum (about 15 logical px on a small phone);
          // the hit tolerance adds more on top.
          expect(r.area, greaterThan(1600), reason: '${r.id} is too small for small fingers');
        }
      });

      test('every region is reachable at a sample point and nothing leaks', () {
        final t = loaded[info.id]!;
        final c = ColoringController(
          template: t,
          artwork: ColoringArtwork(id: 'v', templateId: t.id),
        );
        for (final r in t.fillableRegions) {
          final p = interiorPoint(r);
          expect(c.regionAt(p)?.id, r.id, reason: 'sample point of ${r.id}');
          expect(c.regionAt(p, tolerance: 14)?.id, r.id, reason: 'tolerance must not steal ${r.id}');
          c.fillAt(p, color: const Color(0xFFE53935));
          expect(c.artwork.fills.keys.toSet(), {r.id}, reason: 'filling ${r.id} must not touch others');
          c.resetPicture();
        }
      });

      test('regions form a partition: no point belongs to two regions', () {
        final t = loaded[info.id]!;
        for (var y = 5.0; y < 1000; y += 10) {
          for (var x = 5.0; x < 1000; x += 10) {
            final p = Offset(x, y);
            final hits = t.regions.where((r) => r.contains(p)).length;
            expect(hits, lessThanOrEqualTo(1), reason: 'overlap at $p');
          }
        }
      });
    });
  }

  test('decorative outline paths (eyes, seeds) are not fillable', () {
    final strawberry = loaded['strawberry']!;
    // Seeds are outline-only details; tapping one fills the strawberry body.
    final c = ColoringController(
      template: strawberry,
      artwork: ColoringArtwork(id: 's', templateId: 'strawberry'),
    );
    expect(c.regionAt(const Offset(500, 560))?.id, 'body');
    expect(strawberry.regions.any((r) => r.id.contains('seed')), isFalse);
    final cat = loaded['cat']!;
    expect(cat.regions.any((r) => r.id.contains('eye') || r.id.contains('whisker')), isFalse);
  });
}
