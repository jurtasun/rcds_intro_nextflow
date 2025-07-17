// The `splitText` operator
println("\nThe `splitText` operator")
Channel
    .fromPath('data/message.txt') 
    .splitText() 
    .view()

println("\nAdd the `by` parameter")
Channel
    .fromPath('data/message.txt')
    .splitText(by: 2)
    .view()

println("\nAdd the `toUpperCase` closure")
Channel
    .fromPath('data/message.txt')
    .splitText(by: 2) { it.toUpperCase() }
    .view()

// The `splitCsv` operator
println("\nThe `splitCsv` operator")
Channel
    .fromPath("data/data.csv")
    .splitCsv()
    .view { row -> "${row[0]}, ${row[3]}" }
