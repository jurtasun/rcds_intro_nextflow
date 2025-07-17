// Define a variable 'name' and assign it a string value
def name = "Groovy Learner"

// Define a variable 'age' and assign it an integer value
def age = 25

// Print a greeting message using string interpolation
println "Hello, $name! You are $age years old."

// Loop through numbers from 1 to 10
println "Even numbers from 1 to 10:"
for (i in 1..10) {

    // Check if current number is even
    if (i % 2 == 0) {

        print "$i"
        
        // Check if number is also divisible by 4
        if (i % 4 == 0) {
            print " (Divisible by 4!)"
        }
        
        // Print newline after each number
        println()
    }

}
