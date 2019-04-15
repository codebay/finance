defmodule Finance.Numerical.RootTest do
  use ExUnit.Case
  doctest Finance.Numerical.Root

  alias Finance.Numerical.Root, as: Root
  alias Finance.Numerical.Examples, as: Ex

  test "bisection - root outside the bounds to the right" do
    assert Root.bisection(&Ex.f1/1, -3, -2) ==
             {:error, "lower_bound and upper_bound do not bracket a root, or possibly bracket multiple roots"}
  end

  test "bisection - root outside the bounds to the left" do
    assert Root.bisection(&Ex.f1/1, 2, 5) ==
             {:error, "lower_bound and upper_bound do not bracket a root, or possibly bracket multiple roots"}
  end

  test "bisection - bounds encompass two roots" do
    assert Root.bisection(&Ex.f1/1, -3, 2) ==
             {:error, "lower_bound and upper_bound do not bracket a root, or possibly bracket multiple roots"}
  end

  test "bisection - maximum number of retries" do
    {:ok, est, 2} =
      Root.bisection(&Ex.f1/1, -0.9, 0, 1.0e-12, 2)

    assert Float.round(est, 4) == -0.5625
  end

  # est = (-0.6 + (-0.8)) / 2 = -0.7
  # f1(-0.7) = 3 * (-0.7) * (-0.7) + 5 * (-0.7) + 2 = -0.03
  # fd1(-0.7) = 6 * (-0.7) + 5 = 0.8
  # N(1) = (-0.7) - (-0.03)/0.8 = -0.6625
  test "newton raphson - maximum number of retries" do
    {:ok, est, 1} =
      Root.newton_raphson(&Ex.f1/1, &Ex.fd1/1, -0.8, -0.6, 1.0e-12, 1)

    assert Float.round(est, 4) == -0.6625
  end

  test "newton raphson - maximum number of retries when iterations cycle" do
    assert Root.newton_raphson(&Ex.f2/1, &Ex.fd2/1, -2, 2, 1.0e-12, 10) ==
             {:ok, 0.0, 10}
  end

  test "newton raphson - iteration from stationary point" do
    assert Root.newton_raphson(&Ex.f3/1, &Ex.fd3/1, -2, 2, 1.0e-12, 10) ==
             {:error, "lower_bound and upper_bound do not bracket a root, or possibly bracket multiple roots"}
  end

  test "newton raphson - iteration from a point close to a stationary point" do
    assert Root.newton_raphson(&Ex.f3/1, &Ex.fd3/1, -1.1, 0.9, 1.0e-12, 10) ==
             {:error, "stepped outside of initial bounds"}
  end
end
