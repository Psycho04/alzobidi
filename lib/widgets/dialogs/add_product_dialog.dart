import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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

    // Using the brown/orange color scheme from the app
    const Color primaryColor = Color(0xFFB25D1E); // Brown/orange color from the image

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      localizations.addProduct,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.add_circle,
                      color: primaryColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category Field
                _buildTextField(
                  label: localizations.categoryType,
                  icon: Icons.category_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.pleaseEnterCategory;
                    }
                    return null;
                  },
                  onSaved: (value) => category = value!,
                ),
                const SizedBox(height: 16),

                // Quantity Field
                _buildTextField(
                  label: localizations.quantity,
                  icon: Icons.shopping_bag_outlined,
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
                const SizedBox(height: 16),

                // Price Field
                _buildTextField(
                  label: localizations.pricePerUnit,
                  icon: Icons.attach_money_outlined,
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
                const SizedBox(height: 24),

                // Expiration Date Picker
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
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
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: primaryColor,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            expirationDate = date;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations.expirationDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(expirationDate),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: primaryColor,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Add Button
                    ElevatedButton(
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(120, 45),
                      ),
                      child: Text(
                        localizations.add,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text(localizations.cancel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    // Define the primary color here as well
    const Color primaryColor = Color(0xFFB25D1E);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          alignLabelWithHint: true,
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format as dd/mm/yyyy
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
}

void showAddProductDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const AddProductDialog(),
  );
}
