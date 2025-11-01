import 'package:flutter/material.dart';

// Define Color Palette constants here since they are used extensively
const Color primaryGreen = Color(0xFF4CAF50);
const Color lightGreen = Color(0xFF8BC34A);

// --- Custom Widget for the common Text Field Design ---
class GradientTextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final Widget? suffixIcon;
  final bool isPassword;
  // New properties for form validation and management:
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const GradientTextField({
    super.key,
    required this.labelText,
    required this.hintText,
    this.suffixIcon,
    this.isPassword = false,
    // Initialize new properties
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the border color based on the validation status.
    // The TextFormField will handle the display of error text.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          // Outer container provides the gradient border effect
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [lightGreen, primaryGreen],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5), // Border effect thickness
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Inner white background
                borderRadius: BorderRadius.circular(12),
              ),
              // --- Replaced TextField with TextFormField ---
              child: TextFormField(
                controller: controller, // Pass the controller
                validator: validator, // Pass the validator function
                obscureText: isPassword,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  filled: true,
                  fillColor: lightGreen.withOpacity(0.1),
                  suffixIcon: suffixIcon,
                  
                  // Hide default border when no error
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  // Style focused border
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryGreen, width: 1.0),
                  ),
                  // Style error border (for when validator returns a string)
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                  // Important: Control error text visibility
                  errorStyle: const TextStyle(fontSize: 0, height: 0),
                ),
              ),
            ),
          ),
        ),
        // Custom Error Text Display (since we hid the default one)
        if (validator != null)
          // Use a custom builder to get the form field state, which includes error text
          Builder(
            builder: (context) {
              final FormFieldState<String>? fieldState = context.findAncestorStateOfType<FormFieldState<String>>();
              final String? errorText = fieldState?.errorText;

              return Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 8.0),
                child: errorText == null
                    ? const SizedBox.shrink()
                    : Text(
                        errorText,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              );
            },
          ),
      ],
    );
  }
}