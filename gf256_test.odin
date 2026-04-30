package gf256

import gf "./"
import "core:fmt"
import "core:math/rand"
import "core:testing"

ROUNDS :: 1000

@(test)
tables :: proc(t: ^testing.T) {
	init()
	for i in 0 ..< MULT_GROUP_SIZE {
		testing.expect_value(t, log3_table[exp3_table[i]], u8(i))
	}
	for i in 1 ..< MULT_GROUP_SIZE + 1 {
		testing.expect_value(t, exp3_table[log3_table[i]], u8(i))
	}
}

@(test)
identities :: proc(t: ^testing.T) {
	init()
	for i in 0 ..< ROUNDS {
		a := u8(rand.uint_range(1, 1 << 8))
		b := u8(rand.uint_range(1, 1 << 8))
		testing.expect_value(t, sub(a, a), 0)
		testing.expect_value(t, sub(a, 0), a)

		testing.expect_value(t, add(a, 0), a)
		testing.expect_value(t, add(0, a), a)

		if a != 0 {
			testing.expect_value(t, div(a, a), 1)
			testing.expect_value(t, div(0, a), 0)
		}
		testing.expect_value(t, div(a, 1), a)

		testing.expect_value(t, mult(a, 1), a)
		testing.expect_value(t, mult(1, a), a)
		testing.expect_value(t, mult(0, a), 0)

		a_plus_b := add(a, b)
		testing.expect_value(t, sub(a_plus_b, a), b)
		testing.expect_value(t, sub(a_plus_b, b), a)

		a_mul_b := mult(a, b)
		testing.expect_value(t, div(a_mul_b, a_mul_b), 1)
		testing.expect_value(t, div(a_mul_b, a), b)
		testing.expect_value(t, div(a_mul_b, b), a)
		testing.expect_value(t, div(a, a_mul_b), div(1, b))
		testing.expect_value(t, div(b, a_mul_b), div(1, a))
	}
}
@(test)
ass :: proc(t: ^testing.T) {
	init()
	for i in 0 ..< ROUNDS {
		a := u8(rand.uint_max(1 << 8))
		b := u8(rand.uint_max(1 << 8))
		c := u8(rand.uint_max(1 << 8))

		testing.expect_value(t, add(a, add(b, c)), add(add(a, b), c))
		testing.expect_value(t, mult(a, mult(b, c)), mult(mult(a, b), c))
	}
}
@(test)
comm :: proc(t: ^testing.T) {
	init()
	for i in 0 ..< ROUNDS {
		a := u8(rand.uint_max(1 << 8))
		b := u8(rand.uint_max(1 << 8))

		testing.expect_value(t, add(a, b), add(b, a))
		testing.expect_value(t, mult(a, b), mult(b, a))
	}
}

@(test)
dist :: proc(t: ^testing.T) {
	init()
	for i in 0 ..< ROUNDS {
		a := u8(rand.uint_max(1 << 8))
		b := u8(rand.uint_max(1 << 8))
		c := u8(rand.uint_max(1 << 8))

		testing.expect_value(t, mult(a, add(b, c)), add(mult(a, b), (mult(a, c))))
	}
}
