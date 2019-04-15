defmodule Finance.Rate do
  @moduledoc """
  Rate conversion functions

  The APR is the annual rate charged for borrowing or earned through an investment, and is expressed as a percentage that represents
  the actual yearly cost of funds over the term of a loan. This includes any fees or additional costs associated with the transaction
  but does not take compounding into account. As loans or credit agreements can vary in terms of interest-rate structure, transaction
  fees, late penalties and other factors, a standardized computation such as the APR provides borrowers with a bottom-line number they
  can easily compare to rates charged by other lenders.
  The APR is expressed as an annual percentage rate.
  """

  @doc """
  Convert internal rate of return into an APR value, where t is the time period of the internal rate of return.
  """
  def irr2apr(_irr = 0, _t) do
    0.0
  end

  def irr2apr(irr, t) do
    (:math.pow(1.0 + irr, t) - 1.0) * 100.0
  end

  @doc """
  Convert APR to an internal rate of return, where t is the time period of the internal rate
  """
  def apr2irr(_apr = 0, _t) do
    0.0
  end

  def apr2irr(apr, t) do
    :math.pow(1.0 + apr / 100.0, 1.0 / t) - 1.0
  end
end
