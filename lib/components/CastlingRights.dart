// Optional: Rechte & EP-Ziel per Args mitgeben, ohne dein gesamtes Design umzubauen.
class CastlingRights {
  bool wk; // Weiß kurze Rochade
  bool wq; // Weiß lange Rochade
  bool bk; // Schwarz kurze Rochade
  bool bq; // Schwarz lange Rochade
  CastlingRights({required this.wk, required this.wq, required this.bk, required this.bq});
}