// Function to read input with a prompt and return the entered value
String readInput(String prompt) {

    // Print input message
    print prompt
    
    // Get the system console to enable user input
    def console = System.console()

    // If console is available, read input from console
    return console.readLine()

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
    def age = person.age ?: "unspeficied"
    def city = person.city ?: "unknown city"

    // If job is present, build a string with job info; otherwise, use an empty string
    def jobInfo = person.job ? " and works as a ${person.job}" : ""
    
    // Return full description using string interpolation
    return "$name is $age years old, lives in $city$jobInfo."
}

// Call function with the 'person' map as input
println describePerson(person)