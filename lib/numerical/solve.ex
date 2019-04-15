defmodule Finance.Numerical do
  alias Finance.Numerical.Root

  @doc """
  Method for solving f(x) = 0

  Using a two phase method which has been tailored to find the internal rate of return from the
  net present value, using the bisection method to move in close to the root, and
  then the Newton Raphson method for rapid convergence.
  """
  def solve(f, fd, guess, tol \\ 1.0e-12, niter1 \\ 2, niter2 \\ 10) do
    with {:ok, lower_bound, upper_bound} <- Root.bracket(f, guess),
         {:ok, est, _iters1} <- Root.bisection(f, lower_bound, upper_bound, tol, niter1),
         {:ok, lower_bound, upper_bound} <- Root.bracket(f, est),
         {:ok, est, _iters2} <- Root.newton_raphson(f, fd, lower_bound, upper_bound, tol, niter2) do
      {:ok, est}
    end
  end
end
