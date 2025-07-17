// The `map` operator
println("\nThe `map` operator")
nums = Channel.of(1, 2, 3, 4) 
square = nums.map { it -> it * it } 
square.view()

// Add groovy `reverse` method
println("\nAdd groovy `reverse` method")
Channel
    .of('hello', 'world')
    .map { it -> it.reverse() }
    .view()

// The `view` operator
println("\nThe `view` operator")
Channel
    .of('foo', 'bar', 'baz')
    .view()

// Add closure parameter
println("\nAdd closure parameter")
Channel
    .of('foo', 'bar', 'baz')
    .view{ "- $it" }

// Add groovy `size` method
println("\nAdd groovy `size` method")
Channel
    .of('hello', 'world')
    .map { word -> [word, word.size()] }
    .view()

// The `mix` operator
println("\nThe `mix` operator")
my_channel_1 = Channel.of(1, 2, 3)
my_channel_2 = Channel.of('a', 'b')
my_channel_3 = Channel.of('z')
my_channel_1
            .mix(my_channel_2, my_channel_3)
            .view()

// The `flatten` operator
println("\nThe `flatten` operator")
foo = [1, 2, 3]
bar = [4, 5, 6]

Channel
    .of(foo, bar)
    .flatten()
    .view()

// The `collect` operator
println("\nThe `collect` operator")
Channel
    .of(1, 2, 3, 4)
    .collect()
    .view()

// The `groupTuple` operator
println("\nThe `groupTuple` operator")
Channel
    .of([1, 'A'], [1, 'B'], [2, 'C'], [3, 'B'], [1, 'C'], [2, 'A'], [3, 'D'])
    .groupTuple()
    .view()

// The `join` operator
println("\nThe `join` operator")
left = Channel.of(['X', 1], ['Y', 2], ['Z', 3], ['P', 7])
right = Channel.of(['Z', 6], ['Y', 5], ['X', 4])
left.join(right).view()

// The `branch` operator
println("\nThe `branch` operator")
Channel
    .of(1, 2, 3, 40, 50)
    .branch {
        small: it < 10
        large: it > 10
    }
    .set { result }

result.small.view { "$it is small" }
result.large.view { "$it is large" }