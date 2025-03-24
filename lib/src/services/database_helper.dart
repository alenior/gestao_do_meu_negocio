import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/quote.dart';
import '../models/sale.dart';
import '../models/company.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static const _databaseVersion = 2; // Aumente a versão do banco

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'business_manager.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE company(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    taxId TEXT NOT NULL,
    address TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    imagePath TEXT
  )
''');
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        taxId TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        imagePath TEXT,
        birthday INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        taxId TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL,
        imagePath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        costPrice REAL NOT NULL,
        sellingPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        supplierId INTEGER NOT NULL,
        imagePath TEXT,
        FOREIGN KEY (supplierId) REFERENCES suppliers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quotes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE quote_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quoteId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (quoteId) REFERENCES quotes (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId INTEGER NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        discount REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (saleId) REFERENCES sales (id),
        FOREIGN KEY (productId) REFERENCES products (id)
      )
    ''');
  }

  Future<int> insertCompany(Company company) async {
    final db = await database;
    return await db.insert('company', company.toMap());
  }

  Future<int> updateCompany(Company company) async {
    final db = await database;
    return await db.update(
      'company',
      company.toMap(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  Future<Company?> getCompany() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('company');

    if (maps.isEmpty) {
      return null;
    }

    return Company.fromMap(maps.first);
  }

  // Customer operations
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    return await db.insert('customers', customer.toMap());
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('customers');
    return List.generate(maps.length, (i) => Customer.fromMap(maps[i]));
  }

  // Supplier operations
  Future<int> insertSupplier(Supplier supplier) async {
    final db = await database;
    return await db.insert('suppliers', supplier.toMap());
  }

  Future<int> updateSupplier(Supplier supplier) async {
    final db = await database;
    return await db.update(
      'suppliers',
      supplier.toMap(),
      where: 'id = ?',
      whereArgs: [supplier.id],
    );
  }

  Future<int> deleteSupplier(int id) async {
    final db = await database;
    return await db.delete('suppliers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Supplier>> getAllSuppliers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('suppliers');
    return List.generate(maps.length, (i) => Supplier.fromMap(maps[i]));
  }

  // Product operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    List<Product> products = [];

    for (var map in maps) {
      final supplierMap = await db.query(
        'suppliers',
        where: 'id = ?',
        whereArgs: [map['supplierId']],
      );

      if (supplierMap.isNotEmpty) {
        map['supplierName'] = supplierMap.first['name'];
        products.add(Product.fromMap(map));
      }
    }

    return products;
  }

  // Quote operations
  Future<int> insertQuote(Quote quote) async {
    final db = await database;
    final quoteId = await db.insert('quotes', quote.toMap());

    for (var item in quote.items) {
      item.quoteId = quoteId;
      await db.insert('quote_items', item.toMap());
    }

    return quoteId;
  }

  Future<int> updateQuote(Quote quote) async {
    final db = await database;
    await db.update(
      'quotes',
      quote.toMap(),
      where: 'id = ?',
      whereArgs: [quote.id],
    );

    await db.delete('quote_items', where: 'quoteId = ?', whereArgs: [quote.id]);

    for (var item in quote.items) {
      await db.insert('quote_items', item.toMap());
    }

    return quote.id!;
  }

  Future<int> deleteQuote(int id) async {
    final db = await database;
    await db.delete('quote_items', where: 'quoteId = ?', whereArgs: [id]);
    return await db.delete('quotes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Quote>> getAllQuotes() async {
    final db = await database;
    final List<Map<String, dynamic>> quoteMaps = await db.query('quotes');
    List<Quote> quotes = [];

    for (var quoteMap in quoteMaps) {
      final customerMap = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [quoteMap['customerId']],
      );

      if (customerMap.isNotEmpty) {
        quoteMap['customerName'] = customerMap.first['name'];

        final itemMaps = await db.query(
          'quote_items',
          where: 'quoteId = ?',
          whereArgs: [quoteMap['id']],
        );

        List<QuoteItem> items = [];
        for (var itemMap in itemMaps) {
          final productMap = await db.query(
            'products',
            where: 'id = ?',
            whereArgs: [itemMap['productId']],
          );

          if (productMap.isNotEmpty) {
            itemMap['productName'] = productMap.first['name'];
            items.add(QuoteItem.fromMap(itemMap));
          }
        }

        quoteMap['items'] = items;
        quotes.add(Quote.fromMap(quoteMap));
      }
    }

    return quotes;
  }

  // Sale operations
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    final saleId = await db.insert('sales', sale.toMap());

    for (var item in sale.items) {
      // Create a new SaleItem with the correct saleId
      final newItem = SaleItem(
        id: item.id,
        saleId: saleId,
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        price: item.price,
        discount: item.discount,
        total: item.total,
      );

      await db.insert('sale_items', newItem.toMap());

      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [item.productId],
      );

      if (product.isNotEmpty) {
        final currentQuantity = product.first['quantity'] as int;
        await db.update(
          'products',
          {'quantity': currentQuantity - item.quantity},
          where: 'id = ?',
          whereArgs: [item.productId],
        );
      }
    }

    return saleId;
  }

  Future<int> updateSale(Sale sale) async {
    final db = await database;
    await db.update(
      'sales',
      sale.toMap(),
      where: 'id = ?',
      whereArgs: [sale.id],
    );

    final oldItems = await db.query(
      'sale_items',
      where: 'saleId = ?',
      whereArgs: [sale.id],
    );

    for (var oldItem in oldItems) {
      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [oldItem['productId']],
      );

      if (product.isNotEmpty) {
        final currentQuantity = product.first['quantity'] as int;
        await db.update(
          'products',
          {'quantity': currentQuantity + (oldItem['quantity'] as int)},
          where: 'id = ?',
          whereArgs: [oldItem['productId']],
        );
      }
    }

    await db.delete('sale_items', where: 'saleId = ?', whereArgs: [sale.id]);

    for (var item in sale.items) {
      await db.insert('sale_items', item.toMap());

      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [item.productId],
      );

      if (product.isNotEmpty) {
        final currentQuantity = product.first['quantity'] as int;
        await db.update(
          'products',
          {'quantity': currentQuantity - item.quantity},
          where: 'id = ?',
          whereArgs: [item.productId],
        );
      }
    }

    return sale.id!;
  }

  Future<int> deleteSale(int id) async {
    final db = await database;
    final items = await db.query(
      'sale_items',
      where: 'saleId = ?',
      whereArgs: [id],
    );

    for (var item in items) {
      final product = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [item['productId']],
      );

      if (product.isNotEmpty) {
        final currentQuantity = product.first['quantity'] as int;
        await db.update(
          'products',
          {'quantity': currentQuantity + (item['quantity'] as int)},
          where: 'id = ?',
          whereArgs: [item['productId']],
        );
      }
    }

    await db.delete('sale_items', where: 'saleId = ?', whereArgs: [id]);

    return await db.delete('sales', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final List<Map<String, dynamic>> saleMaps = await db.query('sales');
    List<Sale> sales = [];

    for (var saleMap in saleMaps) {
      final customerMap = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [saleMap['customerId']],
      );

      if (customerMap.isNotEmpty) {
        saleMap['customerName'] = customerMap.first['name'];

        final itemMaps = await db.query(
          'sale_items',
          where: 'saleId = ?',
          whereArgs: [saleMap['id']],
        );

        List<SaleItem> items = [];
        for (var itemMap in itemMaps) {
          final productMap = await db.query(
            'products',
            where: 'id = ?',
            whereArgs: [itemMap['productId']],
          );

          if (productMap.isNotEmpty) {
            itemMap['productName'] = productMap.first['name'];
            items.add(SaleItem.fromMap(itemMap));
          }
        }

        saleMap['items'] = items;
        sales.add(Sale.fromMap(saleMap));
      }
    }

    return sales;
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> saleMaps = await db.query(
      'sales',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    List<Sale> sales = [];

    for (var saleMap in saleMaps) {
      final customerMap = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [saleMap['customerId']],
      );

      if (customerMap.isNotEmpty) {
        saleMap['customerName'] = customerMap.first['name'];

        final itemMaps = await db.query(
          'sale_items',
          where: 'saleId = ?',
          whereArgs: [saleMap['id']],
        );

        List<SaleItem> items = [];
        for (var itemMap in itemMaps) {
          final productMap = await db.query(
            'products',
            where: 'id = ?',
            whereArgs: [itemMap['productId']],
          );

          if (productMap.isNotEmpty) {
            itemMap['productName'] = productMap.first['name'];
            items.add(SaleItem.fromMap(itemMap));
          }
        }

        saleMap['items'] = items;
        sales.add(Sale.fromMap(saleMap));
      }
    }

    return sales;
  }

  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE customers ADD COLUMN birthday INTEGER');
    }
  }
}
