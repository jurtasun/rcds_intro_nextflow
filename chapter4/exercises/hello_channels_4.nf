#!/usr/bin/env nextflow

// Pipeline parameters
params.greeting = 'Hola mundo!'

// Use echo to print 'Hello World!' to a file
process say_hello {
        
    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path "output_${greeting}.txt"

    script:
    """
    echo '$greeting' > 'output_${greeting}.txt'
    """

}

// Workflow
workflow {

    // declare an array of input greetings
    greetings_array = ['Hello','Bonjour','Hola']

    // create a channel for inputs
    // greeting_ch = Channel.of(greetings_array)
    //                      .view { greeting -> "Before flatten: $greeting" }
    //                      .flatten()
    //                      .view { greeting -> "After flatten: $greeting" }
    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
                         .view { "Before flatten: $it" }
                         .flatten()
                         .view { "After flatten: $it" }
                         
    // emit a greeting
    say_hello(greeting_ch)

}