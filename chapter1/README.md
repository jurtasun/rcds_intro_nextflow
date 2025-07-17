## RCDS 2025 - Introduction to Nextflow & nf-core

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width="300">

### Introduction: Groovy

Nextflow is a domain specific language (DSL) implemented on top of the Groovy programming language, which in turn is a super-set of the Java programming language. This means that Nextflow can run any Groovy or Java code.

You have already been using some Groovy code in the previous sections, but now it's time to learn more about it.

#### 1.1 

This first exercise introduces Groovy's basic syntax, which is similar to Java but more concise and expressive. We will start by defining variables using `def`, which allows dynamic typing. Groovy automatically determines the type based on the assigned value.

Next, we will use string interpolation with double-quoted strings, allowing variables to be embedded directly in strings using the `$variableName` syntax. This is a cleaner way to build strings than concatenation.

Then, we will introduces loops using a range (1..10) and a `for` loop to iterate through it.

Write a Groovy script that:
- Declares a variable name with your name.
- Prints "Hello, <name>!".
- Then, prints numbers from 1 to 5 using a loop.

```groovy
def name = "Groovy Learner"
println "Hello, $name!"

for (i in 1..5) {
    println "Number: $i"
}
```

We can modify this a little. Inside the loop, conditional statements (`if`, `else`) can be used to apply logic to each value-filtering even numbers and printing a special message for numbers divisible by 4. These are foundational tools for controlling flow in any Groovy (or Nextflow) script.

Edit the script to do the following:
- Declares a variable name and age.
- Prints a greeting like: "Hello, <name>! You are <age> years old."
- Loops from 1 to 10 and: Prints even numbers only. If the number is divisible by 4, also print "Divisible by 4!".

```groovy
def name = "Groovy Learner"
def age = 25

println "Hello, $name! You are $age years old."

println "Even numbers from 1 to 10:"
for (i in 1..10) {
    if (i % 2 == 0) {
        print "$i"
        if (i % 4 == 0) {
            print " (Divisible by 4!)"
        }
        println()
    }
}
```

#### 1.2

This exercise explores one of Groovy's most powerful and commonly used structures: maps. A map is a collection of key-value pairs, and Groovy provides very concise syntax for creating and accessing them. Maps are heavily used in Nextflow configurations, parameter passing, and data modelling.

Let's write a function (or *method*) that takes a map as input and constructs a description string. This function demonstrates Groovy's support for dynamic typing and named parameters via maps.

Write a groovy script that:
- Creates a map person with keys: name, age, and city.
- Write a function describePerson(Map person) that returns a string like: "Alice is 30 years old and lives in London."
- Call the function and print the result.

```groovy
def person = [
    name: "Alice",
    age : 30,
    city: "London"
]

String describePerson(Map person) {
    return "${person.name} is ${person.age} years old and lives in ${person.city}."
}

println describePerson(person)
```

We could also use the `Elvis` operator (`?:`) to supply default values if certain keys are missing from the map, which is a common and elegant way to handle optional inputs.

Finally, we could practice conditional string construction: for example, only appending the job description if it exists. This shows how you can write expressive logic in compact, readable code using Groovy's flexible syntax.

Edit the script to do the following:
- Create a map person with: name, age, city, and optionally job.
- Write a function describePerson(Map person) that: Returns a sentence describing the person. Includes job only if it's provided.
- The function uses default values if some keys are missing.

```groovy
def person = [
    name: "Alice",
    age : 30,
    city: "London",
    job : "Data Scientist"
]

String describePerson(Map person) {
    def name = person.name ?: "Unknown"
    def age = person.age ?: "unspecified age"
    def city = person.city ?: "an unknown city"
    def jobInfo = person.job ? " and works as a ${person.job}" : ""
    
    return "$name is $age years old, lives in $city$jobInfo."
}

println describePerson(person)
```

Try modifying the person map to omit `job` or `age` and rerun to see the default behavior.

#### 1.3

Closures are first-class functions in Groovy, meaning they can be assigned to variables, passed as arguments, and used like any other object. They are a core feature of Groovy and are especially powerful when working with collections.

In this exercise, we will define a closures to calculate squares (`square`). We will then use Groovy's collection method `.collect()` - which take closures as arguments - to filter and transform a list.

These operations demonstrate how Groovy supports functional programming patterns. You can apply logic directly to lists without writing loops, resulting in more concise and expressive code. Closures are especially useful in data pipelines (like Nextflow processes), where we often pass logic into workflow steps or transformations.

Write a groovy script that:
- Defines a closure square that takes a number and returns its square.
- Uses it to square each number in the list [1, 2, 3, 4, 5].
- Prints the resulting list.

```groovy
def square = { x -> x * x }

def numbers = [1, 2, 3, 4, 5]
def squares = numbers.collect { square(it) }

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
def isEven = { n -> n % 2 == 0 }
def square = { x -> x * x }

def numbers = [1, 2, 3, 4, 5, 6, 7, 8]
def evens = numbers.findAll(isEven)
def squaredEvens = evens.collect(square)

println "Original List: $numbers"
println "Even Numbers : $evens"
println "Squared Evens: $squaredEvens"
```