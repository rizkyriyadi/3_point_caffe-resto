// lib/data/dummy_data.dart

import 'models/coffee.dart';

const String newImageUrl =
    'https://plus.unsplash.com/premium_photo-1674327105074-46dd8319164b?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

final List<Coffee> coffeeList = [
  Coffee(
    name: 'Cappuccino',
    image: newImageUrl,
    prices: {'S': 4.33, 'M': 4.53, 'L': 4.83},
    rating: 4.8,
    isBestSeller: true,
    description:
        'A cappuccino is an espresso-based coffee drink that originated in Italy, and is traditionally prepared with steamed milk foam.',
  ),
  Coffee(
    name: 'Macchiato',
    image: newImageUrl,
    prices: {'S': 3.70, 'M': 3.90, 'L': 4.20},
    rating: 4.7,
    description:
        'An espresso macchiato is a coffee beverage with a small amount of milk, usually foamed. In Italian, macchiato means "stained" or "spotted".',
  ),
  Coffee(
    name: 'Latte',
    image: newImageUrl,
    prices: {'S': 4.00, 'M': 4.20, 'L': 4.50},
    rating: 4.5,
    isBestSeller: true,
    description:
        'A latte or caffè latte is a coffee drink made with espresso and steamed milk. The word comes from the Italian caffè e latte, which means "coffee and milk".',
  ),
  Coffee(
    name: 'Americano',
    image: newImageUrl,
    prices: {'S': 3.30, 'M': 3.50, 'L': 3.80},
    rating: 4.3,
    description:
        'Caffè Americano is a type of coffee drink prepared by diluting an espresso with hot water, giving it a similar strength to, but different flavor from, traditionally brewed coffee.',
  ),
];
