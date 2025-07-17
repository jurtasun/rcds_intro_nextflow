// Define closure (anonymous function) named 'isEven' that checks if a number is even
def isEven = { n -> n % 2 == 0 }

// Define another closure named 'square' that returns the square of a number
def square = { x -> x * x }

// Create a list of numbers from 1 to 8
def numbers = [1, 2, 3, 4, 5, 6, 7, 8]

// Use the 'findAll' method with the 'isEven' closure to filter even numbers
def evens = numbers.findAll(isEven)

// Use the 'collect' method with the 'square' closure to square each even number
def squaredEvens = evens.collect(square)

// Print results
println "Original list: $numbers"
println "Even numbers : $evens"
println "Squared even numbers: $squaredEvens"
