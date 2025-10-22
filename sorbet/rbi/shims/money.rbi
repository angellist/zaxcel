# DO NOT require this file; Sorbet reads RBIs automatically
# typed: true

class NilClass
  sig { params(currency: T.nilable(T.any(String, Money::Currency))).returns(Money) }
  def to_money(currency = nil); end
end

class Money
  class << self
    sig { params(currency: T.any(String, Money::Currency)).returns(Money) }
    def zero(currency = Money.default_currency); end
  end

  sig { returns(Money) }
  def abs; end

  sig { params(currency: T.any(String, Money::Currency)).returns(Money) }
  def to_money(currency = Money.default_currency); end

  sig { returns(Integer) }
  def cents; end

  sig { returns(Integer) }
  def fractional; end

  sig { returns(Money::Currency) }
  def currency; end

  sig { returns(BigDecimal) }
  def to_d; end

  sig { params(other: Money).returns(Money) }
  def +(other); end

  sig { params(other: Money).returns(Money) }
  def -(other); end

  sig { params(other: Numeric).returns(Money) }
  def *(other); end

  sig { returns(T::Boolean) }
  def positive?; end

  sig { returns(T::Boolean) }
  def nonzero?; end

  sig { returns(T::Boolean) }
  def zero?; end

  sig { returns(T::Boolean) }
  def negative?; end

  module Bank
    class OpenExchangeRatesBank < Money::Bank::VariableExchange; end

    class Historical
      class << self
        sig { returns(Money::Bank::Historical) }
        def instance; end
      end

      sig { params(local_amount: Money, non_precision_to_currency_code: String, historical_date: Date).returns(Money) }
      def exchange_with_historical(local_amount, non_precision_to_currency_code, historical_date); end

      sig do
        params(
          from_currency_code: String,
          to_currency_code: String,
          date: T.nilable(Date),
        ).returns(T.any(Integer, Float, BigDecimal))
      end
      def get_rate(from_currency_code, to_currency_code, date = nil); end
    end
  end

  class Currency
    sig { returns(String) }
    def iso_code; end
  end
end

# typed: true
# frozen_string_literal: true

class NilClass
  sig { params(currency: T.nilable(T.any(String, Money::Currency))).returns(Money) }
  def to_money(currency = nil); end
end

class Money
  class << self
    sig { params(currency: T.any(String, Money::Currency)).returns(Money) }
    def zero(currency = Money.default_currency); end
  end

  sig { returns(Money) }
  def abs; end

  sig { params(currency: T.any(String, Money::Currency)).returns(Money) }
  def to_money(currency = Money.default_currency); end

  sig { returns(Integer) }
  def cents; end

  sig { returns(Integer) }
  def fractional; end

  sig { returns(Money::Currency) }
  def currency; end

  sig { returns(BigDecimal) }
  def to_d; end

  sig { params(other: Money).returns(Money) }
  def +(other); end

  sig { params(other: Money).returns(Money) }
  def -(other); end

  sig { params(other: Numeric).returns(Money) }
  def *(other); end

  sig { returns(T::Boolean) }
  def positive?; end

  sig { returns(T::Boolean) }
  def nonzero?; end

  sig { returns(T::Boolean) }
  def zero?; end

  sig { returns(T::Boolean) }
  def negative?; end

  module Bank
    class OpenExchangeRatesBank < Money::Bank::VariableExchange; end

    class Historical
      class << self
        sig { returns(Money::Bank::Historical) }
        def instance; end
      end

      sig { params(local_amount: Money, non_precision_to_currency_code: String, historical_date: Date).returns(Money) }
      def exchange_with_historical(local_amount, non_precision_to_currency_code, historical_date); end

      sig do
        params(
          from_currency_code: String,
          to_currency_code: String,
          date: T.nilable(Date),
        ).returns(T.any(Integer, Float, BigDecimal))
      end
      def get_rate(from_currency_code, to_currency_code, date = nil); end
    end
  end

  class Currency
    sig { returns(String) }
    def iso_code; end
  end
end
