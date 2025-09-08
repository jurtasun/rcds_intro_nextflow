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