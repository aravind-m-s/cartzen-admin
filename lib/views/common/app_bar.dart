import 'package:cartzen_admin/Core/constants.dart';
import 'package:flutter/material.dart';

customAppBar({required String title, required BuildContext context}) {
  return PreferredSize(
    preferredSize: const Size(double.infinity, 75),
    child: AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(defaultRadius * 2),
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  );
}
