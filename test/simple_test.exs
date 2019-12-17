defmodule Finance.SimpleTest do
  use ExUnit.Case
  doctest Finance.Simple

  alias Finance.Period
  alias Finance.Simple

  test "pv with payment at start of the period" do
    assert_in_delta Simple.pv(
                      -100,
                      0.05 / Period.monthly(),
                      10 * Period.monthly(),
                      15692.93,
                      true
                    ),
                    -60.72,
                    1.0e-2
  end

  test "fv with payment at start of the period" do
    assert_in_delta Simple.fv(
                      -60.72,
                      -100.0,
                      0.05 / Period.monthly(),
                      10 * Period.monthly(),
                      true
                    ),
                    15692.93,
                    1.0e-2
  end

  test "pmt at start of the period" do
    assert_in_delta Simple.pmt(
                      -60.72,
                      0.05 / Period.monthly(),
                      10 * Period.monthly(),
                      15692.93,
                      true
                    ),
                    -100.0,
                    1.0e-2
  end

  test "nper with payment at the start of the period" do
    assert_in_delta Simple.nper(-60.72, -100, 0.05 / Period.monthly(), 15692.93, true),
                    120.0,
                    1.0e-2
  end

  test "nper simple example" do
    assert_in_delta Simple.nper(1000, -100, 0.05), 14.2067, 1.0e-4
  end

  test "nper simple example with non-zerp fv" do
    assert_in_delta Simple.nper(1000, -100, 0.05, 100), 15.2067, 1.0e-4
  end

  test "nper simple example and payment at beginning of period" do
    assert_in_delta Simple.nper(1000, -100, 0.05, 100, true), 14.2067, 1.0e-4
  end

  test "nper with rate zero" do
    assert Simple.nper(1000, -100, 0) == 10.0
  end

  test "nper with negative rate" do
    assert_in_delta Simple.nper(1000, -100, -0.01), 9.483283066, 1.0e-6
  end

  test "rate with fv value" do
    pmt = Finance.Simple.pmt(-7500, 0.015123, 48, 2000)

    with {:ok, rate} <- Finance.Simple.rate(-7500, pmt, 48, 2000) do
      assert_in_delta rate, 0.015123, 1.0e-6
    else
      {:error, msg} -> flunk(msg)
    end
  end

  test "rate with fv value, and payment at the beginning of the periods" do
    pmt = Finance.Simple.pmt(-7500, 0.015123, 48, 2000, true)

    with {:ok, rate} <- Finance.Simple.rate(-7500, pmt, 48, 2000, true) do
      assert_in_delta Float.round(rate, 6), 0.015123, 1.0e-6
    else
      {:error, msg} -> flunk(msg)
    end
  end
end
