import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/invoice.dart';
import '../../l10n/app_localizations.dart';

class PaymentDialog extends StatefulWidget {
  final Invoice invoice;
  final Function(double) onPaymentComplete;

  const PaymentDialog({
    super.key,
    required this.invoice,
    required this.onPaymentComplete,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.invoice.totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return AlertDialog(
      title: Text(localizations.paymentVoucher),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${localizations.total}: SAR ${widget.invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: localizations.amount,
                border: const OutlineInputBorder(),
                prefixText: 'SAR ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations.pleaseEnterAmount;
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return localizations.invalidAmount;
                }
                if (amount > widget.invoice.totalAmount) {
                  return localizations.amountExceedsTotal;
                }
                return null;
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: _handlePayment,
          child: Text(localizations.pay),
        ),
      ],
    );
  }

  void _handlePayment() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      widget.onPaymentComplete(amount);
      Navigator.pop(context);
    }
  }
}

void showPaymentDialog({
  required BuildContext context,
  required Invoice invoice,
  required Function(double) onPaymentComplete,
}) {
  showDialog(
    context: context,
    builder: (context) => PaymentDialog(
      invoice: invoice,
      onPaymentComplete: onPaymentComplete,
    ),
  );
} 