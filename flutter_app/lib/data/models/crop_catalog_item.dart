class CropCatalogItem {
  const CropCatalogItem(
      {required this.cropKey, required this.cropNameVi, required this.isAuto});
  final String cropKey;
  final String cropNameVi;
  final bool isAuto;

  factory CropCatalogItem.fromJson(Map<String, dynamic> json) =>
      CropCatalogItem(
        cropKey: json['cropKey'] as String,
        cropNameVi: json['cropNameVi'] as String,
        isAuto: json['isAuto'] == true,
      );
}
