import 'package:coffe_shop_gpt/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../data/models/coffee.dart';

class ProductDetailScreen extends StatefulWidget {
  final Coffee coffee;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Function(Coffee, String) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.coffee,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';
  late bool _isFavorite;
  late double _currentPrice;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _currentPrice = widget.coffee.prices[_selectedSize]!;
  }

  void _updatePrice(String size) {
    setState(() {
      _selectedSize = size;
      _currentPrice = widget.coffee.prices[_selectedSize]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildContent(context),
          _buildAppBar(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAppBarButton(context, Icons.arrow_back_ios_new_rounded, () => Navigator.of(context).pop()),
            _buildAppBarButton(context, _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, () {
              setState(() => _isFavorite = !_isFavorite);
              widget.onToggleFavorite();
            }, color: _isFavorite ? Colors.redAccent : Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarButton(BuildContext context, IconData icon, VoidCallback onPressed, {Color? color}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 50,
          height: 50,
          color: Colors.black.withOpacity(0.3),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(theme),
                const SizedBox(height: 25),
                _buildSectionTitle('Description', theme),
                const SizedBox(height: 10),
                _buildDescription(theme),
                const SizedBox(height: 25),
                _buildSectionTitle('Size', theme),
                const SizedBox(height: 15),
                _buildSizeSelector(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Hero(
      tag: widget.coffee.image + widget.coffee.name,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(widget.coffee.image), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.coffee.name,
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(height: 5),
              Text(
                'with ${widget.coffee.subtitle}',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 28),
            const SizedBox(width: 5),
            Text(
              widget.coffee.rating.toString(),
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.headlineSmall,
    );
  }

  Widget _buildDescription(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.coffee.description,
          maxLines: _isDescriptionExpanded ? null : 3,
          overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Text(
            _isDescriptionExpanded ? 'Read Less' : 'Read More',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Row(
      children: ['S', 'M', 'L'].map((size) {
        final isSelected = _selectedSize == size;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: GestureDetector(
              onTap: () => _updatePrice(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : (isDarkMode ? Colors.grey[850] : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  size,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 25, 25),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 25,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Price', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                AppTheme.formatRupiah(_currentPrice),
                style: theme.textTheme.displaySmall?.copyWith(color: theme.primaryColor),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: ElevatedButton(
              onPressed: () => widget.onAddToCart(widget.coffee, _selectedSize),
              child: const Text('Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }
}
