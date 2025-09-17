## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 700>
<img src="/readme_figures/nextflow-logo.png" width = 700>

### Chapter 2. Basic `Nextflow` syntax.

At the heart of Nextflow, three concepts work together to define and execute workflows: `channels`, `processes`, and `operators`.

A `channel` is a data stream that connects different parts of a workflow. Think of it as a conveyor belt that carries values (files, strings, numbers, or complex objects) from one process to another. `Channels` can emit a single value, multiple values, or continuously produce values during execution.

A `process` is the fundamental computational unit in `Nextflow`. Each `process` has three main parts: `inputs` (declared through channel bindings), `outputs` (emitted onto channels), and a `script` block which contains the command or script (often `Bash`, `R`, or `Python`) that does the work.

Finally, `operators` are functions that transform `channels`. They allow to filter, map, group, or merge data streams before passing them to processes. For example, `.map(...)` can transform each value in a channel, `.filter(...)` can remove unwanted elements, and `.combine(...)` can join two channels together. `Operators` provide the expressive power to model complex data dependencies with concise, declarative syntax.

### 2.1. Channels: data flow, queue and value channels, channel factories.

A `channel` is a data stream that connects different parts of a workflow. They can emit a single value (`Channel.value`), multiple values (`Channel.from`), or continuously produce values during execution. As we will see, `channels` are asynchronous and immutable: once a value is put on a channel, it flows downstream, and processes can consume it without altering the channel itself. This design makes workflows both scalable and reproducible. `Nextflow` distinguishes two different kinds of channels: **queue** channels and **value** channels.

#### Queue channels

A **queue** channel is an *asynchronous* unidirectional FIFO queue that connects two processes or operators.

- Asynchronous means that operations are non-blocking.
- Unidirectional means that data flows from a producer to a consumer.
- FIFO means that the data is guaranteed to be delivered in the same order as it is produced. First In, First Out.
A queue channel is implicitly created by process output definitions or using channel factories such as `Channel.of()` or `Channel.fromPath()`.

Create a `nextflow` file named `channels.nf` and pase the following code:
```nextflow
// Create a queue channel with multiple values
ch = Channel.of(1, 2, 3)
ch.view()
```

You shall see that a `work` directory has appeared, together with some hidden files `.nextfow.log`. For now, let's ignore these and just focus on the output we see on screen. Let's now edit this to create two channels, `ch1` and `ch2`, and then uses them as inputs to the `SUM` process. The `SUM` process sums the two inputs and prints the result to the standard output. Finally the `workflow` section calls the `SUM` process on these two channels.

```nextflow
// Create a queue channel with multiple values
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of(1)

// Define process computing sum
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

// Define workflow
workflow {
    SUM(ch1, ch2).view()
}
```

When you run this script, it only prints `2`. A process will only instantiate a task when there are elements to be consumed from all the channels provided as input to it. Because `ch1` and `ch2` are queue channels, and the single element of `ch2` has been consumed, no new process instances will be launched, even if there are other elements to be consumed in `ch1`.

#### Value channels

A **value** channel (a.k.a. a *singleton* channel) is bound to a single value and it can be read unlimited times without consuming its contents. It is created using the `Channel.value()` channel factory or by operators returning a single value, such as `first`, `last`, `collect`, `count`, `min`, `max`, `reduce`, and `sum`. 
To see the difference between value and queue channels, edit the `channels.nf` file to contain the following: 

```nextflow
// Create queue and value channels
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.value(1)

// Define process
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

// Define workflow
workflow {
    SUM(ch1, ch2).view()
}
```

To use the single element in `ch2` multiple times, you can either use the `Channel.value` channel factory, 
or use a channel operator that returns a single element, such as `first()`:

```nextflow
// Create queue and value channels
ch1 = Channel.of(1, 2, 3)
ch2 = ch1.first()

// Define process
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

// Define workflow
workflow {
    SUM(ch1, ch2).view()
}
```

In many situations, `Nextflow` will implicitly convert variables to value channels when they are used in a process invocation. 
For example, when you invoke a process with a workflow parameter (`params.ch2`) which has a string value, it is automatically cast into a value channel:

```nextflow
// Declare channel and parameter
ch1 = Channel.of(1, 2, 3)
params.ch2 = "1"

// Define process
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

// Define workflow
workflow {
    SUM(ch1, params.ch2).view()
}
```

#### Channel factories

Channel factories are `Nextflow` commands for creating channels that have implicit expected inputs and functions. There are several different Channel factories which are useful for different situations. During the following chapters will cover the most common channel factories. Besides the basic `of()` and `value()` factories for queue and value channeles, there are also the `fromList()` and `fromPath()`, among others.

We will see how they are used practice during the next chapters. For now, keep in mind that a `channel` is a data stream that connects different parts of a workflow, and that can be found mainly in these two species, *queue* and *value*. A note on syntax: Since version 20.07.0, `channel` was introduced as an alias of `Channel`, allowing factory methods to be specified as `channel.of()` or `Channel.of()`, and so on.

### 2.2. Processes: executing functions.

In `Nextflow`, a `process` is the basic computing tool used to execute functions, custom scripts or external tools. 
The `process` definition starts with the keyword `process`, followed by the process name and then the process body delimited by curly brackets. 
A basic process, only using the `script` definition block, looks like the following:

```nextflow
// Define process
process say_hello {
    script:
    """
    echo 'Hello world!'
    """
}

// Define workflow
workflow {
    say_hello()
}

```

You should see a message saying that the `say_hello` process was executed once. However, the process body can contain up to five definition blocks:
- **Directives**: initial declarations that define optional settings
- **Input**: defines the expected input channel(s)
- **Output**: defines the expected output channel(s)
- **When**: optional clause statement to allow conditional processes
- **Script**: string statement that defines the command to be executed by the process' task

##### Script

The `script` block is a string statement that defines the command to be executed by the `process`. 
A `process` can execute only one `script` block, placed after the input and output declarations. 

Create a `nextflow` script named `processes.nf` and join the following syntax:

```nextflow
// Define process
process Example {

    output:
    path "greetings.txt"
    
    script:
    """
    echo 'Hello world!\nHola mundo!\nCiao mondo!\nHallo Welt!' > file
    cat file | head -n 1 | head -c 5 > greetings.txt
    """
    
}

// Define workflow
workflow {
    result = Example()
    result.view()
}
```

If you execute this code you will see that a `work` directory appears. But our `greetings.txt` file seems to appear very deep, layers behind the `work` directory. 
We will dig inside the structure of `Nextflow` ouptuts soon, and why this is the case. 
For now, adding a `directive`, such as the `publishDir`, allows the output to appear directly in our current directory.

```nextflow
// Define process
process Example {

    output:
    path "greetings.txt"
    
    publishDir "./", mode: 'copy'  // publish result to your current directory

    script:
    """
    echo 'Hello world!\nHola mundo!\nCiao mondo!\nHallo Welt!' > file
    cat file | head -n 1 | head -c 5 > greetings.txt
    """
    
}

// Define workflow
workflow {
    result = Example()
    result.view()
}
```

Check the ouptut with

```bash
less greetings.txt
```

Edit the `publishDir` directive to contain `$HOME` instead of `./`, allows the output to appear directly in our home directory.
As a note, anything that starts with the `$` is normally called an *environment variable*. They are key-value pairs defined in your operating system's environment.
They are inherited by processes (like `Nextflow`, `bash` scripts, `Python` programs), and often store system paths, user information, configuration values, etc.
Try typing in your terminal `echo $HOME`, `echo $USER`, `echo $SHELL`, `echo $PATH`.

```nextflow
// Define process
process Example {

    output:
    path "greetings.txt"
    
    publishDir "$HOME", mode: 'copy'  // publish result to your home directory

    script:
    """
    echo 'Hello world!\nHola mundo!\nCiao mondo!\nHallo Welt!' > file
    cat file | head -n 2 | head -c 5 > greetings.txt
    """
    
}

// Define workflow
workflow {
    result = Example()
    result.view()
}
```

Now the result will be *published* directly in our home directory. You can access the file and verify the result with

```bash
less ~/greetings.txt
```

Add the `debug` directive to enable debugging mode for the process. This is useful to print the output of the process script in the console.

##### Inputs

The input block defines the names and qualifiers of variables that refer to channel elements directed at the process. You can only define one input block at a time, and it must contain one or more input declarations. The `val` qualifier allows to receive data of any type as input. It can be accessed in the process `script` by using the specified input name. For example:

```nextflow
// Create queue channel
num = Channel.of(1, 2, 3)

// Define process
process BasicExample {

    debug true

    input:
    val x

    script:
    """
    echo 'process job $x'
    """

}

// Define workflow
workflow {
    BasicExample(num)
}
```

In the above example the process is executed three times, each time a value is received from the channel num it is used by the script. 
Thus, it results in an output similar to the one shown below:

```bash
process job 1
process job 2
process job 3
```

The channel guarantees that items are delivered in the same order as they have been sent. But since the process is executed in a parallel manner, there is no guarantee that they are processed in the same order as they are received.

We can provide the input through a file, rather than hard-coded in the script, using the `.fromPath()` channel factory.

```nextflow
// Create a queue channel from the file lines
ch1 = Channel.fromPath('data/input.txt')
           .splitText()   // splits file into lines

// Define process
process BasicExample {

    debug true

    input:
    val x   // each line from the file

    script:
    """
    echo 'Processing: $x'
    """
}

// Define workflow
workflow {
    BasicExample(ch1)
}
```

A key feature of processes is the ability to handle inputs from multiple channels. 
However, it is important to understand how channel contents and their semantics affect the execution of a process.

Consider the following example:

```nextflow
// Create queue channels
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of('a', 'b', 'c')

// Define process
process BasicExample {

    debug true

    input:
    val x
    val y

    script:
    """
    echo '$x and $y'
    """
}

// Define workflow
workflow {
    BasicExample(ch1, ch2)
}
```

Both channels emit three values, therefore the process is executed three times, each time with a different pair:

```bash
1 and a
3 and c
2 and b
```

The process waits until there is a complete input configuration, meaning that it receives an input value from all the channels declared as input. When this condition is verified, it consumes the input values coming from the respective channels, spawns a task execution, then repeats the same logic until one or more channels have no more content. This means channel values are consumed serially one after another and the first empty channel causes the process execution to stop, even if there are other values in other channels.

What happens when channels do not have the same cardinality (i.e., they emit a different number of elements)?

```nextflow
// Create queue channels
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of('a')

// Define process
process BasicExample {

    debug true

    input:
    val x
    val y

    script:
    """
    echo '$x and $y'
    """
}

// Define workflow
workflow {
    BasicExample(ch1, ch2)
}
```

In the above example, the process is only executed once because the process stops when a channel has no more data to be processed.

```bash
1 and a
```

However, replacing `ch2` with a value channel will cause the process to be executed three times, each time with the same value of a:

```nextflow
// Create queue channels
ch1 = Channel.of(1, 2, 3)
ch2 = Channel.value ('a')

// Define process
process BasicExample {

    debug true

    input:
    val x
    val y

    script:
    """
    echo '$x and $y'
    """
}

// Define workflow
workflow {
    BasicExample(ch1, ch2)
}
```

As `ch2` is now a value channel, it can be consumed multiple times and does not affect process termination.

```bash
1 and a
2 and a
3 and a
```

#### Outputs

The output declaration block defines the channels used by the process to send out the results produced. 
Only one output block, that can contain one or more output declaration, can be defined. The output block follows the syntax shown below:

```nextflow
// Define a greeting
greeting = "Hello world!"

// Define process
process BasicExample {

    input:
    val x

    output:
    val x

    script:
    """
    echo $x > file
    """

}

// Define workflow
workflow {
    BasicExample(Channel.of(greeting))
        .view()
}
```

The path qualifier specifies one or more files produced by the process into the specified channel as an output. 
Here we are using the `view()` operator to visualize the result.

```nextflow
// Define process
process RandomNum {

    publishDir "./", mode: 'copy'  // publish result to your current directory

    output:
    path 'random_number.txt'

    script:
    """
    echo \$RANDOM > random_number.txt
    """

}

// Define workflow
workflow {
    receiver_ch = RandomNum()
    receiver_ch.view()
}
```

In the above example the process `RandomNum` creates a file named `random_number.txt` containing a random number. 
Since a file parameter using the same name is declared in the output block, the file is sent over the `receiver_ch` channel when the task is complete. 
A downstream process declaring the same channel as input will be able to receive it.

##### Multiple output files

When an output file name contains a wildcard character (`*` or `?`) it is interpreted as a glob path matcher. 
This allows us to capture multiple files into a list object and output them as a sole emission. For example:

```nextflow
// Define process
process SplitLetters {

    publishDir "./", mode: 'copy'  // publish result to your current directory

    output:
    path 'chunk_*'

    script:
    """
    printf 'Hola' | split -b 1 - chunk_
    """

}

// Define workflow
workflow {
    letters = SplitLetters()
    letters.view()
}
```

Here the process splits the input (`Hola`) into chunks of 1 byte each, writing them into separate files with prefix `chunk_`. Hence you should see the following outpus:

- `chunk_aa`, contains the first letter (4-byte chunk): `H`
- `chunk_ab`, contains the first letter (4-byte chunk): `o`
- `chunk_ac`, contains the first letter (4-byte chunk): `l`
- `chunk_ad`, contains the first letter (4-byte chunk): `a`

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