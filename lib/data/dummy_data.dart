// lib/data/dummy_data.dart

import 'models/coffee.dart';

final List<Coffee> coffeeList = [
  Coffee(
    name: 'Cappuccino',
    subtitle: 'with Oat Milk',
    image: 'assets/images/drink_coffe_cappucino.jpg',
    prices: {'S': 65000, 'M': 68000, 'L': 72000},
    rating: 4.8,
    isBestSeller: true,
    description:
        'A cappuccino is an espresso-based coffee drink that originated in Italy, and is traditionally prepared with steamed milk foam.',
    category: 'drinks',
  ),
  Coffee(
    name: '3 Point Coffee',
    subtitle: 'with Creamer',
    image: 'assets/images/drink_coffe_3point_coffee.jpg',
    prices: {'S': 65000, 'M': 68000, 'L': 72000},
    rating: 4.8,
    isBestSeller: true,
    description:
        'A unique coffee blend with a rich aroma and smooth taste, perfect for any time of the day.',
    category: 'drinks',
  ),
  Coffee(
    name: 'Peach Tea',
    subtitle: 'with Jelly',
    image: 'assets/images/drink_tea_peachtea.jpg',
    prices: {'S': 52000, 'M': 55000, 'L': 60000},
    rating: 4.5,
    description:
        'A refreshing iced tea with a delightful peach flavor, perfect for a hot day.',
    category: 'drinks',
  ),
  Coffee(
    name: 'Ayam Telur Asin',
    subtitle: 'with Rice',
    image: 'assets/images/food_ayam_telur_asin.jpg',
    prices: {'S': 90000, 'M': 97000, 'L': 105000},
    rating: 4.7,
    isBestSeller: true,
    description:
        'Crispy fried chicken with a savory salted egg yolk sauce, a popular Indonesian dish.',
    category: 'food',
  ),
  Coffee(
    name: 'Fried Rice',
    subtitle: 'Special',
    image: 'assets/images/food_fried_rice.jpg',
    prices: {'S': 75000, 'M': 82000, 'L': 90000},
    rating: 4.2,
    description:
        'Classic Indonesian fried rice with a mix of vegetables and your choice of protein.',
    category: 'food',
  ),
  Coffee(
    name: 'Sandwich',
    subtitle: 'with Egg',
    image: 'assets/images/food_sandwich.jpg',
    prices: {'S': 60000, 'M': 67000, 'L': 75000},
    rating: 4.0,
    description:
        'A delicious and filling sandwich with fresh ingredients, perfect for a quick meal.',
    category: 'food',
  ),
  Coffee(
    name: 'Shrimp Singapore Sauce',
    subtitle: 'with Mantau',
    image: 'assets/images/food_shrimp_singapore_sauce.jpg',
    prices: {'S': 105000, 'M': 112000, 'L': 120000},
    rating: 4.6,
    isBestSeller: true,
    description:
        'Succulent shrimp cooked in a rich and spicy Singaporean-style sauce, a true delight.',
    category: 'food',
  ),
];
