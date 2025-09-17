## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 700>
<img src="/readme_figures/nextflow-logo.png" width = 700>

### Chapter 4. Channels and operators.

In most realistic cases, we want to process multiple values, like experimental data for multiple samples, so we need a more sophisticated way to handle inputs.
That is what Nextflow **channels** are for. Channels are queues designed to handle inputs efficiently and shuttle them from one step to another, and work in multi-step workflows. In this part of the course, we will learn how to use a channel to handle multiple inputs from a variety of different sources. You will also learn to use **operators** to transform and manipulate channel contents as needed.

Write the following code which reproduces the exercise we did in the last chapter.
Let's begin by creating a file called `hellow_channels.nf`.

```bash
touch hello_channels.nf
```

And open it with our text editor `VSCode`.

```bash
code hello_channels.nf
```

Then let's put together the following syntax.

```nextflow
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

    // emit a greeting
    say_hello(params.greeting)

}
```

And run it on your terminal:

```bash
nextflow run hello_channels.nf --greeting "Hello Channels"
```

As previously, you will find the output file named `output.txt` in the `results` directory, as specified by the `publishDir` directive.

### 4.1. Provide variable inputs with a channel

We are going to create a channel to pass the variable input to the `say_hello()` process instead of relying on the implicit handling, which has certain limitations. 
Let's start by using the most basic *channel factory*, called `Channel.of`, which will create a channel containing a single value. 

This creates a channel called `greeting_ch` using the `Channel.of()` channel factory, which sets up a simple queue channel, 
and loads the string `'Hello Channels!'` as the greeting value. In the workflow block, add the channel factory code:

*Before:*
```nextflow
workflow {

    // emit a greeting
    say_hello(params.greeting)

}
```

*After:*
```nextflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello Channels!')

    // emit a greeting
    say_hello(greeting_ch)

}
```

This tells Nextflow to run the `say_hello` process on the contents of the `greeting_ch` channel.
Now our workflow is properly functional; it is the explicit equivalent of writing `say_hello('Hello Channels!')`.

You can check the results directory to satisfy yourself that the outcome is still the same as previously.

### 4.2. Adapt workflow to accept multiple inputs.

Workflows typically run on batches of inputs that are meant to be processed in bulk, so we want to upgrade the workflow to accept multiple input values. 
Conveniently, the `Channel.of()` channel factory we just defined can accept more than one value, so we don't need to modify. 
We just have to load more values into the channel.

*Before:*
```nextflow
// create a channel for inputs
greeting_ch = Channel.of('Hello Channels')
```

*After:*
```nextflow
// create a channel for inputs
greeting_ch = Channel.of('Hello','Bonjour','Hola')
```

And run it again:

```bash
nextflow run hello_channels.nf
```

It certainly seems to run just fine:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_channels.nf` [sleepy_wright] DSL2 - revision: 55ea09727b

executor >  local (3)
[8d/b5a939] say_hello (3) | 3 of 3 ✔
```
Notw that this seems to indicate that '3 of 3' calls were made for the process, which is encouraging, 
but this only shows us a single run of the process, with one subdirectory path `(8d/b5a939)`. What's going on?

By default, Nextflow uses a system called *ANSI logging* system, which writes the logging from multiple calls in a compact way on the same line.
Fortunately, we can just disable that behavior to see the full list of process calls.

To expand the logging to display one line per process call, add `-ansi-log` false to the command.

```bash
nextflow run hello_channels.nf -ansi-log false
```

This time we see all three process runs and their associated work subdirectories listed in the output:

```bash
N E X T F L O W  ~  version 24.10.0
Launching `hello_channels.nf` [pensive_poitras] DSL2 - revision: 778deadaea
[76/f61695] Submitted process > say_hello (1)
[6e/d12e35] Submitted process > say_hello (3)
[c1/097679] Submitted process > say_hello (2)
```

That's much better; at least for a simple workflow. For a complex workflow, or a large number of inputs, having the full list output to the terminal might get overwhelming, so you might not choose to use -ansi-log false in those cases.

That being said, we have another problem. If you look in the results directory, there is only one file: `output.txt`.
We should be expecting a separate file per input greeting, so why do we get a single file? All three calls produced a file called `output.txt`. 
If we check the work subdirectories for each processes; each of them contains a file called output.txt as expected. 
We see then what is the problem. The output files stay there, isolated from the other processes, which is okay. 
But when the `publishDir` directive copies each of them to the same `results` directory, whichever got copied there first gets overwritten by the next one, and so on.

#### Ensure unique output file names

We can continue publishing all the outputs to the same results directory, but we need to ensure they will have unique names. 
Specifically, we need to modify the first process to generate a file name dynamically so that the final file names will be unique. 
Here, for convenience, we'll just use the greeting itself since it's just a short string, and prepend it to the base output filename.

Let's construct a dynamic output file name bu making the following code changes:

*Before:*
```nextflow
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
```

*After:*
```nextflow
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
```

Make sure to replace `output.txt` in both the `output:` definition and in the `script:` command block.
In the output definition, you **must** use double quotes around the output filename expression (NOT single quotes), otherwise it will fail.

Run it again and check we have now three new files in addition to the one we already had in the `results` directory.
Success! Now we can add as many greetings as we like without worrying about output files being overwritten.

In practice, naming files based on the input data itself is almost always impractical. 
The better way to generate dynamic filenames is to pass metadata to a process along with the input files.
The metadata is typically provided via a 'sample sheet' or equivalents. You'll learn how to do that later in next chapter.

### 4.3. Use operators to transform the contents of a channel.

In Nextflow, operators allow us to transform the contents of a channel. 
We just saw how to handle multiple input elements that were hardcoded directly in the channel factory. 
What if we wanted to provide those multiple inputs in a different form?

For example, imagine we set up an input variable containing an array of elements like this: `greetings_array = ['Hello','Bonjour','Hola']`. 
Can we load that into our output channel and expect it to work? Let's find out. 

#### Provide an array of values as input to the channel

We will now pass an array of values as input, instead of a single value.
First, let's take the `greetings_array` variable we just imagined and add it to the workflow block:

*Before:*
```nextflow
workflow {

    // create a channel for inputs
    greeting_ch = Channel.of('Hello','Bonjour','Hola')
```

*After:*
```nextflow
workflow {

    // declare an array of input greetings
    greetings_array = ['Hello','Bonjour','Hola']

    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
```

Run it again. This time, Nextflow throws an error that starts like this:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_channels.nf` [romantic_cuvier] DSL2 - revision: 66a1b858ff

executor >  local (1)
[f4/2f333c] say_hello | 1 of 1, failed: 1 ✘
ERROR ~ Error executing process > 'say_hello'

Caused by:
  Missing output file(s) `[Hello, Bonjour, Hola]_output.txt` expected by process `say_hello`
```

It looks like Nextflow tried to run a single process call, using `[Hello, Bonjour, Hola]` as a string value, 
instead of using the three strings in the array as separate values. Let's now get Nextflow to unpack the array and load the individual strings into the channel.

#### Use operator to transform channel contents

This is where **operators** come in.

If you read through the list of **operators** in the Nextflow documentation, 

[https://www.nextflow.io/docs/latest/reference/operator.html](https://www.nextflow.io/docs/latest/reference/operator.html)

you'll find `flatten()`, which does exactly what we need: unpack the contents of an array and emits them as individual items.
To apply the `flatten()` operator to our input channel, we append it to the channel factory declaration.

*Before:*
```nextflow
    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
```

*After:*
```nextflow
    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
                         .flatten()
```

Here we added the operator on the next line for readability, but you can add operators on the same line as the channel factory if you prefer, like this: `greeting_ch = Channel.of(greetings_array).flatten()`

We could run this right away to test if it works, but while we're at it, we're also going to add a couple of `view()` operators, 
which allow us to inspect the contents of a channel. You can think of `view()` as a debugging tool, like a `print()` statement in Python, or its equivalent in other languages.

In the workflow block, make the following code change:

*Before:*
```nextflow
    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
                         .flatten()
```

*After:*
```nextflow
    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
                         .view { greeting -> "Before flatten: $greeting" }
                         .flatten()
                         .view { greeting -> "After flatten: $greeting" }
```

We are using an operator *closure* here - the curly brackets. This code executes for each item in the channel. 
We define a temporary variable for the inner value, here called `greeting` (it could be anything). This variable is only used within the scope of that closure. 
In this example, `$greeting` represents each individual item loaded in a channel.

As a note, in some pipelines you may see a special variable called `$it` used inside operator closures. This is an implicit variable that allows a short-hand access to the inner variable, without needing to define it with a `->`. We prefer to be explicit to aid code clarity, as such the `$it` syntax is discouraged and will slowly be phased out of the Nextflow language.

This time it works AND gives us the additional insight into what the contents of the channel look like before and after we run the `flatten()` operator: 
You see that we get a single `Before flatten`: statement because at that point the channel contains one item, the original array. 
Then we get three separate `After flatten`: statements, one for each greeting, which are now individual items in the channel.

### 4.4. Use an operator to parse input values from a csv file

It's often the case that, when we want to run on multiple inputs, the input values are contained in a file. 
As an example, let's create a `greetings.csv` containing several greetings, one on each line, like a column of data.

```text
Hello
Bonjour
Hola
```

So now we need to modify our workflow to read in the values from a file like that.

#### Take inputs from a file

To get started, we're going to need to make two key changes to the script:

- Switch the input parameter to point to the CSV file
- Switch to a channel factory designed to handle a file

First, remember the `params.greeting` parameter we set up in previous chapter. We're going to update it to point to the CSV file containing our greetings.
Make the following code change:

*Before:*
```nextflow
// Pipeline parameters
params.greeting = ['Hello','Bonjour','Hola']
```

*After:*
```nextflow
// Pipeline parameters
params.greeting = 'greetings.csv'
```

And in the worflow section

*Before:*
```nextflow
    // create a channel for inputs
    greeting_ch = Channel.of(greetings_array)
                         .flatten()
```

*After:*
```nextflow
    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.greeting)
```

Then switch to a channel factory designed to handle a file. Since we now want to use a file instead of simple strings as the input, we can't use the `Channel.of()` channel factory from before. We need to switch to using a new channel factory, `Channel.fromPath()`, which has some built-in functionality for handling file paths.

In the workflow block, make the following code change:

Finally, run it again:

```bash
nextflow run hello_channels.nf
```

Here's the start of the console output and error message:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_channels.nf` [adoring_bhabha] DSL2 - revision: 8ce25edc39

[-        ] say_hello | 0 of 1
ERROR ~ Error executing process > 'say_hello (1)'

Caused by:
  File `/workspaces/training/hello-nextflow/data/greetings.csv-output.txt` is outside the scope of the process work directory: /workspaces/training/hello-nextflow/work/e3/c459b3c8f4029094cc778c89a4393d


Command executed:

  echo '/workspaces/training/hello-nextflow/data/greetings.csv' > '/workspaces/training/hello-nextflow/data/greetings.
```

The `Command executed:` part is especially helpful here.

This may look a little bit familiar. It looks like Nextflow tried to run a single process call using the file path itself as a string value. 
So it has resolved the file path correctly, but it didn't actually parse its contents, which is what we wanted.
To get Nextflow to open the file and load its contents into the channel, we will need another operator.

#### 4.2. Use the `splitCsv()` operator to parse the file

Looking through the list of operators again, we find splitCsv(), which is designed to parse and split CSV-formatted text.

To apply the `splitCsv()` operator, we append it to the channel factory line like previously.

In the workflow block, make the following code change:

*Before:*
```nextflow
// create a channel for inputs from a CSV file
greeting_ch = Channel.fromPath(params.greeting)
```

*After:*
```nextflow
// create a channel for inputs from a CSV file
greeting_ch = Channel.fromPath(params.greeting)
                     .view { csv -> "Before splitCsv: $csv" }
                     .splitCsv()
                     .view { csv -> "After splitCsv: $csv" }
```
we also include before/after view statements while we're at it.

Finally, run it again:

```bash
nextflow run hello_channels.nf
```

Here's the start of the console output and error message:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_channels.nf` [stoic_ride] DSL2 - revision: a0e5de507e

executor >  local (3)
[42/8fea64] say_hello (1) | 0 of 3
Before splitCsv: /workspaces/training/hello-nextflow/greetings.csv
After splitCsv: [Hello]
After splitCsv: [Bonjour]
After splitCsv: [Hola]
ERROR ~ Error executing process > 'say_hello (2)'

Caused by:
  Missing output file(s) `[Bonjour]-output.txt` expected by process `say_hello (2)`


Command executed:

  echo '[Bonjour]' > '[Bonjour]-output.txt'
```

This time Nextflow has parsed the contents of the file correctly, but it's added brackets around the greetings.

Long story short, `splitCsv()` reads each line into an array, and each comma-separated value in the line becomes an element in the array. 
So here it gives us three arrays containing one element each. Note that, even if this behavior feels inconvenient right now, 
it's going to be extremely useful later when we deal with input files with multiple columns of data.

We could solve this by using `flatten()`, which you already know. However, 
there's another operator called `map()` that's more appropriate to use here and is really useful to know; it pops up a lot in Nextflow pipelines.

#### 4.3. Use the `map()` operator to extract the greetings

The `map()` operator is a very handy little tool that allows us to do all kinds of mappings to the contents of a channel.
In this case, we're going to use it to extract that one element that we want from each line of our file. This is what the syntax looks like:

```nextflow
.map { item -> item[0] }
```
This means that for each element in the channel, take the first of any items it contains'. So let's apply that to our CSV parsing.

In the workflow block, make the following code change:

*Before:*
```nextflow
// create a channel for inputs from a CSV file
greeting_ch = Channel.fromPath(params.greeting)
                     .view { csv -> "Before splitCsv: $csv" }
                     .splitCsv()
                     .view { csv -> "After splitCsv: $csv" }
```

*After:*
```nextflow
// create a channel for inputs from a CSV file
greeting_ch = Channel.fromPath(params.greeting)
                     .view { csv -> "Before splitCsv: $csv" }
                     .splitCsv()
                     .view { csv -> "After splitCsv: $csv" }
                     .map { item -> item[0] }
                     .view { csv -> "After map: $csv" }
```
Once again we include another `view()` call to confirm that the operator does what we expect.

Run it again:

```bash
nextflow run hello_channels.nf
```

This time it should run without error.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_channels.nf` [tiny_heisenberg] DSL2 - revision: 845b471427

executor >  local (3)
[1a/1d19ab] say_hello (2) | 3 of 3 ✔
Before splitCsv: /workspaces/training/hello-nextflow/greetings.csv
After splitCsv: [Hello]
After splitCsv: [Bonjour]
After splitCsv: [Hola]
After map: Hello
After map: Bonjour
After map: Hola
```

Looking at the output of the view() statements, we see the following:

- A single `Before splitCsv`: statement: at that point the channel contains one item, the original file path.
- Three separate `After splitCsv`: statements: one for each greeting, but each is contained within an array that corresponds to that line in the file.
- Three separate `After map`: statements: one for each greeting, which are now individual elements in the channel.
You can also look at the output files to verify that each greeting was correctly extracted and processed through the workflow.

We've achieved the same result as previously, but now we have a lot more flexibility to add more elements to the channel of greetings we want to process by modifying an input file, without modifying any code.