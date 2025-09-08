 // Define closure (anonymous function) named 'isEven' that checks if a number is even
def isEven = { n -> n % 2 == 0 }

// Define another closure named 'square' that returns the square of a number
def square = { x -> x * x }

// Read numbers from a file called "numbers.txt" (one number per line)
def numbers = []
new File("data/numbers.txt").eachLine { line ->
    // Convert each line to integer and add to the list
    numbers << line.toInteger()
}

// Use the 'findAll' method with the 'isEven' closure to filter even numbers
def evens = numbers.findAll(isEven)

// Use the 'collect' method with the 'square' closure to square each even number
def squaredEvens = evens.collect(square)

// Prepare the output text
def output = """Original list: $numbers
Even numbers : $evens
Squared even numbers: $squaredEvens
"""

// Write output to 'results.txt'
new File("results.txt").write(output)