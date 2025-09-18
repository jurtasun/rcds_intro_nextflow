#!/usr/bin/env nextflow

// Pipeline parameters
params.greeting = 'exercises/data/greetings_1.csv'

// Process printing 'Hello World!' to a file
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

// Process converting content of file to upper case
process convert_to_upper {

    publishDir 'results', mode: 'copy'

    input:
        path input_file

    output:
        path "upper_${input_file}"

    script:
    """
    cat '$input_file' | tr '[a-z]' '[A-Z]' > 'upper_${input_file}'
    """

}

// Collect uppercase greetings into a single output file
process collect_greetings {

    publishDir 'results', mode: 'copy'

    input:
        path input_files

    output:
        path "collected_output.txt"

    script:
    """
    cat ${input_files} > 'collected_output.txt'
    """
}

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
    collect_greetings(convert_to_upper.out.collect())

    // optional view statements
    convert_to_upper.out.view { greeting -> "Before collect: $greeting" }
    convert_to_upper.out.collect().view { greeting -> "After collect: $greeting" }

}