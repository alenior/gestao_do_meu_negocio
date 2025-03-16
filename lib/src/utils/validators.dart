class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um telefone';
    }
    final phoneRegex = RegExp(r'^\(\d{2}\) \d{4,5}-\d{4}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Por favor, insira um telefone válido (XX) XXXXX-XXXX';
    }
    return null;
  }

  static String? validateCNPJ(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um CNPJ';
    }
    final cnpjRegex = RegExp(r'^\d{2}\.\d{3}\.\d{3}\/\d{4}\-\d{2}$');
    if (!cnpjRegex.hasMatch(value)) {
      return 'Por favor, insira um CNPJ válido XX.XXX.XXX/XXXX-XX';
    }
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um CPF';
    }
    final cpfRegex = RegExp(r'^\d{3}\.\d{3}\.\d{3}\-\d{2}$');
    if (!cpfRegex.hasMatch(value)) {
      return 'Por favor, insira um CPF válido XXX.XXX.XXX-XX';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um preço';
    }
    final price = double.tryParse(value.replaceAll(',', '.'));
    if (price == null || price <= 0) {
      return 'Por favor, insira um preço válido';
    }
    return null;
  }

  static String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma quantidade';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Por favor, insira uma quantidade válida';
    }
    return null;
  }
}