import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product.dart';
import '../../cubits/products_cubit.dart';
import '../../l10n/app_localizations.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final formKey = GlobalKey<FormState>();
  String category = '';
  int quantity = 0;
  double pricePerUnit = 0.0;
  DateTime expirationDate = DateTime.now().add(const Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.addProduct),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration:
                  InputDecoration(labelText: localizations.categoryType),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterCategory;
                }
                return null;
              },
              onSaved: (value) => category = value!,
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: localizations.quantity),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterQuantity;
                }
                final number = int.tryParse(value);
                if (number == null || number < 0) {
                  return localizations.pleaseEnterValidQuantity;
                }
                return null;
              },
              onSaved: (value) => quantity = int.parse(value!),
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: localizations.pricePerUnit),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterPrice;
                }
                final number = double.tryParse(value);
                if (number == null || number < 0) {
                  return localizations.pleaseEnterValidPrice;
                }
                return null;
              },
              onSaved: (value) => pricePerUnit = double.parse(value!),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Get today's date with time set to midnight for proper comparison
                final today = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                );

                // Set initialDate to today if expirationDate is in the past
                final initialDate = expirationDate.isBefore(today)
                    ? today
                    : expirationDate;

                final date = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: today,
                  lastDate: today.add(const Duration(days: 365 * 2)),
                  selectableDayPredicate: (DateTime day) {
                    // Only allow dates from today onwards
                    return !day.isBefore(today);
                  },
                );
                if (date != null) {
                  setState(() {
                    expirationDate = date;
                  });
                }
              },
              child: Text(
                  '${localizations.expirationDate}: ${_formatDate(expirationDate)}'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              final product = Product(
                category: category,
                quantity: quantity,
                pricePerUnit: pricePerUnit,
                expirationDate: expirationDate,
              );
              context.read<ProductsCubit>().addProduct(product);
              Navigator.pop(context);
            }
          },
          child: Text(localizations.add),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

void showAddProductDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AddProductDialog(),
  );
}
