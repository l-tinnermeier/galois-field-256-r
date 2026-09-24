# GF(256) in R

An educational implementation of arithmetic in the finite field GF(256), also written GF(2^8), using base R. The project demonstrates addition, multiplication, multiplicative inverses, division, and generation of all 256 field elements.

## Field representation

Each element is stored as an integer from `0` to `255`. Its eight binary digits represent polynomial coefficients over GF(2): the rightmost bit is the constant term, and the leftmost bit is the coefficient of x^7. For example, `00000101` represents x^2 + 1.

Multiplication is reduced modulo:

```text
p(x) = x^8 + x^4 + x^3 + x^2 + 1
Hex:    0x11D
Binary: 100011101
```

Polynomial coefficients are computed modulo 2. Addition is therefore bitwise XOR, and subtraction is identical to addition. Multiplication and division are field operations, not ordinary integer arithmetic or arithmetic modulo 256.

For example, multiplying `4` by `64` represents x^2 times x^6 = x^8. Reducing by p(x) gives x^4 + x^3 + x^2 + 1, or `00011101` (`29`).

## Files

| File | Purpose |
| --- | --- |
| `GaloisFields.Rproj` | RStudio project file. |
| `main.R` | Field arithmetic, worked examples, table generation, and verification. |
| `GF256_table.csv` | All elements in decimal order, from 0 through 255. |
| `GF256_table_prog.csv` | Zero followed by the successive powers of 2 in the field. |

Both CSV files contain `decimal` and `binary` columns.

## Running the project

Use R with RStudio. No additional R packages are required.

1. Open `GaloisFields.Rproj` in RStudio.
2. Open `main.R`.
3. Run the script's sections interactively, or run this in the Console to display the example expressions and their results:

   ```r
   source("main.R", echo = TRUE)
   ```

The script opens two table viewers with `View()` and writes both CSV files into the current working directory, replacing existing files with those names. Opening the RStudio project sets the working directory to the project folder; check it with `getwd()` if needed.

For a noninteractive environment, omit or guard the two `View()` calls, since a table viewer may be unavailable.

## Functions

| Function | Behavior |
| --- | --- |
| `to_binary(n)` | Formats a field element as an eight-character binary string. |
| `gf_add(a, b)` | Adds two field elements with bitwise XOR. |
| `gf_mult(a, b)` | Multiplies using shifts and XOR, reducing by `0x11D`. |
| `gf_inv(b)` | Searches `1:255` for an element whose product with `b` is 1. |
| `gf_div(a, b)` | Multiplies `a` by the multiplicative inverse of `b`. |

Supply one integer from `0` through `255` per argument. The arithmetic functions do not validate all invalid inputs. Zero has no multiplicative inverse: `gf_inv(0)` and division by zero raise an error.

The inverse search is intentionally straightforward and suitable for this small educational example.

## Expected example results

The comments beside the examples in `main.R` show eight-bit operands and results. `GF-multiply` and `GF-divide` refer to operations using the polynomial above.

| Expression | Decimal result | Binary result |
| --- | ---: | --- |
| `gf_add(58, 41)` | 19 | `00010011` |
| `gf_add(37, 85)` | 112 | `01110000` |
| `gf_add(4, 64)` | 68 | `01000100` |
| `gf_mult(58, 41)` | 228 | `11100100` |
| `gf_mult(37, 85)` | 110 | `01101110` |
| `gf_mult(4, 64)` | 29 | `00011101` |
| `gf_div(50, 5)` | 168 | `10101000` |
| `gf_div(85, 37)` | 62 | `00111110` |
| `gf_div(4, 64)` | 216 | `11011000` |

## Generating and checking the field

Starting from `1`, the script repeatedly multiplies by `2`, which represents x. For the chosen polynomial, this visits all 255 nonzero elements exactly once before returning to `1`. The script prepends zero to form the complete field table.

The final expressions in `main.R` should produce:

```r
nrow(field_table_prog)                    # 256
setequal(field_table_prog$decimal, 0:255)  # TRUE
current                                  # 1
```

After running the script, these additional assertions check the generation cycle, inverses, and division round trips. They finish silently when all checks pass:

```r
stopifnot(
  length(unique(nonzero_elements)) == 255L,
  setequal(nonzero_elements, 1:255),
  current == 1L
)

for (b in 1:255) {
  stopifnot(gf_mult(b, gf_inv(b)) == 1L)
  stopifnot(gf_mult(gf_div(50L, b), b) == 50L)
}
```
