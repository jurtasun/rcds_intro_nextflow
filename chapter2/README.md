## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width=500>

### Chapter2. Basic `Nextflow` syntax.

### 1 Channels: data flow, queue and value channels.

Channels are a key data structure of `Nextflow` that allows the implementation of reactive-functional oriented computational workflows based on the Dataflow programming paradigm. They are used to logically connect tasks to each other or to implement functional style data transformations. `Nextflow` distinguishes two different kinds of channels: **queue** channels and **value** channels.

#### 1.1 Channel types.

A **queue** channel is an *asynchronous* unidirectional FIFO queue that connects two processes or operators.

- asynchronous means that operations are non-blocking.
- unidirectional means that data flows from a producer to a consumer.
- FIFO means that the data is guaranteed to be delivered in the same order as it is produced. First In, First Out.
A queue channel is implicitly created by process output definitions or using channel factories such as `Channel.of()` or `Channel.fromPath()`.

Try the following code:
```nextflow
ch = Channel.of(1, 2, 3)
ch.view()
```

A **value** channel (a.k.a. a *singleton* channel) is bound to a single value and it can be read unlimited times without consuming its contents. A `value` channel is created using the `value` channel factory or by operators returning a single value, such as `first`, `last`, `collect`, `count`, `min`, `max`, `reduce`, and `sum`.

To see the difference between value and queue channels, you can try the following:

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of(1)

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    SUM(ch1, ch2).view()
}
```

This workflow creates two channels, `ch1` and `ch2`, and then uses them as inputs to the SUM process. The SUM process sums the two inputs and prints the result to the standard output.

When you run this script, it only prints `2`.

A process will only instantiate a task when there are elements to be consumed from all the channels provided as input to it. Because `ch1` and `ch2` are queue channels, and the single element of `ch2` has been consumed, no new process instances will be launched, even if there are other elements to be consumed in `ch1`.

To use the single element in `ch2` multiple times, you can either use the `Channel.value` channel factory, or use a channel operator that returns a single element, such as `first()`:

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.value(1)

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    SUM(ch1, ch2).view()
}
```
In many situations, `Nextflow` will implicitly convert variables to value channels when they are used in a process invocation.

For example, when you invoke a process with a workflow parameter (`params.ch2`) which has a string value, it is automatically cast into a value channel:

```nextflow
ch1 = Channel.of(1, 2, 3)
params.ch2 = "1"

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

workflow {
    SUM(ch1, params.ch2).view()
}
```

#### 1.2. Channel factories.

Channel factories are `Nextflow` commands for creating channels that have implicit expected inputs and functions. There are several different Channel factories which are useful for different situations. The following sections will cover the most common channel factories. 

Tip: Since version 20.07.0, `channel` was introduced as an alias of `Channel`, allowing factory methods to be specified as `channel.of()` or `Channel.of()`, and so on.

##### 1.2.1 `value()`

The `value` channel factory is used to create a *value* channel. An optional not `null` argument can be specified to bind the channel to a specific value. For example:

```nextflow
ch1 = Channel.value() 
ch2 = Channel.value('Hello there') 
ch3 = Channel.value([1, 2, 3, 4, 5])
```

##### 1.2.1 `of()`

The `Channel.of` factory allows the creation of a *queue* channel with the values specified as arguments.

```nextflow
Channel
    .of(1, 3, 5, 7)
    .view()
```

The `Channel.of` channel factory works in a similar manner to `Channel.from` (which is now deprecated), fixing some inconsistent behaviors of the latter and providing better handling when specifying a range of values. For example, the following works with a range from 1 to 23:

```nextflow
Channel
    .of(1..23, 'X', 'Y')
    .view()
```

##### 1.2.3 `fromList()`

The `Channel.fromList` factory creates a channel emitting the elements provided by a list object specified as an argument:

```nextflow
list = ['hello', 'world']

Channel
    .fromList(list)
    .view()
```

##### 1.2.4 `fromPath()`

The `Channel.fromPath` factory creates a queue channel emitting one or more files matching the specified glob pattern.

```nextflow
Channel
    .fromPath('./data/meta/*.csv')
```

This example creates a channel and emits as many items as there are files with a `csv` extension in the `./data/meta` folder. 
Each element is a file object implementing the Path interface.

##### 1.2.5 `fromFilePairs()`

The `Channeld.fromFilePairs` factory creates a channel emitting the file pairs matching a glob pattern provided by the user. The matching files are emitted as tuples, in which the first element is the grouping key of the matching pair and the second element is the list of files (sorted in lexicographical order).

```nextflow
Channel
    .fromFilePairs('./data/ggal/*_{1,2}.fq')
    .view()
```

The glob pattern must contain at least an asterisk wildcard character `(*)`. It will produce an output similar to the following:

```bash
[liver, [/workspaces/training/nf-training/data/ggal/liver_1.fq, /workspaces/training/nf-training/data/ggal/liver_2.fq]]
[gut, [/workspaces/training/nf-training/data/ggal/gut_1.fq, /workspaces/training/nf-training/data/ggal/gut_2.fq]]
[lung, [/workspaces/training/nf-training/data/ggal/lung_1.fq, /workspaces/training/nf-training/data/ggal/lung_2.fq]]
```

#### 2. Processes: executing functions.

In `Nextflow`, a `process` is the basic computing tool used to execute functions, custom scripts or external tools.
The `process` definition starts with the keyword `process`, followed by the process name and then the process body delimited by curly brackets.
A basic process, only using the script definition block, looks like the following:

```nextflow
process say_hello {
    script:
    """
    echo 'Hello world!'
    """
}
```

However, the process body can contain up to five definition blocks:
- **Directives**: initial declarations that define optional settings
- **Input**: defines the expected input channel(s)
- **Output***: defines the expected output channel(s)
- **When**: optional clause statement to allow conditional processes
- **Script**: string statement that defines the command to be executed by the process' task

##### 2.1 Script

The script block is a string statement that defines the command to be executed by the process.

A process can execute only one script block. It must be the last statement when the process contains input and output declarations.

The script block can be a single or a multi-line string. The latter simplifies the writing of non-trivial scripts composed of multiple commands spanning over multiple lines. For example:

```nextflow
process EXAMPLE {
    script:
    """
    echo 'Hello world!\nHola mundo!\nCiao mondo!\nHallo Welt!' > file
    cat file | head -n 1 | head -c 5 > chunk_1.txt
    gzip -c chunk_1.txt  > chunk_archive.gz
    """
}

workflow {
    EXAMPLE()
}
```

In the snippet below the directive debug is used to enable the debug mode for the process. This is useful to print the output of the process script in the console.

By default, the process command is interpreted as a Bash script. However, any other scripting language can be used by simply starting the script with the corresponding Shebang declaration. For example:

```nextflow
process PYSTUFF {
    debug true

    script:
    """
    #!/usr/bin/env python

    x = 'Hello'
    y = 'world!'
    print ("%s - %s" % (x, y))
    """
}

workflow {
    PYSTUFF()
}
```

```bash
Hello-world
```
Multiple programming languages can be used within the same workflow script. However, for large chunks of code it is better to save them into separate files and invoke them from the process script. One can store the specific scripts in the ./bin/ folder.

##### 2.1.1 Script parameters

Script parameters (params) can be defined dynamically using variable values. For example:

```nextflow
params.data = 'World'

process FOO {
    debug true

    script:
    """
    echo Hello $params.data
    """
}

workflow {
    FOO()
}
```

```bash
Hello World
```
A process script can contain any string format supported by the Groovy programming language. This allows us to use string interpolation as in the script above or multiline strings. Refer to String interpolation for more information.

Warning: Since Nextflow uses the same Bash syntax for variable substitutions in strings, Bash environment variables need to be escaped using the \ character. The escaped version will be resolved later, returning the task directory (e.g. work/7f/f285b80022d9f61e82cd7f90436aa4/), while $PWD would show the directory where you're running Nextflow.

```nextflow
process FOO {
    debug true

    script:
    """
    echo "The current directory is \$PWD"
    """
}

workflow {
    FOO()
}
```
Your expected output will look something like this:

Output

The current directory is /workspaces/training/nf-training/work/7a/4b050a6cdef4b6c1333ce29f7059a0
It can be tricky to write a script that uses many Bash variables. One possible alternative is to use a script string delimited by single-quote characters (').

```nextflow
process BAR {
    debug true

    script:
    '''
    echo "The current directory is $PWD"
    '''
}

workflow {
    BAR()
}
```
Your expected output will look something like this:

Output

The current directory is /workspaces/training/nf-training/work/7a/4b050a6cdef4b6c1333ce29f7059a0
However, using the single quotes (') will block the usage of Nextflow variables in the command script.

Another alternative is to use a shell statement instead of script and use a different syntax for Nextflow variables, e.g., !{..}. This allows the use of both Nextflow and Bash variables in the same script.

```nextflow
params.data = 'le monde'

process BAZ {
    shell:
    '''
    X='Bonjour'
    echo $X !{params.data}
    '''
}

workflow {
    BAZ()
}
```

##### 2.2 Inputs

Nextflow process instances (tasks) are isolated from each other but can communicate between themselves by sending values through channels.

Inputs implicitly determine the dependencies and the parallel execution of the process. The process execution is fired each time new data is ready to be consumed from the input channel [...figure...]

The input block defines the names and qualifiers of variables that refer to channel elements directed at the process. You can only define one input block at a time, and it must contain one or more input declarations.

##### 2.2.1 Input values

The val qualifier allows you to receive data of any type as input. It can be accessed in the process script by using the specified input name. For example:

```nextflow
num = Channel.of(1, 2, 3)

process BASICEXAMPLE {
    debug true

    input:
    val x

    script:
    """
    echo process job $x
    """
}

workflow {
    BASICEXAMPLE(num)
}
```

In the above example the process is executed three times, each time a value is received from the channel num it is used by the script. Thus, it results in an output similar to the one shown below:

```bash
process job 1
process job 2
process job 3
```
Warning
The channel guarantees that items are delivered in the same order as they have been sent - but - since the process is executed in a parallel manner, there is no guarantee that they are processed in the same order as they are received.

##### 2.2.2 Input files

The path qualifier allows the handling of file values in the process execution context. This means that Nextflow will stage it in the process execution directory, and it can be accessed by the script using the name specified in the input declaration. For example:

```nextflow
reads = Channel.fromPath('data/ggal/*.fq')

process FOO {
    debug true

    input:
    path 'sample.fastq'

    script:
    """
    ls sample.fastq
    """
}

workflow {
    result = FOO(reads)
}
```
In this case, the process is executed six times and will print the name of the file sample.fastq six times as this is the name of the file in the input declaration and despite the input file name being different in each execution (e.g., lung_1.fq).

```bash
sample.fastq
sample.fastq
sample.fastq
sample.fastq
sample.fastq
sample.fastq
```
The input file name can also be defined using a variable reference as shown below:

```nextflow
reads = Channel.fromPath('data/ggal/*.fq')

process FOO {
    debug true

    input:
    path sample

    script:
    """
    ls  $sample
    """
}

workflow {
    result = FOO(reads)
}
```

In this case, the process is executed six times and will print the name of the variable input file six times (e.g., lung_1.fq).

```bash
lung_1.fq
gut_2.fq
liver_2.fq
lung_2.fq
liver_1.fq
gut_1.fq
```
The same syntax is also able to handle more than one input file in the same execution and only requires changing the channel composition using an operator (e.g., collect).

```nextflow
reads = Channel.fromPath('data/ggal/*.fq')

process FOO {
    debug true

    input:
    path sample

    script:
    """
    ls $sample
    """
}

workflow {
    FOO(reads.collect())
}
```
Note that while the output looks the same, this process is only executed once.

Output

lung_1.fq
gut_2.fq
liver_2.fq
lung_2.fq
liver_1.fq
gut_1.fq
Warning
In the past, the file qualifier was used for files, but the path qualifier should be preferred over file to handle process input files when using Nextflow 19.10.0 or later. When a process declares an input file, the corresponding channel elements must be file objects created with the file helper function from the file specific channel factories (e.g., Channel.fromPath or Channel.fromFilePairs).

##### 2.2.3 Combine input channels

A key feature of processes is the ability to handle inputs from multiple channels. However, it’s important to understand how channel contents and their semantics affect the execution of a process.

Consider the following example:

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of('a', 'b', 'c')

process FOO {
    debug true

    input:
    val x
    val y

    script:
    """
    echo $x and $y
    """
}

workflow {
    FOO(ch1, ch2)
}
```
Both channels emit three values, therefore the process is executed three times, each time with a different pair:

```bash
1 and a
3 and c
2 and b
```
The process waits until there’s a complete input configuration, i.e., it receives an input value from all the channels declared as input.

When this condition is verified, it consumes the input values coming from the respective channels, spawns a task execution, then repeats the same logic until one or more channels have no more content.

This means channel values are consumed serially one after another and the first empty channel causes the process execution to stop, even if there are other values in other channels.

What happens when channels do not have the same cardinality (i.e., they emit a different number of elements)?

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of('a')

process FOO {
    debug true

    input:
    val x
    val y

    script:
    """
    echo $x and $y
    """
}

workflow {
    FOO(ch1, ch2)
}
```

In the above example, the process is only executed once because the process stops when a channel has no more data to be processed.

```bash
1 and a
```
However, replacing ch2 with a value channel will cause the process to be executed three times, each time with the same value of a:

```nextflow
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.value('a')

process FOO {
    debug true

    input:
    val x
    val y

    script:
    """
    echo $x and $y
    """
}

workflow {
    FOO(ch1, ch2)
}
```
Script output

```bash
1 and a
2 and a
3 and a
```
As ch2 is now a value channel, it can be consumed multiple times and does not affect process termination.

Exercise
Write a process that is executed for each read file matching the pattern data/ggal/*_1.fq and use the same data/ggal/transcriptome.fa in each execution.

#### 2.3 Outputs

The output declaration block defines the channels used by the process to send out the results produced.

Only one output block, that can contain one or more output declaration, can be defined. The output block follows the syntax shown below:

##### 2.3.1 Output values

The val qualifier specifies a defined value in the script context. Values are frequently defined in the input and/or output declaration blocks, as shown in the following example:

snippet.nf

greeting = "Hello world!"

process FOO {
    input:
    val x

    output:
    val x

    script:
    """
    echo $x > file
    """
}

workflow {
    FOO(Channel.of(greeting))
        .view()
}

##### 5.3.2 Output files

The path qualifier specifies one or more files produced by the process into the specified channel as an output.

snippet.nf

process RANDOMNUM {
    output:
    path 'result.txt'

    script:
    """
    echo \$RANDOM > result.txt
    """
}

workflow {
    receiver_ch = RANDOMNUM()
    receiver_ch.view()
}
In the above example the process RANDOMNUM creates a file named result.txt containing a random number.

Since a file parameter using the same name is declared in the output block, the file is sent over the receiver_ch channel when the task is complete. A downstream process declaring the same channel as input will be able to receive it.

##### 5.3.3 Multiple output files

When an output file name contains a wildcard character (* or ?) it is interpreted as a glob path matcher. This allows us to capture multiple files into a list object and output them as a sole emission. For example:

```nextflow
process SPLITLETTERS {
    output:
    path 'chunk_*'

    script:
    """
    printf 'Hola' | split -b 1 - chunk_
    """
}

workflow {
    letters = SPLITLETTERS()
    letters.view()
}
```
Prints the following:

```bash
[/workspaces/training/nf-training/work/ca/baf931d379aa7fa37c570617cb06d1/chunk_aa, /workspaces/training/nf-training/work/ca/baf931d379aa7fa37c570617cb06d1/chunk_ab, /workspaces/training/nf-training/work/ca/baf931d379aa7fa37c570617cb06d1/chunk_ac, /workspaces/training/nf-training/work/ca/baf931d379aa7fa37c570617cb06d1/chunk_ad]
```
Some caveats on glob pattern behavior:

Input files are not included in the list of possible matches
Glob pattern matches both files and directory paths
When a two asterisks pattern ** is used to recourse across directories, only file paths are matched i.e., directories are not included in the result list.
Exercise
Add the flatMap operator and see out the output changes. The documentation for the flatMap operator is available at this link.

Solution

##### 2.3.4 Dynamic output file names

When an output file name needs to be expressed dynamically, it is possible to define it using a dynamic string that references values defined in the input declaration block or in the script global context. For example:

```nextflow
species = ['cat', 'dog', 'sloth']
sequences = ['AGATAG', 'ATGCTCT', 'ATCCCAA']

Channel
    .fromList(species)
    .set { species_ch }

process ALIGN {
    input:
    val x
    val seq

    output:
    path "${x}.aln"

    script:
    """
    echo align -in $seq > ${x}.aln
    """
}

workflow {
    genomes = ALIGN(species_ch, sequences)
    genomes.view()
}
```

In the above example, each time the process is executed an alignment file is produced whose name depends on the actual value of the x input.

#### 2.5 Directives

Directive declarations allow the definition of optional settings that affect the execution of the current process without affecting the semantic of the task itself.

They must be entered at the top of the process body, before any other declaration blocks (i.e., input, output, etc.).

Directives are commonly used to define the amount of computing resources to be used or other meta directives that allow the definition of extra configuration of logging information. For example:

snippet.nf

process FOO {
    cpus 2
    memory 1.GB
    container 'image/name'

    script:
    """
    echo your_command --this --that
    """
}
The complete list of directives is available at this link. Some of the most common are described in detail below.

##### 2.5.1 Resource allocation

Directives that allow you to define the amount of computing resources to be used by the process. These are:

Name	Description
cpus	Allows you to define the number of (logical) CPUs required by the process’ task.
time	Allows you to define how long the task is allowed to run (e.g., time 1h: 1 hour, 1s 1 second, 1m 1 minute, 1d 1 day).
memory	Allows you to define how much memory the task is allowed to use (e.g., 2 GB is 2 GB). Can also use B, KB,MB,GB and TB.
disk	Allows you to define how much local disk storage the task is allowed to use.
These directives can be used in combination with each other to allocate specific resources to each process. For example:

```nextflow
process FOO {
    cpus 2
    memory 1.GB
    time '1h'
    disk '10 GB'

    script:
    """
    echo your_command --this --that
    """
}
```

##### 2.5.2 `PublishDir` directive

Given each task is being executed in separate temporary work/ folder (e.g., work/f1/850698…), you may want to save important, non-intermediary, and/or final files in a results folder.

To store our workflow result files, you need to explicitly mark them using the directive publishDir in the process that’s creating the files. For example:

```nextflow
reads_ch = Channel.fromFilePairs('data/ggal/*_{1,2}.fq')

process FOO {
    publishDir "results", pattern: "*.bam"

    input:
    tuple val(sample_id), path(sample_id_paths)

    output:
    tuple val(sample_id), path("*.bam")
    tuple val(sample_id), path("*.bai")

    script:
    """
    echo your_command_here --sample $sample_id_paths > ${sample_id}.bam
    echo your_command_here --sample $sample_id_paths > ${sample_id}.bai
    """
}

workflow {
    FOO(reads_ch)
}
```

The above example will copy all BAM files created by the FOO process into the directory path results.

The publish directory can be local or remote. For example, output files could be stored using an AWS S3 bucket by using the s3:// prefix in the target path.

You can use more than one publishDir to keep different outputs in separate directories. For example:

```nextflow
reads_ch = Channel.fromFilePairs('data/ggal/*_{1,2}.fq')

process FOO {
    publishDir "results/bam", pattern: "*.bam"
    publishDir "results/bai", pattern: "*.bai"

    input:
    tuple val(sample_id), path(sample_id_paths)

    output:
    tuple val(sample_id), path("*.bam")
    tuple val(sample_id), path("*.bai")

    script:
    """
    echo your_command_here --sample $sample_id_paths > ${sample_id}.bam
    echo your_command_here --sample $sample_id_paths > ${sample_id}.bai
    """
}

workflow {
    FOO(reads_ch)
}
```
Exercise
Edit the publishDir directive in the previous example to store the output files for each sample type in a different directory.

Solution
Summary
In this step you have learned:

How to use the cpus, time, memory, and disk directives to define the amount of computing resources to be used by the process
How to use the publishDir directive to store the output files in a results folder


#### 3. Operators: produce, chain and manipulate channels.

`Nextflow` operators are methods that allow to manipulate channels. Every operator, with the exception of `set` and `subscribe`, produces one or more new channels, 
allowing to chain operators to fit your needs. There are seven main groups of operators are described in greater detail within the `Nextflow` Reference Documentation, linked below:
- Filtering operators
- Transforming operators
- Splitting operators
- Combining operators
- Forking operators
- Maths operators
- Other operators

##### 3.1 Basic example

The `map` operator applies a function of your choosing to every item emitted by a channel, and returns the items so obtained as a new channel. 
The function applied is called the mapping function and is expressed with a closure as shown in the example below:

##### 3.2 Common operators

Here we will explore some of the most commonly used operators.

##### 3.3 Text files

Here we will explore how to parse and process text files.