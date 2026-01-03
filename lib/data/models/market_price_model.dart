class MarketPrice {
  final String id;
  final String cropType;
  final String marketName;
  final double price;
  final String unit;
  final DateTime lastUpdated;
  final String? region;
  
  MarketPrice({
    required this.id,
    required this.cropType,
    required this.marketName,
    required this.price,
    required this.unit,
    required this.lastUpdated,
    this.region,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'crop_type': cropType,
      'market_name': marketName,
      'price': price,
      'unit': unit,
      'last_updated': lastUpdated.toIso8601String(),
      'region': region,
    };
  }
  
  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      id: json['id'],
      cropType: json['crop_type'],
      marketName: json['market_name'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      lastUpdated: DateTime.parse(json['last_updated']),
      region: json['region'],
    );
  }
}
