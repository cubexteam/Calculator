/// AST для разбора выражений (включая % и научные функции).
sealed class Expr {}

final class NumberExpr extends Expr {
  NumberExpr(this.value);
  final double value;
}

/// N% — процент от внутреннего выражения (например 20 или (10+10)).
final class PercentExpr extends Expr {
  PercentExpr(this.inner);
  final Expr inner;
}

final class UnaryMinus extends Expr {
  UnaryMinus(this.inner);
  final Expr inner;
}

final class BinaryExpr extends Expr {
  BinaryExpr(this.op, this.left, this.right);
  final String op; // + - * / ^
  final Expr left;
  final Expr right;
}

final class FuncExpr extends Expr {
  FuncExpr(this.name, this.arg);
  final String name;
  final Expr arg;
}
