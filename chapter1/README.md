## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 700>
<img src="/readme_figures/nextflow-logo.png" width = 700>

### Chapter 1. Introduction to `Groovy`

`Nextflow` is a domain specific language (DSL) implemented on top of the `Groovy` programming language, which in turn is a super-set of the `Java` programming language. This means that `Nextflow` can run any `Groovy` or `Java` code. It was created to make it easier to write and manage complex workflows, especially in fields like bioinformatics and data science.

As we will see, `Nextflow` uses `Groovy` syntax under the hood. Before running any `Nextflow` syntax, let's dig a little deeper into `Groovy` itself, as understanding how it works will help us write more powerful and flexible workflows in `Nextflow`.

### 1.1. Basic `Groovy` syntax.

This first exercise introduces `Groovy`'s basic syntax, which is similar to `Java` but more concise and expressive. We will start by defining variables using `def`, which allows dynamic typing. `Groovy` automatically determines the type based on the assigned value.

Next, we will use string interpolation with double-quoted strings, allowing variables to be embedded directly in strings using the `$variableName` syntax. This is a cleaner way to build strings than concatenation.

Then, we will use loops using a range (1..10) iterate through a set of values and printing each time a different message.

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

We can modify this a little. Inside the loop, conditional statements (`if`, `else`) can be used to apply logic to each value, filtering even numbers and printing a specific message for some values. For instance, numbers divisible by 4. These are foundational tools for controlling flow in any `Groovy` (or `Nextflow`) script.

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

This exercise explores one of `Groovy`'s most powerful and commonly used structures: maps. A map is a collection of key-value pairs, and `Groovy` provides very concise syntax for creating and accessing them. Maps are heavily used in `Nextflow` configurations, parameter passing, and data modelling. Indeed, if you have some prior coding experience, you shall find that maps are similar to dictionaries in modern languages such as `Python`.

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
The `Elvis` operator is a shorthand in `Groovy` - and other languages - used to provide a default value if something is `null` or `false`.

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

The original code defined a fixed person map with hardcoded values for name, age, city, and job. To make the program interactive, we can modified it to read these values from the keyboard at runtime. To do this, we will define a helper function `readInput` that prompts the user for input and captures their response. The `person` map is then populated with these user-provided values instead of static data. This approach allows the program to describe any person based on the information entered by the user, making it more flexible and dynamic.

The `def console = System.console()` attempts to obtain the system console object associated with the running Java Virtual Machine (JVM). The `System.console()` method returns a `Console` instance if the program is running in an interactive command-line environment where input and output are connected to a console (like a terminal). If the program is run in an environment without a console—for example, inside some IDEs, background processes, or when input/output is redirected—this method returns `null`. By assigning this to the variable console, the program can then check if it has access to a console and decide how to read user input accordingly.

```groovy
// Function to read input with a prompt and return the entered value
String readInput(String prompt) {

    // Print input message
    print prompt
    
    // Try to get the system console
    def console = System.console()

    // If console is available, read input from console
    if (console != null) {
        return console.readLine()
    } else {
        // If console is not available (e.g., running in IDE), use Scanner to read input from System.in
        Scanner scanner = new Scanner(System.in)
        return scanner.nextLine()
    }

}

// Read map values from keyboard
def person = [
    name: readInput("Enter name: "),
    age : readInput("Enter age: "),
    city: readInput("Enter city: "),
    job : readInput("Enter job: ")
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

Edit this file further to read the input numbers from a file `data/numbers.txt`.

```groovy
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
```