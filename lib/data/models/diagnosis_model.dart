class Diagnosis {
  final String id;
  final String userId;
  final String cropType;
  final String imageUrl;
  final String diseaseName;
  final double confidence;
  final String severity;
  final String? description;
  final String? treatment;
  final DateTime diagnosisDate;
  final bool synced;
  
  Diagnosis({
    required this.id,
    required this.userId,
    required this.cropType,
    required this.imageUrl,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    this.description,
    this.treatment,
    required this.diagnosisDate,
    this.synced = false,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'crop_type': cropType,
      'image_url': imageUrl,
      'disease_name': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'description': description,
      'treatment': treatment,
      'diagnosis_date': diagnosisDate.toIso8601String(),
      'synced': synced ? 1 : 0,
    };
  }
  
  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'],
      userId: json['user_id'],
      cropType: json['crop_type'],
      imageUrl: json['image_url'],
      diseaseName: json['disease_name'],
      confidence: json['confidence'].toDouble(),
      severity: json['severity'],
      description: json['description'],
      treatment: json['treatment'],
      diagnosisDate: DateTime.parse(json['diagnosis_date']),
      synced: json['synced'] == 1,
    );
  }
}
