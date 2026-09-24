# Polynomial: p(x) = x^8 + x^4 + x^3 + x^2 + 1
#   This is represented by 0x11D in hex (or 100011101)

# Initial Table
to_binary <- function(n) {
  paste(rev(as.integer(intToBits(n))[1:8]), collapse = "")
}
field_table <- data.frame(decimal = 0:255, binary = vapply(0:255, to_binary, character(1)))
View(field_table)
write.csv(field_table, "GF256_table.csv", row.names = FALSE)

# === Math functions ===
# Addition
gf_add <- function(a, b) {
  bitwXor(a, b)
}

# Multiplication
gf_mult <- function(a, b) {
  result <- 0L
  
  while (b > 0L) {
    if (bitwAnd(b, 1L) != 0L) {
      result <- bitwXor(result, a)
    }
    
    b <- bitwShiftR(b, 1L)
    a <- bitwShiftL(a, 1L)
    
    if (a >= 256L) {
      a <- bitwXor(a, 0x11D)
    }
  }
  result
}

# Inverse
gf_inv <- function(b) {
  if (b == 0) stop("Zero has no inverse")
  
  for (candidate in 1:255) {
    if (gf_mult(b, candidate) == 1L) {
      return (candidate)
    }
  }
  
  stop("No inverse found")
}

# Division
gf_div <- function(a, b) {
  gf_mult(a, gf_inv(b))
}

# === Math examples ===
# GF-multiply/GF-divide use polynomial arithmetic modulo 100011101 (0x11D).
# Add
gf_add(58, 41) # 00111010 XOR 00101001 -> 00010011 (19)
gf_add(37, 85) # 00100101 XOR 01010101 -> 01110000 (112)
gf_add(4, 64) # 00000100 XOR 01000000 -> 01000100 (68)

# Multiplication
gf_mult(58, 41) # 00111010 GF-multiply 00101001 -> 11100100 (228)
gf_mult(37, 85) # 00100101 GF-multiply 01010101 -> 01101110 (110)
gf_mult(4, 64) # 00000100 GF-multiply 01000000 -> 00011101 (29)

# Division
gf_div(50, 5) # 00110010 GF-divide 00000101 -> 10101000 (168)
gf_div(85, 37) # 01010101 GF-divide 00100101 -> 00111110 (62)
gf_div(4, 64) # 00000100 GF-divide 01000000 -> 11011000 (216)

# === Generating GF(256) ===
nonzero_elements <- integer(255)
current <- 1L

for (i in 1:255) {
  nonzero_elements[i] <- current
  current <- gf_mult(current, 2L)
}

field_elements <- c(0L, nonzero_elements)
field_table_prog <- data.frame(
  decimal = field_elements,
  binary = vapply(field_elements, to_binary, character(1))
)

# === Verifying GF(256) ===
View(field_table_prog)
write.csv(field_table_prog, "GF256_table_prog.csv", row.names = FALSE)
nrow(field_table_prog)                    # 256
setequal(field_table_prog$decimal, 0:255) # TRUE
current                                   # 1

