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
