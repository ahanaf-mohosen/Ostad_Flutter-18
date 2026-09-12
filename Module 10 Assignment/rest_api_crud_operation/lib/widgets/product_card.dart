import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 90,
                height: 90,
                child: product.img.isNotEmpty
                    ? Image.network(
                  product.img,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 40,
                    );
                  },
                )
                    : const Icon(
                  Icons.image,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Product information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    'Code: ${product.productCode}',
                  ),

                  Text(
                    'Quantity: ${product.qty}',
                  ),

                  Text(
                    'Unit Price: ৳${product.unitPrice}',
                  ),

                  Text(
                    'Total: ৳${product.totalPrice}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                        ),
                        label: const Text('Edit'),
                      ),

                      const SizedBox(width: 8),

                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}