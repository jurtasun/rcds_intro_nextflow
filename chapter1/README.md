## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width="500">

### Chapter 1. Introduction to `Groovy`

`Nextflow` is a domain specific language (DSL) implemented on top of the `Groovy` programming language, which in turn is a super-set of the `Java` programming language. This means that `Nextflow` can run any `Groovy` or `Java` code.

You have already been using some `Groovy` code in the previous sections, but now it's time to learn more about it.

### 1.1. Basic `Groovy` syntax.

This first exercise introduces `Groovy`'s basic syntax, which is similar to `Java` but more concise and expressive. We will start by defining variables using `def`, which allows dynamic typing. `Groovy` automatically determines the type based on the assigned value.

Next, we will use string interpolation with double-quoted strings, allowing variables to be embedded directly in strings using the `$variableName` syntax. This is a cleaner way to build strings than concatenation.

Then, we will introduces loops using a range (1..10) and a `for` loop to iterate through it.

Write a `Groovy` script that:
- Declares a variable name with your name.
- Prints "Hello, <name>!".
- Then, prints numbers from 1 to 5 using a loop.

```groovy
// Define a variable 'name' and assign it a string value
def name = "Groovy Learner"

// Print a greeting message using string interpolation
println "Hello, $name!"

// Loop through numbers from 1 to 5
for (i in 1..5) {

    // Print current number
    println "Number: $i"

}
```

We can modify this a little. Inside the loop, conditional statements (`if`, `else`) can be used to apply logic to each value-filtering even numbers and printing a special message for numbers divisible by 4. These are foundational tools for controlling flow in any `Groovy` (or `Nextflow`) script.

Edit the script to do the following:
- Declares a variable name and age.
- Prints a greeting like: "Hello, <name>! You are <age> years old."
- Loops from 1 to 10 and: Prints even numbers only. If the number is divisible by 4, also print "Divisible by 4!".

```groovy
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
```

### 1.2. Maps, parameters, data processing.

This exercise explores one of `Groovy`'s most powerful and commonly used structures: maps. A map is a collection of key-value pairs, and `Groovy` provides very concise syntax for creating and accessing them. Maps are heavily used in `Nextflow` configurations, parameter passing, and data modelling.

Let's write a function (or *method*) that takes a map as input and constructs a description string. This function demonstrates `Groovy`'s support for dynamic typing and named parameters via maps.

Write a `Groovy` script that:
- Creates a map person with keys: name, age, and city.
- Write a function describePerson(Map person) that returns a string like: "Alice is 30 years old and lives in London."
- Call the function and print the result.

```groovy
// Define map called 'person' with key-value pairs for name, age, city
def person = [
    name: "Alice",
    age : 30,
    city: "London"
]

// Define function that takes a map (like 'person') and returns a string
String describePerson(Map person) {
    return "${person.name} is ${person.age} years old and lives in ${person.city}."
}

// Call function with the 'person' map as input
println describePerson(person)
```

We could also use the `Elvis` operator (`?:`) to supply default values if certain keys are missing from the map, which is a common and elegant way to handle optional inputs.

Finally, we could practice conditional string construction: for example, only appending the job description if it exists. This shows how you can write expressive logic in compact, readable code using `Groovy`'s flexible syntax.

Edit the script to do the following:
- Create a map person with: name, age, city, and optionally job.
- Write a function describePerson(Map person) that: Returns a sentence describing the person. Includes job only if it's provided.
- The function uses default values if some keys are missing.

```groovy
// Define map called 'person' with key-value pairs for name, age, city, and job
def person = [
    name: "Alice",
    age : 30,
    city: "London",
    job : "Data Scientist"
]

// Define function that takes a map (like 'person') and returns a string
String describePerson(Map person) {

    // Use the Elvis operator (?:) to provide a default value if field is missing or null
    def name = person.name ?: "Unknown"
    def age = person.age ?: "unspecified age"
    def city = person.city ?: "an unknown city"

    // If job is present, build a string with job info; otherwise, use an empty string
    def jobInfo = person.job ? " and works as a ${person.job}" : ""
    
    // Return full description using string interpolation
    return "$name is $age years old, lives in $city$jobInfo."

}

// Call function with the 'person' map as input
println describePerson(person)
```

Try modifying the person map to omit `job` or `age` and rerun to see the default behavior.

### 1.3. Closures, collections, connection to `Nextflow`.

Closures are first-class functions in `Groovy`, meaning they can be assigned to variables, passed as arguments, and used like any other object. They are a core feature of `Groovy` and are especially powerful when working with collections.

In this exercise, we will define a closures to calculate squares (`square`). We will then use `Groovy`'s collection method `.collect()` - which take closures as arguments - to filter and transform a list.

These operations demonstrate how `Groovy` supports functional programming patterns. You can apply logic directly to lists without writing loops, resulting in more concise and expressive code. Closures are especially useful in data pipelines (like `Nextflow` processes), where we often pass logic into workflow steps or transformations.

Write a `Groovy` script that:
- Defines a closure square that takes a number and returns its square.
- Uses it to square each number in the list [1, 2, 3, 4, 5].
- Prints the resulting list.

```groovy
// Define closure (anonymous function) named 'square' that returns the square of a number
def square = { x -> x * x }

// Create a list of numbers from 1 to 5
def numbers = [1, 2, 3, 4, 5]

// Use the 'collect' method on the 'square' closure to square each even number
def squares = numbers.collect { square(it) }

// Print results
println "Original: $numbers"
println "Squared : $squares"
```

In this exercise, we will define two closures: one to test whether a number is even (`isEven`), and one to calculate squares (`square`). We will then use Groovy's collection methods like `.findAll()` and `.collect()` - which take closures as arguments - to filter and transform a list.

Edit the script to do the following:
- Define a closure isEven that returns true if a number is even.
- Define a closure square that returns the square of a number.
- From the list [1, 2, 3, 4, 5, 6, 7, 8]: Filter even numbers. Square each even number.
- Print the original list, even numbers, and their squares.

```groovy
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
```