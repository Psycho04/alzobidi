import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/customer.dart';
import '../../cubits/customers_cubit.dart';
import '../../l10n/app_localizations.dart';

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final formKey = GlobalKey<FormState>();
  String name = '';
  String whatsappNumber = '';

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations.addCustomer),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration:
                  InputDecoration(labelText: localizations.customerName),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterName;
                }
                return null;
              },
              onSaved: (value) => name = value!,
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: localizations.whatsappNumber),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterWhatsapp;
                }
                return null;
              },
              onSaved: (value) => whatsappNumber = value!,
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
              final customer = Customer(
                name: name,
                whatsappNumber: whatsappNumber,
              );
              context.read<CustomersCubit>().addCustomer(customer);
              Navigator.pop(context);
            }
          },
          child: Text(localizations.add),
        ),
      ],
    );
  }
}

void showAddCustomerDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AddCustomerDialog(),
  );
}
