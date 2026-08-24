class Product {
  String? id;
  String productName;
  int productCode;
  String img;
  int qty;
  double unitPrice;
  double totalPrice;

  Product({
    this.id,
    required this.productName,
    required this.productCode,
    required this.img,
    required this.qty,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      productName: json['ProductName']?.toString() ?? '',
      productCode: _toInt(json['ProductCode']),
      img: json['Img']?.toString() ?? '',
      qty: _toInt(json['Qty']),
      unitPrice: _toDouble(json['UnitPrice']),
      totalPrice: _toDouble(json['TotalPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ProductName': productName,
      'ProductCode': productCode,
      'Img': img,
      'Qty': qty,
      'UnitPrice': unitPrice,
      'TotalPrice': totalPrice,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}