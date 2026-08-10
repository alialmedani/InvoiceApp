import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

bool isRtl(BuildContext context) =>
    Directionality.of(context) == TextDirection.rtl;
