defmodule Finance.Simple do
  @moduledoc """
  For the simplified case series of regular payments the realtionship between the present value (pv),
  future value (fv), payment (pmt) and rate (i) over a period of (n) time periods is given by:
  ```
                  pmt(1+i)
   pv(1+i)^n +  ------------ + fv = 0
                i(1+i)^n -1
  ```
  This can be solved for each parameter, pv, fv, pmt, i and n.
  """

  @doc """
  Present Value for regular fixed payments.

  If payments made at the end of the periods (default) type = false,
  else if payments are made at the beginning type = true.

  ## Example
  What is the present value (e.g., the initial investment) of an
  investment that needs to total £15692.93 after 10 years of saving
  £100 every month? Assume the interest rate is 5% (annually)
  compounded monthly?

      iex> Finance.Simple.pv(-100, 0.05/Finance.Period.monthly, 10*Finance.Period.monthly, 15692.93) |> Float.round(2)
      -100.00
  """
  def pv(pmt, i, n, fv \\ 0, type \\ false)

  def pv(pmt, _i = 0, n, fv, _type), do:
    -(pmt * n + fv)

  def pv(pmt, i, n, fv, type) when is_boolean(type), do:
    -(pmt * (1.0 + ((type && i) || 0.0)) * pvifa(i, n) + fv * pvif(i, n))

  @doc """
  Future Value for regular fixed payments.

  If payments made at the end of the periods (default) type = true,
  else if payments are made at the beginning type = false.

  ## Example
  What is the future value after 10 years of saving $100 now, with
  an additional monthly savings of $100. Assume the interest rate
  is 5% (annually) compounded monthly?

      iex> Finance.Simple.fv(-100, -100, 0.05/Finance.Period.monthly, 10*Finance.Period.monthly) |> Float.round(2)
      15692.93

  By convention, the negative sign represents cash flow out (i.e. money not
  available today).  Thus, saving £100 a month at 5% annual interest leads
  to £15,692.93 available to spend in 10 years.
  """
  def fv(pv, pmt, i, n, type \\ false)

  def fv(pv, pmt, _i = 0, n, _type), do:
    -(pmt * n + pv)

  def fv(pv, pmt, i, n, type) when is_boolean(type), do:
    -(pmt * (1.0 + ((type && i) || 0.0)) * fvifa(i, n) + pv * fvif(i, n))

  @doc """
  Payment aganist the loan principal plus interest

  If payments made at the end of the periods (default) type = true,
  else if payments are made at the beginning type = false.

  ## Examples
  What is the monthly payment needed to pay off a £200,000 loan in
  15 years at an annual interest rate of 7.5%?

      iex> Finance.Simple.pmt(200000, 0.075/Finance.Period.monthly, 15*Finance.Period.monthly, 0) |> Float.round(2)
      -1854.02

  In order to pay-off (i.e., have a future-value of 0) the $200,000 obtained
  today, a monthly payment of £1,854.02 would be required.  Note that this
  example illustrates usage of `fv` having a default value of 0.

  What is the future value after 10 years of saving $100 now, with
  an additional monthly savings of £100. Assume the interest rate
  is 5% (annually) compounded monthly?

      iex> Finance.Simple.pmt(-100, 0.05/Finance.Period.monthly, 10*Finance.Period.monthly, 15692.93) |> Float.round(2)
      -100.00
  """
  def pmt(pv, i, n, fv \\ 0, type \\ false)

  def pmt(pv, _i = 0, n, fv, _type), do:
    -(fv + pv) / n

  def pmt(pv, i, n, fv, type) when is_boolean(type), do:
    -(fv + pv * fvif(i, n)) / ((1.0 + ((type && i) || 0.0)) * fvifa(i, n))

  @doc """
  Number of payment periods

  ##Example
  If you only had £150/month to pay towards the loan, how long would it take
  to pay-off a loan of £8,000 at 7% annual interest?

      iex> Finance.Simple.nper(8000, -150, 0.07/Finance.Period.monthly) |> Float.round(5)
      64.07335

  So, just over 64 months would be required to pay off the loan.
  """
  def nper(pv, pmt, i, fv \\ 0, type \\ false)

  def nper(pv, pmt, _i = 0, fv, _type), do:
    -(pv + fv) / pmt

  def nper(pv, pmt, i, fv, type) when is_boolean(type) do
    fx = pmt * (1.0 + ((type && i) || 0.0)) / i
    :math.log((-fv + fx) / (pv + fx)) / :math.log(1.0 + i)
  end

  @doc """
  Rate of interest per period

  ##Example
      iex> pmt = Finance.Simple.pmt(-7500, 0.015123, 48)
      iex> {:ok, rate} = Finance.Simple.rate(-7500, pmt, 48)
      iex> Float.round(rate, 6)
      0.015123
  """
  def rate(pv, pmt, n, fv \\ 0, type \\ false) do
    Finance.CashFlow.irr(
      List.flatten([
        pv + ((type && pmt) || 0.0),
        List.duplicate(pmt, n - 1),
        ((type && 0.0) || pmt) + fv
      ])
    )
  end

  defp pvifa(i, n), do:
    (:math.pow(1.0 + i, n) - 1.0) / (i * :math.pow(1.0 + i, n))

  defp pvif(i, n), do:
    1.0 / :math.pow(1.0 + i, n)

  defp fvifa(i, n), do:
    (:math.pow(1.0 + i, n) - 1.0) / i

  defp fvif(i, n), do:
    :math.pow(1.0 + i, n)
end
