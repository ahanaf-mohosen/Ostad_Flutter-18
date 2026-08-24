import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({
    super.key,
    this.product,
  });

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() =>
      _ProductFormScreenState();
}

class _ProductFormScreenState
    extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _imageController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitPriceController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.product != null) {
      _nameController.text =
          widget.product!.productName;

      _codeController.text =
          widget.product!.productCode.toString();

      _imageController.text =
          widget.product!.img;

      _qtyController.text =
          widget.product!.qty.toString();

      _unitPriceController.text =
          widget.product!.unitPrice.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _imageController.dispose();
    _qtyController.dispose();
    _unitPriceController.dispose();

    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final int qty = int.parse(_qtyController.text);
      final double unitPrice =
      double.parse(_unitPriceController.text);

      final double totalPrice = qty * unitPrice;

      final product = Product(
        id: widget.product?.id,
        productName: _nameController.text.trim(),
        productCode: int.parse(_codeController.text),
        img: _imageController.text.trim(),
        qty: qty,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
      );

      bool success;

      if (widget.isEditing) {
        success = await _apiService.updateProduct(
          widget.product!.id!,
          product,
        );
      } else {
        success = await _apiService.createProduct(
          product,
        );
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Product updated successfully'
                  : 'Product created successfully',
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        throw Exception('Operation failed');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType =
        TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }

          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Product'
              : 'Add Product',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Product Name',
                icon: Icons.shopping_bag,
              ),

              _buildTextField(
                controller: _codeController,
                label: 'Product Code',
                icon: Icons.qr_code,
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _imageController,
                label: 'Image URL',
                icon: Icons.image,
              ),

              _buildTextField(
                controller: _qtyController,
                label: 'Quantity',
                icon: Icons.inventory,
                keyboardType: TextInputType.number,
              ),

              _buildTextField(
                controller: _unitPriceController,
                label: 'Unit Price',
                icon: Icons.attach_money,
                keyboardType:
                const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  _loading ? null : _saveProduct,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : Text(
                    widget.isEditing
                        ? 'Update Product'
                        : 'Add Product',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}