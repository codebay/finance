defmodule Finance.CashFlow do
  @moduledoc """
  An annunity of n regular payments or receipts occuring at evenly spaced periods
  can be represented by the cash flow:
  ```
  [c0, c1, c2, c3, ....., cn]
  ```
  Where the outgoings are represented by negative values, and income by positive values.

  Calculates the net present value of a cash flow which is represented by
  a list of values. Its assumed that the time period between values is
  constant, e.g. monthly, weekly etc.
  ```
          c1        c2                cn
   c0 +  -----  + ------- + .... + -------- = 0
         1 + i    (1+i)^2          (1+i)^n
  ```

  ## Example
  From UK OFT document OFT144.pdf

  A borrower is advanced £7,500 on 15 August 2000, to be repaid over
  48 months by equal monthly instalments. The first instalment is to be paid on
  15 November 2000 and the lender requires a £25 administration fee to be paid
  at the same time. Interest will be charged monthly on the outstanding balance
  at one-twelfth of the lender’s variable annual base rate plus 4%. The base rate
  is 9.5% at the time the agreement is made.

  Although the lenders rate is variable we assume for now that its fixed for the
  duration of this loan at 4%.

  Annual interest rate = 9.5% + 4% = 13.5%.

  So the monthly interest is charged is:
  ```
  i = 13.5% / 12 = 1.125%
  ```
  No payments are made for the first two month but interest is charged on the advance
  giving a future value: 7500*(1+0.01125)^2 = 7669.69921875

      iex> Finance.Simple.fv(7500, 0, 0.01125, 2)
      -7669.69921875

  This value can be used as an adjusted advance for a 48 month payment period, in which
  we ignore the one-off admin fee.
  ```
                       P            P                       P
  -7669.69921875 + --------- + ------------- + .... + -------------- = 0
                   1+0.01125   (1+0.01125)^2          (1+0.01125)^48
  ```
      iex> Finance.Simple.pmt(-7669.69921875, 0.01125, 48) |> Float.round(2)
      207.67

  The customer will pay £207.67 for 48 months, however as this has been rounded up to
  two decimal places, the customer will end up paying back slightly to much. The
  difference can be determined by calulating the future value of the loan with a
  payment of £207.67, which if correct would give a value of zero.

      iex> Finance.Simple.fv(-7669.69921875, 207.67, 0.01125, 48) |> Float.round(2)
      -0.17

  So the final payment will be need to be adjusted by 17p i.e. 207.67 - 0.17
   = £207.50 to compensate.

  Now we have payments, a cashflow can be constructed
  ```
  c0  = -£7500                       advance
  c1  = c2 = 0.0                     2 months deferred payment
  c3  = £207.67 + £25                payment + admin fee
  c4  = c5 = .... = c49 = £207.67    46 payments
  c50 = £207.50                      final payment

  Which can be solved to obtain the internal rate of return (irr)
  ```
      iex> c = List.flatten([[-7500, 0, 0, 232.67], List.duplicate(207.67, 46), 207.50])
      iex> {:ok, root} = Finance.CashFlow.irr(c)
      iex> Float.round(root, 12)
      0.011384044595

  Finally given that the time periods of the payments is monthly, the APR can be determined.

      iex> Finance.Rate.irr2apr(0.011384044595, Finance.Period.monthly) |> Float.round(1)
      14.5
  """

  alias Finance.Numerical

  @doc """
  Net Present Value of an arbitary cash flow

  ## Example
  From http://www.financeformulas.net/Net_Present_Value.html

  | Year | Cash Flow | Present Value
  | 0    | -£500,000 | -£500,000
  | 1    |  £200,000 | £181,818.18
  | 2    |  £300,000 | £247,933.88
  | 3    |  £200,000 | £150,262.96

  Net Present Value = £80,015.03    @ 10%

      iex> Finance.CashFlow.npv([-500000, 200000, 300000, 200000], 0.1) |> Float.round(2)
      80015.03
  """
  def npv(c, irr) do
    f = 1.0 / (1.0 + irr)

    {npv, _} =
      Enum.reduce(c, {0.0, 1.0}, fn x, {s, fm} ->
        {s + fm * x, fm * f}
      end)

    npv
  end

  @doc """
  First Derivative of the Net Present Value
  ```
               v1         2 * v2
  dpv =  - ----------- - ----------- - .....
           (1 + irr)^2   (1 + irr)^3
  ```
  ## Example
      iex> Finance.CashFlow.dnpv([-500000, 200000, 300000, 200000], 0.1) |> Float.round(2)
      -1025886.21
  """
  def dnpv(c, irr) do
    f = 1.0 / (1.0 + irr)

    {dnpv, _, _} =
      Enum.reduce(c, {0.0, 0.0, f}, fn x, {s, i, fm} ->
        {s - i * fm * x, i + 1.0, fm * f}
      end)

    dnpv
  end

  @doc """
  Internal Rate of Return IRR
  """

  @default_irr_guess 0.1

  def irr(c, guess \\ @default_irr_guess) do
    npv = fn c ->
      fn i -> npv(c, i) end
    end

    dnpv = fn c ->
      fn i -> dnpv(c, i) end
    end

    Numerical.solve(npv.(c), dnpv.(c), guess)
  end
end
