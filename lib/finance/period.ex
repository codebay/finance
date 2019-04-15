defmodule Finance.Period do
  @moduledoc """
  Time Periods
  """

  @doc """
  Annual time period
  """
  def annual, do: 1.0

  @doc """
  Monthly time period
  """
  def monthly, do: 12.0

  @doc """
  Weekly time period
  """
  def weekly, do: 52.0

  @doc """
  Daily time period
  """
  def daily, do: 365.0
end
