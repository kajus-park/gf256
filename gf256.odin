package gf256

// An element is a polynomial of degree 7 with coefficients using modulo 2
// the number 0b00101001 represents the polynomaial
// 0x^7 + 0x^6  + 1x^5 + 0x^4 + 1x^3 + 0x^2 + 0x^1 + 1x^0
Elem :: u8
BIT_COUNT :: 8
// It is only 255 elements, because 0 is not part of the multiplicative group of GF(2^8)
MULT_GROUP_SIZE :: (1 << 8) - 1

PRIMITIVE_POLY :: 0b100011011
PRIMITIVE_POLY_TRUNC :: 0b00011011

// The powers of 3 generate all elements of GF(2^8) besides 0
GENERATOR :: 3
initialized := false


// n -> 3^n
exp3_table: [MULT_GROUP_SIZE]Elem

// 3^n -> n
// 0th index is meaningless, since log(0) is not defined
log3_table: [MULT_GROUP_SIZE + 1]Elem

add :: proc(a, b: Elem) -> Elem {
	// In modulo 2 arithmetic addition is just xor
	return a ~ b
}

sub :: add

mult :: proc(a, b: Elem) -> Elem {
	if a == 0 || b == 0 {
		return 0
	}
	la := log3_table[a]
	lb := log3_table[b]
	index: u16 = (u16(la) + u16(lb) + MULT_GROUP_SIZE) % MULT_GROUP_SIZE
	ab := exp3_table[index]
	return ab
}

div :: proc(a, b: Elem) -> Elem {
	if b == 0 {
		panic("dividing by zero")
	}
	if a == 0 {
		return 0
	}

	la := log3_table[a]
	lb := log3_table[b]

	index: u16 = (u16(la) - u16(lb) + MULT_GROUP_SIZE) % MULT_GROUP_SIZE
	ab := exp3_table[index]
	return ab
}

init :: proc() {
	if initialized {return}
	current: Elem = 1
	exp3_table[0] = 1
	log3_table[1] = 0
	for exponent in 1 ..< MULT_GROUP_SIZE {
		next: Elem
		if current >= 1 << 7 {
			next ~= PRIMITIVE_POLY_TRUNC
		}
		// multiply by current by 3 (0b11)
		next ~= current ~ (current << 1)
		current = next
		exp3_table[exponent] = current
		log3_table[current] = u8(exponent)
	}
	initialized = true
}
