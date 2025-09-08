// Define closure that returns the square of a number
def square = { x -> x * x }

// Create a list of numbers
def numbers = [1, 2, 3, 4, 5]

// Use the 'collect' method on the 'square' closure to square each even number
def squares = numbers.collect { n -> square(n) }

// Print results
println "Original: $numbers"
println "Squared: $squares"