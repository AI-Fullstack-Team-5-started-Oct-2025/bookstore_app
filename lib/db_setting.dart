import 'package:bookstore_app/Restitutor_custom/dao_custom.dart';
import 'package:bookstore_app/data_set.dart';
import 'package:bookstore_app/model/customer.dart';
import 'package:bookstore_app/model/employee.dart';
import 'package:bookstore_app/model/product/manufacturer.dart';
import 'package:bookstore_app/model/product/product.dart';
import 'package:bookstore_app/model/product/product_base.dart';
import 'package:bookstore_app/model/product/product_image.dart';
import 'package:bookstore_app/mv/oncrate.dart';
import 'package:bookstore_app/config.dart' as config;
class DbSetting {

  late DataSet _dataSet;  

  final String dbName = '${config.kDBName}${config.kDBFileExt}';
  final int dVersion = config.kVersion;


  Future<void> svInitDB() async {
    _dataSet = DataSet();
    await DBCreation.creation(dbName, dVersion);
    final productDAO = RDAO<Product>(
      dbName: dbName,
      tableName: config.kTableProduct,
      dVersion: dVersion,
      fromMap: Product.fromMap,
    );
    final productbaseDAO = RDAO<ProductBase>(
      dbName: dbName,
      tableName: config.kTableProductBase,
      dVersion: dVersion,
      fromMap: ProductBase.fromMap,
    );
    final productImageDAO = RDAO<ProductImage>(
      dbName: dbName,
      tableName: config.kTableProductImage,
      dVersion: dVersion,
      fromMap: ProductImage.fromMap,
    );
    final manufacturerDAO = RDAO<Manufacturer>(
      dbName: dbName,
      tableName: config.kTableManufacturer,
      dVersion: dVersion,
      fromMap: Manufacturer.fromMap,
    );

    final customerDAO = RDAO<Customer>(
      dbName: dbName,
      tableName: config.kTableCustomer,
      dVersion: dVersion,
      fromMap: Customer.fromMap,
    );

     final employeeDAO = RDAO<Employee>(
      dbName: dbName,
      tableName: config.tTableEmployee,
      dVersion: dVersion,
      fromMap: Employee.fromMap,
    );

    for(var manufacturer in _dataSet.manufacturerList)
    {
      await manufacturerDAO.insertK(manufacturer.toMap());
    }

    for(var pbItem in _dataSet.productBaseList)
    {
     await productbaseDAO.insertK(pbItem.toMap());
      
    }

    for(var pimageList in _dataSet.productImageList)
    {
      await productImageDAO.insertK(pimageList.toMap());
    }
    
    for(var pItem in _dataSet.productList)
    {
      await productDAO.insertK(pItem.toMap());
    }

    for(var cItem in _dataSet.customerList)
    {
      int i = await customerDAO.insertK(cItem.toMap());
      // Customer result = await customerDAO.queryK({'id': i});
      // print("result :  ${result.id} / ${result.cPname} / ${result.cPhoneNumber} / ${result.cEmail} / ${result.cPassword}"  );
    }

    for(var eItem in _dataSet.employeeList)
    {
      int i = await employeeDAO.insertK(eItem.toMap());
      // Employee result = await employeeDAO.queryK({'id' : i});
      // print("result :  ${result.id} / ${result.eName} / ${result.ePhoneNumber} / ${result.eEmail} / ${result.ePassword}"  );
    }

  }
}