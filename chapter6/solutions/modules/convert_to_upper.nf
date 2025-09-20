#!/usr/bin/env nextflow

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