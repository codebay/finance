# Finance

Finance Library for Elixir

## Periodic Cash Flow
An annuity of n regular payments or receipts occurring at evenly spaced periods can be represented by the cash flow:
  ```
  [c0, c1, c2, c3, ....., cn]
  ```

Where the outgoings are represented by negative values, and income by positive values.

Calculates the net present value of a cash flow which is represented by a list of values. Its assumed that the time period between values is constant, e.g. monthly, weekly etc.
  ```
          c1        c2                cn
   c0 +  -----  + ------- + .... + -------- = 0
         1 + i    (1+i)^2          (1+i)^n
  ```

- Simplified functions for periodic fixed amounts
    - Present Value
    - Future Value
    - Payments
    - Number of Payments
    - Rate of Interest per period
- Net Present Value of a periodic cash flow
- Rate conversion IRR to APR, and APR to IRR

## Numerical Methods

- Bracketing the root
- Root finder Bisection Method
- Root finder Raphson-Newton Method


Full test suite with examples.
