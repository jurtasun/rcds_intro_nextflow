#!/usr/bin/env nextflow

// Pipeline parameters
params.greeting = 'exercises/data/greetings_1.csv'
params.batch = 'test_batch'

// Include modules

// Process printing 'Hello World!' to a file
include { say_hello } from './modules/say_hello.nf'

// Process converting content of file to upper case
include { convert_to_upper } from './modules/convert_to_upper.nf'

// Collect uppercase greetings into a single output file
include { collect_greetings } from './modules/collect_greetings.nf'

// Workflow
workflow {

    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.greeting)
                        .view { csv -> "Before splitCsv: $csv" }
                        .splitCsv()
                        .view { csv -> "After splitCsv: $csv" }
                        .map { item -> item[0] }
                        .view { csv -> "After map: $csv" }
                        
    // Emit a greeting
    say_hello(greeting_ch)

    // Convert to uppercase
    convert_to_upper(say_hello.out)

    // collect all the greetings into one file
    collect_greetings(convert_to_upper.out.collect(), params.batch)

    // emit a message about the size of the batch
    collect_greetings.out.count.view { num_greetings -> "There were $num_greetings greetings in this batch" }
    
}