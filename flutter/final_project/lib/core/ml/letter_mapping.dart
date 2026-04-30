/// 🔤 خريطة بين labels نموذج ML والحروف العربيّة المستخدمة في التطبيق
class LetterMapping {
  LetterMapping._();

  static const Map<String, String> _modelToArabic = {
    'alif': 'أ',
    'alif_hamza_above': 'أ',
    'alif_hamza_below': 'أ',
    'alif_maad': 'أ',
    'alif_maqsoura': 'ى',
    'alif_maqsoura_hamza': 'ى',
    'baa': 'ب',
    'ta': 'ت',
    'taa': 'ت',
    'tha': 'ث',
    'jiim': 'ج',
    'haa': 'ح',
    'kha': 'خ',
    'daal': 'د',
    'thal': 'ذ',
    'raa': 'ر',
    'zay': 'ز',
    'zaa': 'ز',
    'siin': 'س',
    'shiin': 'ش',
    'saad': 'ص',
    'daad': 'ض',
    'haa2': 'ط',
    'ayn': 'ع',
    'ghayn': 'غ',
    'faa': 'ف',
    'qaaf': 'ق',
    'kaaf': 'ك',
    'laam': 'ل',
    'miim': 'م',
    'noon': 'ن',
    'waaw': 'و',
    'waaw_hamza': 'و',
    'yaa': 'ي',
    'taa_marbuuta': 'ة',
  };

  /// تحويل label من النموذج إلى حرف عربيّ
  static String? toArabic(String modelLabel) {
    return _modelToArabic[modelLabel];
  }

  /// التحقّق من تطابق label النموذج مع الحرف المتوقَّع
  static bool matches(String modelLabel, String expectedArabic) {
    final mapped = toArabic(modelLabel);
    return mapped != null && mapped == expectedArabic;
  }
}
