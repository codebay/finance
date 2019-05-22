defmodule Finance.Numerical.Root do
  @moduledoc """
  Method for finding the roots of any one-dimensional function
  ```
  f(x) = 0
  ```
  """

  defmodule Finance.Numerical.Iteration do
    @moduledoc false

    defstruct [
      # function f(x)
      :f,
      # first derivative of f(x)
      :fd,
      # minimum value bounding the root
      :lower_bound,
      :flower_bound,
      # current estimated value of x
      :est,
      :fest,
      # maximum value bounding the root
      :upper_bound,
      :fupper_bound,
      # required tolerance
      :tol,
      # number of iterations left
      :left,
      # step size of current iteration
      :dx,
      # step size of previous iteration
      :pdx
    ]
  end

  @doc """
  Find an upper and lower bound around an initial guess that brackets a root.

  ##Example
  The function 3x^2+5x+2 = 0 has two roots at -1 and -2/3

      iex> f = fn(x) -> 3*x*x + 5*x + 2 end
      iex> Finance.Numerical.Root.bracket(f, -0.7)
      {:ok, -0.71, -0.6579999999999999}
  """

  @default_bracket_precision 2
  @bracket_step_size 1.6

  def bracket(f, guess, precision \\ @default_bracket_precision) do
    dt = :math.pow(10.0, round(:math.log10(abs(guess == 0.0 && 1.0 || guess))) - precision)
    bracket_step(f, guess - dt, f.(guess - dt), guess + dt, f.(guess + dt), 10)
  end

  defp bracket_step(_f, _l, _fl, _u, _fu, _niter = 0) do
    {:error, "Unable to find a possible root around the guess"}
  end

  defp bracket_step(_f, l, fl, u, fu, _niter) when fl * fu < 0.0 do
    {:ok, l, u}
  end

  defp bracket_step(f, l, fl, u, fu, niter) when abs(fl) <  abs(fu) do
    x = l + @bracket_step_size * (l - u)
    bracket_step(f, x, f.(x), u, fu, niter - 1)
  end

  defp bracket_step(f, l, fl, u, _fu, niter) do
    x = u + @bracket_step_size *(u - l)
    bracket_step(f, l, fl, x, f.(x), niter - 1)
  end

  @doc """
  Bisection method iteratively finds the root of a function
  by the process of successively reducing the initial bounds. In
  iteration step the bounds sizes will reduce by half, thus the
  number iterations required to achieve a given tolerance (t) given
  the initial bounds size (e) is given by

               n = log2(e/t)

  If the initial bounds encompass one of more roots the bisection
  method will converge to one of these roots.

  This method has a preset function which will quit after 40 iterations and
  should achieve a tolerance of about 1e-12, i.e 2^-40 ~ 1e-12

  ##Examples
  The function 3x^2+5x+2 = 0 has two roots at -1 and -2/3

      iex> f = fn(x) -> 3*x*x + 5*x + 2 end
      iex> {:ok, root, niter}  = Finance.Numerical.Root.bisection(f, -1.2, -0.7)
      iex> Float.round(root, 12)
      -1.0
      iex> niter
      39
      iex> {:ok, root, niter}  = Finance.Numerical.Root.bisection(f, -0.7, 0.0)
      iex> Float.round(root, 12)
      -0.666666666667
      iex> niter
      40
  """

  @default_bisection_tolerance 1.0e-12
  @default_bisection_max_iterations 41

  def bisection(f, lower_bound, upper_bound, tolerance \\ @default_bisection_tolerance, niters \\ @default_bisection_max_iterations) when lower_bound < upper_bound do
    est = (lower_bound + upper_bound) / 2.0

    bisection(
      %Finance.Numerical.Iteration{
        f: f,
        lower_bound: lower_bound,
        flower_bound: f.(lower_bound),
        est: est,
        fest: f.(est),
        upper_bound: upper_bound,
        fupper_bound: f.(upper_bound),
        tol: tolerance,
        left: niters
      },
      niters
    )
  end

  defp bisection(iter = %Finance.Numerical.Iteration{}, niters) do
    case bisection_step(iter) do
      {:ok, est, left} -> {:ok, est, niters - left}
      {:error, msg} -> {:error, msg}
    end
  end

  defp bisection_step(%Finance.Numerical.Iteration{lower_bound: lower_bound, est: est, upper_bound: upper_bound, tol: tol, left: left})
       when abs(upper_bound - lower_bound) <= tol, do:
    {:ok, est, left}

  defp bisection_step(%Finance.Numerical.Iteration{est: est, left: 0}), do:
    {:ok, est, 0}

  defp bisection_step(%Finance.Numerical.Iteration{flower_bound: flower_bound, fupper_bound: fupper_bound}) when flower_bound * fupper_bound > 0, do:
    {:error, "lower_bound and upper_bound do not bracket a root, or possibly bracket multiple roots"}

  defp bisection_step(
         iter = %Finance.Numerical.Iteration{f: f, flower_bound: flower_bound, est: est, fest: fest, upper_bound: upper_bound, left: left}
       )
       when flower_bound * fest > 0.0 do
    nest = (est + upper_bound) / 2.0

    bisection_step(%Finance.Numerical.Iteration{
      iter
      | lower_bound: est,
        flower_bound: fest,
        est: nest,
        fest: f.(nest),
        left: left - 1
    })
  end

  defp bisection_step(iter = %Finance.Numerical.Iteration{f: f, lower_bound: lower_bound, est: est, fest: fest, left: left}) do
    nest = (lower_bound + est) / 2.0

    bisection_step(%Finance.Numerical.Iteration{
      iter
      | est: nest,
        fest: f.(nest),
        upper_bound: est,
        fupper_bound: fest,
        left: left - 1
    })
  end

  @doc """
  Newton Raphson method requires the evaluation of both the function f(x) and its derivative.
  The method can display a very rapid convergence to the root, however it can be become unstable
  when the initial estimate is too close to any local lower_bound or upper_bound minima. There is also the
  possibility that the method can get trapped in a non-convergent cycle.

  ##Examples
      The function 3x^2+5x+2 = 0 has two roots at -1 and -2/3

          iex> f = fn(x) -> 3*x*x + 5*x + 2 end
          iex> fd = fn(x) -> 6*x + 5 end
          iex> {:ok, root, iters}  = Finance.Numerical.Root.newton_raphson(f, fd, -1.3, -0.9)
          iex> Float.round(root, 12)
          -1.0
          iex> iters
          5
          iex> {:ok, root, iters}  = Finance.Numerical.Root.newton_raphson(f, fd, -0.7, 0.0)
          iex> Float.round(root, 12)
          -0.666666666667
          iex> iters
          6
  """

  @default_newton_raphson_tolerance 1.0e-12
  @default_newton_raphson_max_iterations 10

  def newton_raphson(f, fd, lower_bound, upper_bound, tolerance \\ @default_newton_raphson_tolerance, niters \\ @default_newton_raphson_max_iterations) when lower_bound < upper_bound do
    est = (lower_bound + upper_bound) / 2.0
    fest = f.(est)

    newton_raphson(
      %Finance.Numerical.Iteration{
        f: f,
        fd: fd,
        lower_bound: lower_bound,
        flower_bound: f.(lower_bound),
        est: est,
        fest: fest,
        upper_bound: upper_bound,
        fupper_bound: f.(upper_bound),
        tol: tolerance,
        left: niters,
        dx: newton_raphson_dx(fest, fd.(est)),
        pdx: (upper_bound - lower_bound) / 2.0
      },
      niters
    )
  end

  defp newton_raphson_dx(_fest, _fdest = 0.0), do: 0.0

  defp newton_raphson_dx(fest, fdest), do:
    fest / fdest

  defp newton_raphson(iter = %Finance.Numerical.Iteration{}, niters) do
    case newton_raphson_step(iter) do
      {:ok, est, left} -> {:ok, est, niters - left}
      {:error, msg} -> {:error, msg}
    end
  end

  defp newton_raphson_step(%Finance.Numerical.Iteration{flower_bound: flower_bound, fupper_bound: fupper_bound})
       when flower_bound * fupper_bound > 0.0, do:
    {:error, "lower_bound and upper_bound do not bracket a root, or possibly bracket multiple roots"}

  defp newton_raphson_step(%Finance.Numerical.Iteration{lower_bound: lower_bound, est: est, upper_bound: upper_bound})
       when (lower_bound - est) * (est - upper_bound) < 0.0, do:
    {:error, "stepped outside of initial bounds"}

  defp newton_raphson_step(%Finance.Numerical.Iteration{est: est, left: left, tol: tol, dx: dx})
       when abs(dx) <= tol, do:
    {:ok, est, left}

  defp newton_raphson_step(%Finance.Numerical.Iteration{est: est, left: 0}), do:
    {:ok, est, 0}

  defp newton_raphson_step(iter = %Finance.Numerical.Iteration{f: f, fd: fd, est: est, dx: dx, left: left}) do
    nest = est - dx
    pdx = dx
    fest = f.(nest)

    newton_raphson_step(%Finance.Numerical.Iteration{
      iter
      | est: nest,
        fest: fest,
        left: left - 1,
        dx: newton_raphson_dx(fest, fd.(nest)),
        pdx: pdx
    })
  end
end
