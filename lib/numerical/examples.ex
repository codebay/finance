defmodule Finance.Numerical.Examples do
  @moduledoc """
  Collection of example functions for testing.
  """

  @doc """
  The function 3x^2 + 5x + 2 has two roots at -1 and -2/3
  """
  def f1(x), do:
    3 * x * x + 5 * x + 2

  @doc """
  First Derivative of f1(x)
  """
  def fd1(x), do:
    6.0 * x + 5.0

  @doc """
  The function x^3 - 2x + 2 if the initial estimate is 0 or 1
  displays 2-cyclic behaviour, and no convergence

  step(0) = 0 - 2/-2 -> 1
  step(1) = 1 - 1 -> 0
  step(0) = ....
  """
  def f2(x), do:
    x * x * x - 2.0 * x + 2.0

  @doc """
  First Derivative of f2(x)
  """
  def fd2(x), do:
    3.0 * x * x - 2.0

  @doc """
  The function 1 -x^2 has roots at +/-1, and upper_boundimum at 0. The zero derivative at
  0 leads division by zero and any iteration point close to 0 will lead to a far
  worse approximation.
  """
  def f3(x), do:
    1.0 - x * x

  @doc """
  First Derivative of f3(x)
  """
  def fd3(x), do:
    -2.0 * x
end
