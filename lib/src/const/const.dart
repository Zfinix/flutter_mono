/// Event names corespond to the type key returned by the raw event data
class MonoConnectEvent {
  /// Triggered when the user opens the Connect Widget.
  static const OPENED = 'OPENED';

  /// Triggered when the user closes the Connect Widget.
  static const EXIT = 'EXIT';

  /// Triggered when the Connect Widget loads
  static const LOADED = 'LOADED';

  /// Triggered when the user selects an institution.
  static const INSTITUTION_SELECTED = 'INSTITUTION_SELECTED';

  /// Triggered when the user changes authentication method from internet to mobile banking, or vice versa.
  static const AUTH_METHOD_SWITCHED = 'AUTH_METHOD_SWITCHED';

  /// Triggered when the user presses Log in.
  static const SUBMIT_CREDENTIALS = 'SUBMIT_CREDENTIALS';

  /// Triggered when the user submits token.
  static const SUBMIT_MFA = 'SUBMIT_MFA';

  /// Triggered when the user submits a wrong token.
  static const MFA_FAILED = 'MFA_FAILED';

  /// Triggered when the user successfully links their account.
  static const ACCOUNT_LINKED = 'ACCOUNT_LINKED';

  /// Triggered when the user selects a new account.
  static const ACCOUNT_SELECTED = 'ACCOUNT_SELECTED';

  /// Triggered when the widget reports an error.
  static const ERROR = 'ERROR';
}
