import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:folly_fields/crud/abstract_builder.dart';
import 'package:folly_fields/crud/abstract_model.dart';
import 'package:folly_fields/folly_fields.dart';
import 'package:folly_fields/responsive/responsive_form_field.dart';
import 'package:folly_fields/util/child_builder.dart';
import 'package:folly_fields/widgets/field_group.dart';
import 'package:folly_fields/widgets/folly_dialogs.dart';
import 'package:folly_fields/widgets/table_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sprintf/sprintf.dart';

///
///
///
class ListField<
    T extends AbstractModel<ID>,
    B extends AbstractBuilder<T, ID>,
    ID> extends ResponsiveFormField<List<T>> {
  ///
  ///
  ///
  ListField({
    required List<T> super.initialValue,
    required B builder,
    required Widget Function(BuildContext context, B builder)
        routeAddBuilder,
    Function(BuildContext context, T model, B builder, {required bool edit})?
        routeEditBuilder,
    void Function(List<T> value)? onSaved,
    String? Function(List<T> value)? validator,
    void Function(List<T> value)? onChanged,
    super.enabled,
    AutovalidateMode autoValidateMode = AutovalidateMode.disabled,
    Future<bool> Function(BuildContext context)? beforeAdd,
    Future<bool> Function(BuildContext context, int index, T model)? beforeEdit,
    Future<bool> Function(BuildContext context, int index, T model)?
        beforeDelete,
    String addText = 'Adicionar %s',
    String removeText = 'Deseja remover %s?',
    String clearText = 'Deseja remover todos itens da lista?',
    String emptyListText = 'Sem %s até o momento.',
    InputDecoration? decoration,
    EdgeInsets padding = const EdgeInsets.all(8),
    int Function(T a, T b)? listSort,
    bool expandable = false,
    bool initialExpanded = true,
    bool clearAllButton = false,
    Widget Function(BuildContext context, List<T> value)? onCollapsed,
    bool showCounter = false,
    bool showTopAddButton = false,
    bool showDeleteButton = true,
    bool showAddButton = true,
    String? hintText,
    EdgeInsets? contentPadding,
    Widget? prefix,
    Widget? prefixIcon,
    Widget? suffix,
    Widget? suffixIcon,
    super.sizeExtraSmall,
    super.sizeSmall,
    super.sizeMedium,
    super.sizeLarge,
    super.sizeExtraLarge,
    super.minHeight,
    super.key,
  }) : super(
          onSaved: enabled && onSaved != null
              ? (List<T>? value) => onSaved(value!)
              : null,
          validator: enabled && validator != null
              ? (List<T>? value) => validator(value!)
              : null,
          autovalidateMode: autoValidateMode,
          builder: (FormFieldState<List<T>> field) {
            InputDecoration effectiveDecoration = (decoration ??
                    InputDecoration(
                      labelText: builder.superPlural(field.context),
                      border: const OutlineInputBorder(),
                      counterText: '',
                      enabled: enabled,
                      errorText: field.errorText,
                      hintText: hintText,
                      contentPadding: contentPadding,
                      prefix: prefix,
                      prefixIcon: prefixIcon,
                      suffix: suffix,
                      suffixIcon: suffixIcon,
                    ))
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            String emptyText = sprintf(
              emptyListText,
              <dynamic>[builder.superPlural(field.context)],
            );

            Future<void> add() async {
              if (beforeAdd != null) {
                bool go = await beforeAdd(field.context);
                if (!go) {
                  return;
                }
              }

              dynamic selected = await Navigator.of(field.context).push(
                MaterialPageRoute<dynamic>(
                  builder: (BuildContext context) =>
                      routeAddBuilder(context, builder),
                ),
              );

              if (selected != null) {
                bool changed = false;

                if (selected is List) {
                  for (final T item in selected) {
                    if (item.id == null ||
                        !field.value!
                            .any((T element) => element.id == item.id)) {
                      field.value!.add(item);
                      changed = true;
                    }
                  }
                } else {
                  if ((selected as AbstractModel<ID>).id == null ||
                      !field.value!
                          .any((T element) => element.id == selected.id)) {
                    field.value!.add(selected as T);
                    changed = true;
                  }
                }

                if (changed) {
                  field.value!.sort(
                    listSort ??
                        (T a, T b) => a.toString().compareTo(b.toString()),
                  );

                  onChanged?.call(field.value!);

                  field.didChange(field.value);
                }
              }
            }

            return FieldGroup(
              decoration: effectiveDecoration,
              padding: padding,
              children: <Widget>[
                ExpandableNotifier(
                  initialExpanded: expandable ? initialExpanded : !expandable,
                  child: Column(
                    children: <Widget>[
                      /// Top Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                /// Counter
                                if (showCounter)
                                  Chip(
                                    label: Text(field.value!.length.toString()),
                                  ),

                                /// Top Add Button
                                if (showTopAddButton)
                                  IconButton(
                                    onPressed: add,
                                    icon: const Icon(FontAwesomeIcons.plus),
                                  ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                /// Expand Button
                                if (expandable)
                                  ExpandableButton(
                                    child: ExpandableIcon(
                                      theme: ExpandableThemeData(
                                        iconColor: Theme.of(field.context)
                                            .iconTheme
                                            .color,
                                        collapseIcon: FontAwesomeIcons.compress,
                                        expandIcon: FontAwesomeIcons.expand,
                                        iconSize: 24,
                                        iconPadding: const EdgeInsets.all(4),
                                      ),
                                    ),
                                  ),

                                /// Clear All Button
                                if (clearAllButton)
                                  IconButton(
                                    onPressed: field.value!.isEmpty
                                        ? null
                                        : () {
                                            FollyDialogs.yesNoDialog(
                                              context: field.context,
                                              message: sprintf(
                                                clearText,
                                                <dynamic>[
                                                  builder.superSingle(
                                                    field.context,
                                                  ),
                                                ],
                                              ),
                                            ).then(
                                              (bool del) {
                                                if (del) {
                                                  field.value!.clear();
                                                  onChanged?.call(field.value!);
                                                  field.didChange(field.value);
                                                }
                                              },
                                            );
                                          },
                                    icon: const Icon(FontAwesomeIcons.trashCan),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expandable(
                        collapsed: field.value!.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Text(emptyText),
                              )
                            : onCollapsed == null
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 32,
                                    ),
                                    child: Text(
                                      field.value!.join(' - '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : onCollapsed(field.context, field.value!),
                        expanded: Column(
                          children: <Widget>[
                            if (field.value!.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(emptyText),
                              )
                            else
                              ...field.value!.asMap().entries.map(
                                    (MapEntry<int, T> entry) =>
                                        _MyListTile<T, B, ID>(
                                      field: field,
                                      index: entry.key,
                                      model: entry.value,
                                      builder: builder,
                                      removeText: removeText,
                                      enabled: enabled,
                                      beforeEdit: beforeEdit,
                                      routeEditBuilder: routeEditBuilder,
                                      beforeDelete: beforeDelete,
                                      listSort: listSort,
                                      onChanged: onChanged,
                                      showDeleteButton: showDeleteButton,
                                    ),
                                  ),

                            /// Add Button
                            if (showAddButton)
                              TableButton(
                                enabled: enabled,
                                iconData: FontAwesomeIcons.plus,
                                label: sprintf(
                                  addText,
                                  <dynamic>[
                                    builder.superSingle(field.context),
                                  ],
                                ).toUpperCase(),
                                onPressed: add,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
}

///
///
///
class _MyListTile<T extends AbstractModel<ID>,
    B extends AbstractBuilder<T, ID>, ID> extends StatelessWidget {
  final FormFieldState<List<T>> field;
  final int index;
  final T model;
  final B builder;
  final String removeText;
  final bool enabled;
  final Future<bool> Function(BuildContext context, int index, T model)?
      beforeEdit;
  final Function(
    BuildContext context,
    T model,
    B builder, {
    required bool edit,
  })? routeEditBuilder;
  final Future<bool> Function(BuildContext context, int index, T model)?
      beforeDelete;
  final int Function(T a, T b)? listSort;
  final void Function(List<T> value)? onChanged;
  final bool showDeleteButton;

  ///
  ///
  ///
  const _MyListTile({
    required this.field,
    required this.index,
    required this.model,
    required this.builder,
    required this.removeText,
    required this.enabled,
    required this.beforeEdit,
    required this.routeEditBuilder,
    required this.beforeDelete,
    required this.listSort,
    required this.onChanged,
    required this.showDeleteButton,
    super.key,
  });

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    return ChildBuilder(
      child: ListTile(
        enabled: enabled,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            builder.getLeading(context, model),
          ],
        ),
        title: builder.getTitle(context, model),
        subtitle: builder.getSubtitle(context, model),
        trailing: Visibility(
          visible: FollyFields().isNotMobile && enabled && showDeleteButton,
          child: IconButton(
            icon: const Icon(FontAwesomeIcons.trashCan),
            onPressed: enabled
                ? () => _delete(context, index, model, ask: true)
                : null,
          ),
        ),
        onTap: () async {
          if (beforeEdit != null) {
            bool go = await beforeEdit!(
              field.context,
              index,
              model,
            );
            if (!go) {
              return;
            }
          }

          if (routeEditBuilder != null) {
            T? returned = await Navigator.of(field.context).push(
              MaterialPageRoute<T>(
                builder: (BuildContext context) => routeEditBuilder!(
                  context,
                  model,
                  builder,
                  edit: enabled,
                ),
              ),
            );

            if (returned != null) {
              field.value![index] = returned;

              field.value!.sort(
                listSort ?? (T a, T b) => a.toString().compareTo(b.toString()),
              );

              onChanged?.call(field.value!);

              field.didChange(field.value);
            }
          }
        },
      ),
      builder: (BuildContext context, Widget child) =>
          FollyFields().isNotMobile || !enabled || !showDeleteButton
              ? child
              : Dismissible(
                  key: Key('key_${index}_${model.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: const FaIcon(
                      FontAwesomeIcons.trashCan,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (DismissDirection direction) =>
                      _askDelete(context, index, model),
                  onDismissed: (DismissDirection direction) =>
                      _delete(context, index, model),
                  child: child,
                ),
    );
  }

  ///
  ///
  ///
  Future<void> _delete(
    BuildContext context,
    int index,
    T model, {
    bool ask = false,
  }) async {
    bool del = true;

    if (ask) {
      del = await _askDelete(context, index, model);
    }

    if (del) {
      field.value!.remove(model);

      onChanged?.call(field.value!);

      field.didChange(field.value);
    }
  }

  ///
  ///
  ///
  Future<bool> _askDelete(BuildContext context, int index, T model) async {
    bool canDelete = await beforeDelete?.call(context, index, model) ?? true;

    if (canDelete) {
      return FollyDialogs.yesNoDialog(
        context: context,
        message: sprintf(
          removeText,
          <dynamic>[builder.superSingle(context)],
        ),
      );
    }

    return false;
  }
}
