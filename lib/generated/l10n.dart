// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class Localization {
  Localization();
  
  static Localization current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<Localization> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      Localization.current = Localization();
      
      return Localization.current;
    });
  } 

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  /// `Initializing`
  String get initializing {
    return Intl.message(
      'Initializing',
      name: 'initializing',
      desc: '',
      args: [],
    );
  }

  /// `Provisioning`
  String get provisioning {
    return Intl.message(
      'Provisioning',
      name: 'provisioning',
      desc: '',
      args: [],
    );
  }

  /// `Please wait a moment`
  String get pleaseWait {
    return Intl.message(
      'Please wait a moment',
      name: 'pleaseWait',
      desc: '',
      args: [],
    );
  }

  /// `Login to Mixin Messenger by QR Code`
  String get pageLandingLoginTitle {
    return Intl.message(
      'Login to Mixin Messenger by QR Code',
      name: 'pageLandingLoginTitle',
      desc: '',
      args: [],
    );
  }

  /// `Open Mixin Messenger on your phone, scan the qr code on the screen and confirm your login.`
  String get pageLandingLoginMessage {
    return Intl.message(
      'Open Mixin Messenger on your phone, scan the qr code on the screen and confirm your login.',
      name: 'pageLandingLoginMessage',
      desc: '',
      args: [],
    );
  }

  /// `CLICK TO RELOAD QR CODE`
  String get pageLandingClickToReload {
    return Intl.message(
      'CLICK TO RELOAD QR CODE',
      name: 'pageLandingClickToReload',
      desc: '',
      args: [],
    );
  }

  /// `Contacts`
  String get contacts {
    return Intl.message(
      'Contacts',
      name: 'contacts',
      desc: '',
      args: [],
    );
  }

  /// `Group`
  String get group {
    return Intl.message(
      'Group',
      name: 'group',
      desc: '',
      args: [],
    );
  }

  /// `Bots`
  String get bots {
    return Intl.message(
      'Bots',
      name: 'bots',
      desc: '',
      args: [],
    );
  }

  /// `Strangers`
  String get strangers {
    return Intl.message(
      'Strangers',
      name: 'strangers',
      desc: '',
      args: [],
    );
  }

  /// `Circle`
  String get circle {
    return Intl.message(
      'Circle',
      name: 'circle',
      desc: '',
      args: [],
    );
  }

  /// `Select a conversation to start messaging`
  String get pageRightEmptyMessage {
    return Intl.message(
      'Select a conversation to start messaging',
      name: 'pageRightEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Chat Backup`
  String get chatBackup {
    return Intl.message(
      'Chat Backup',
      name: 'chatBackup',
      desc: '',
      args: [],
    );
  }

  /// `Data and Storage Usage`
  String get dataAndStorageUsage {
    return Intl.message(
      'Data and Storage Usage',
      name: 'dataAndStorageUsage',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message(
      'About',
      name: 'about',
      desc: '',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: '',
      args: [],
    );
  }

  /// `NO DATA`
  String get noData {
    return Intl.message(
      'NO DATA',
      name: 'noData',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Introduction`
  String get introduction {
    return Intl.message(
      'Introduction',
      name: 'introduction',
      desc: '',
      args: [],
    );
  }

  /// `Phone number`
  String get phoneNumber {
    return Intl.message(
      'Phone number',
      name: 'phoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `{date} join`
  String pageEditProfileJoin(Object date) {
    return Intl.message(
      '$date join',
      name: 'pageEditProfileJoin',
      desc: '',
      args: [date],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<Localization> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<Localization> load(Locale locale) => Localization.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}