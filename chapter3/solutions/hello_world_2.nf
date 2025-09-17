#!/usr/bin/env nextflow

// Use echo to print 'Hello World!' to a file
process say_hello {

    publishDir 'results', mode: 'copy'

    output:
        path 'output.txt'

    script:
    """
    echo 'Hello World!' > output.txt
    """
    
}

// Define workflow
workflow {

    // emit a greeting
    say_hello()

}