import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  static const delegate = AppLocalizationsDelegate();
  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations != null) {
      return localizations;
    }
    // Return a default implementation if localizations are not yet available
    return AppLocalizationsAr();
  }

  static const List<Locale> supportedLocales = [
    Locale('ar'), // Arabic
    Locale('en'), // English
  ];

  // General
  String get appTitle;

  // Navigation
  String get productsTab;
  String get accountsTab;
  String get invoicesTab;
  String get cashboxTab;

  // Products Page
  String get lowStock;
  String get expiringSoon;
  String get allProducts;
  String get quantity;
  String get price;
  String get expires;
  String get addProduct;
  String get editProduct;
  String get categoryType;
  String get pricePerUnit;
  String get expirationDate;
  String get pleaseEnterCategory;
  String get pleaseEnterQuantity;
  String get pleaseEnterValidQuantity;
  String get pleaseEnterPrice;
  String get pleaseEnterValidPrice;
  String get showAll;

  // Customers
  String get addCustomer;
  String get customerName;
  String get whatsappNumber;
  String get pleaseEnterName;
  String get pleaseEnterWhatsapp;
  String get customerDetails;
  String get totalPaid;
  String get remainingBalance;
  String get paymentVoucher;

  // Invoices
  String get newInvoice;
  String get customer;
  String get selectCustomer;
  String get selectedProducts;
  String get total;
  String get createInvoice;
  String get selectProducts;
  String get noProductsAvailable;
  String get selectMultipleProducts;
  String get addSelected;
  String get invoices;
  String get allInvoices;
  String get customerInvoices;
  String get date;
  String get items;
  String get product;
  String get close;
  String get share;
  String get taxNumber;
  String get commercialRegistration;
  String get institutionName;

  // Buttons
  String get cancel;
  String get save;
  String get delete;
  String get add;
  String get refreshData;

  // Cashbox Page
  String get financialSummary;
  String get lastUpdated;
  String get sales;
  String get purchases;
  String get totalProfit;
  String get recentTransactions;
  String get noRecentTransactions;

  // Payment
  String get amount;
  String get pleaseEnterAmount;
  String get invalidAmount;
  String get amountExceedsTotal;
  String get pay;
  String get paymentSuccessful;

  // Search
  String get searchProducts;
  String get searchResults;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    Intl.defaultLocale = locale.languageCode;

    switch (locale.languageCode) {
      case 'ar':
        return AppLocalizationsAr();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
