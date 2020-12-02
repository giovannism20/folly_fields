import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:folly_fields/widgets/string_field.dart';

///
///
///
class PasswordField extends StringField {
  ///
  ///
  ///
  PasswordField({
    Key key,
    String prefix,
    String label,
    TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    FormFieldValidator<String> validator,
    List<TextInputFormatter> inputFormatter,
    TextAlign textAlign = TextAlign.start,
    int maxLength,
    FormFieldSetter<String> onSaved,
    String initialValue,
    bool enabled = true,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    ValueChanged<String> onChanged,
    FocusNode focusNode,
    TextInputAction textInputAction,
    ValueChanged<String> onFieldSubmitted,
    bool autocorrect = true,
    bool enableSuggestions = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    bool filled = false,
  }) : super(
          key: key,
          prefix: prefix,
          label: label,
          controller: controller,
          keyboard: keyboard,
          validator: validator,
          minLines: 1,
          maxLines: 1,
          obscureText: true,
          inputFormatter: inputFormatter,
          textAlign: textAlign,
          maxLength: maxLength,
          onSaved: onSaved,
          initialValue: initialValue,
          enabled: enabled,
          autoValidateMode: autoValidateMode,
          onChanged: onChanged,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          textCapitalization: textCapitalization,
          scrollPadding: scrollPadding,
          enableInteractiveSelection: enableInteractiveSelection,
          filled: filled,
        );
}