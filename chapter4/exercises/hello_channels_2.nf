#!/usr/bin/env nextflow

// Pipeline parameters
params.greeting = 'Hola mundo!'

// Use echo to print 'Hello World!' to a file
process say_hello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path 'output.txt'

    script:
    """
    echo '$greeting' > output.txt
    """

}

// Workflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello Channels!')

    // emit a greeting
    say_hello(greeting_ch)

}