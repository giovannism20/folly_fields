
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart' as file;
import 'package:flutter/material.dart';
import 'package:folly_fields/responsive/responsive.dart';


///
///
///
class FileField extends FormFieldResponsive<Uint8List> {
  final FileEditingController? controller;

  ///
  ///
  ///
  FileField({
    String labelPrefix = '',
    String? label,
    Widget? labelWidget,
    this.controller,
    FormFieldValidator<Uint8List?>? validator,
    super.onSaved,
    Uint8List? initialValue,
    super.enabled,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    Function(Uint8List? value)? onChanged,
    bool filled = false,
    Color? fillColor,
    Color? focusColor,
    double? itemHeight,
    InputDecoration? decoration,
    EdgeInsets padding = const EdgeInsets.all(8),
    List<String>? allowedExtensions,
    FileType fileType = FileType.any,
    super.sizeExtraSmall,
    super.sizeSmall,
    super.sizeMedium,
    super.sizeLarge,
    super.sizeExtraLarge,
    super.minHeight,
    super.key,
  })  : assert(
          initialValue == null || controller == null,
          'initialValue or controller must be null.',
        ),
        assert( fileType==FileType.custom || fileType==FileType.any || 
                allowedExtensions==null , 
                'If specifying allowed extensions, fileType '
                'should be FileType.custom',),
        assert(
          itemHeight == null || itemHeight >= kMinInteractiveDimension,
          'itemHeight must be null or equal or greater '
          'kMinInteractiveDimension.',
        ),
        // assert(autofocus != null),
        assert(
          label == null || labelWidget == null,
          'label or labelWidget must be null.',
        ),
        super(
          initialValue: controller != null ? controller.value : initialValue,
          validator: enabled ? validator : (_) => null,
          autovalidateMode: autoValidateMode,
          builder: (FormFieldState<Uint8List?> field) {
            FileFieldState state = field as FileFieldState;
            InputDecoration effectiveDecoration = (decoration ??
                    InputDecoration(
                      border: const OutlineInputBorder(),
                      filled: filled,
                      fillColor: fillColor,
                      label: labelWidget,
                      labelText:
                          labelPrefix.isEmpty ? label : '$labelPrefix - $label',
                      counterText: '',
                      focusColor: focusColor,
                    ))
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            return Padding(
              padding: padding,
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                child: Builder(
                  builder: (BuildContext context) {
                    return InputDecorator(
                      decoration: effectiveDecoration.copyWith(
                        errorText: enabled ? field.errorText : null,
                        enabled: enabled,
                      ),
                      isFocused: Focus.of(context).hasFocus,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        
                        children: [
                          
                          if( state._filename!=null )...[
                            Text( state._filename! ) ,
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.delete),
                              label: const Text('Apagar'),
                              onPressed: enabled
                                ? () {
                                  state
                                    ..didChange(null)
                                    .._filename = null;
                                  if (onChanged != null && state.isValid ){
                                    onChanged(null);
                                  }
                                }
                                : null,
                            ),
                            const SizedBox(width: 8),
                          ],
                          
                          // File select button
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.attach_file),
                              label: const Text('Carregar'),
                              onPressed: enabled
                                ? () async {
                                  allowedExtensions = allowedExtensions
                                    ?.map((String ext){
                                      return ext.startsWith('.')
                                        ? ext.substring(1)
                                        : ext;
                                    }).toList();
                                  file.FilePickerResult? picked 
                                    = await file.FilePicker.platform.pickFiles(
                                      allowedExtensions: allowedExtensions,
                                      type: allowedExtensions!=null 
                                        ? file.FileType.custom 
                                        : fileType.toFilePicker
                                    );
                                  if(picked!=null){
                                    state
                                      ..didChange(picked.files[0].bytes)
                                      .._filename = picked.files[0].name;
                                    if (onChanged != null && state.isValid ){
                                      onChanged(picked.files[0].bytes);
                                    }
                                  }
                                }
                              : null,
                            ),
                          ),

                        ],
                      )
                    );
                  },
                ),
              ),
            );
          },
        );

  ///
  ///
  ///
  @override
  FileFieldState createState() => FileFieldState();
}

///
///
///
class FileFieldState extends FormFieldState<Uint8List> {
  FileEditingController? _controller;
  String? _filename;

  ///
  ///
  ///
  @override
  FileField get widget => super.widget as FileField;

  ///
  ///
  ///
  FileEditingController get _effectiveController =>
      widget.controller ?? _controller!;

  ///
  ///
  ///
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = FileEditingController(
        value: widget.initialValue,
      );
    } else {
      widget.controller!.addListener(_handleControllerChanged);
    }
  }

  ///
  ///
  ///
  @override
  void didUpdateWidget(FileField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);

      widget.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && widget.controller == null) {
        _controller = FileEditingController.fromValue(
          oldWidget.controller!,
        );
      }

      if (widget.controller != null) {
        setValue(widget.controller!.value);

        if (oldWidget.controller == null) {
          _controller = null;
        }
      }
    }
  }

  ///
  ///
  ///
  @override
  void didChange(Uint8List? value) {
    super.didChange(value);
    if (_effectiveController.value != value) {
      _effectiveController.value = value;
    }
  }

  ///
  ///
  ///
  @override
  void reset() {
    super.reset();
    setState(() => _effectiveController.value = widget.initialValue);
  }

  ///
  ///
  ///
  void _handleControllerChanged() {
    if (_effectiveController.value != value) {
      didChange(_effectiveController.value);
    }
  }

  ///
  ///
  ///
  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }
}

///
///
///
class FileEditingController extends ValueNotifier<Uint8List?> {
  
  ///
  ///
  ///
  FileEditingController.fromValue(FileEditingController controller)
      : super(controller.value);

  ///
  ///
  ///
  FileEditingController({Uint8List? value})
      : super(value);


}

enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

extension FileTypeExtension on FileType {
  file.FileType get toFilePicker {
    switch(this){
      case FileType.any: return file.FileType.any;
      case FileType.media: return file.FileType.media;
      case FileType.image: return file.FileType.image;
      case FileType.video: return file.FileType.video;
      case FileType.audio: return file.FileType.audio;
      case FileType.custom: return file.FileType.custom;
    }
  }
}
