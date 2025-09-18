## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 700>
<img src="/readme_figures/nextflow-logo.png" width = 700>

### Chapter 5. General workflow.

In this chapter we will learn how to connect processes together in a multi-step workflow, achieving the following:

1. Making data flow from one process to the next
2. Collecting outputs from multiple processes into a single call
3. Passing more than one input to a process
3. Handling multiple outputs coming out of a process

We're going to use as starting point the example we did in previous chapter. Create a script named `hello_workflow.nf`, 

```bash
touch hello_workflow.nf && code hello_workflow.nf
```

and put together the following syntax:

```nextflow
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

// Workflow
workflow {

    // create a channel for inputs from a CSV file
    greeting_ch = Channel.fromPath(params.greeting)
                        .view { csv -> "Before splitCsv: $csv" }
                        .splitCsv()
                        .view { csv -> "After splitCsv: $csv" }
                        .map { item -> item[0] }
                        .view { csv -> "After map: $csv" }
                        
    // emit a greeting
    say_hello(greeting_ch)

}
```

Then run it to verify that runs as expected, with three calls to the `say_hello` process.

```bash
nextflow run hello_workflow.nf
```

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_workflow.nf` [stupefied_sammet] DSL2 - revision: b9e466930b

executor >  local (3)
[2a/324ce6] say_hello (3) | 3 of 3 ✔
```

As previously, you will find the output files in the results directory, as specified by the `publishDir` directive. 
We will now make the following changes to our workflow:

1. Add a second step that converts the greeting to uppercase.
2. Add a third step that collects all the transformed greetings and writes them into a single file.
3. Add a parameter to name the final output file and pass that as a secondary input to the collection step.
4. Make the collection step also output a simple statistic about what was processed.

### 5.1. Add a second step to the workflow

We're going to add a step to convert the greeting to uppercase. To that end, we need to do three things:

- Define the command we're going to use to do the uppercase conversion.
- Write a new process that wraps the uppercasing command.
- Call the new process in the workflow block and set it up to take the output of the `say_hello()` process as input.

#### Define the uppercasing command and test it in the terminal

As an exercise, we will convert the output greetings to uppercase. For that we will use a classic UNIX tool called `tr` for 'text replacement', with the following syntax:

```bash
tr '[a-z]' '[A-Z]'
```

To test it out, we can run the echo 'Hello World' command and pipe its output to the tr command:

```bash
echo 'Hello World' | tr '[a-z]' '[A-Z]' > output_upper.txt
```

The output is a text file called `output_upper.txt` that contains the uppercase version of the Hello World string.
Let's now implement that change with our workflow. Add the following process definition to the workflow script:

```nextflow
// Convert the greeting to uppercase with text replacement
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
```

Here, we compose the second output filename based on the input filename, similarly to what we did originally for the output of the first process. 
Note that Nextflow will determine the order of operations based on the chaining of inputs and outputs in the workflow. 
Nevertheless, it is always a good practice to write them in a logical order for the sake of readability.

#### Add a call to the new process in the workflow block

Now we need to tell Nextflow to actually call the process that we just defined. In the workflow block, add the following call to `convert_to_upper()`:

```nextflow

    // Emit a greeting
    say_hello(greeting_ch)

    // Convert to uppercase
    convert_to_upper()

```

This is not yet functional because we have not specified what should be input to the `convert_to_upper()` process. 
Now we need to make the output of the `say_hello()` process flow into the `convert_to_upper()` process.

Conveniently, Nextflow automatically packages the output of a process into a channel called `<process>.out`. 
So the output of the `say_hello` process is a channel called `say_hello.out`, which we can plug straight into the call to `convert_to_upper()`.

In the workflow block, make the final edit in the call to `converToUpper()`:

```nextflow

    // Convert to uppercase
    convert_to_upper(say_hello.out)

```

#### Run the workflow again with `-resume`

Let's run this using the `-resume` flag, since we've already run the first step of the workflow successfully.

```bash
nextflow run hello-workflow.nf -resume
```

You should get the following output

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-workflow.nf` [disturbed_darwin] DSL2 - revision: 4e252c048f

executor >  local (3)
[79/33b2f0] say_hello (2)       | 3 of 3, cached: 3 ✔
[b3/d52708] convert_to_upper (3) | 3 of 3 ✔
```

Think about how all we did was connect the output of `say_hello` to the input of `convert_to_upper` and the two processes could be run in series. 
Nextflow did the hard work of handling individual input and output files and passing them between the two commands for us.

This is one of the reasons Nextflow channels are so powerful: they take care of the busywork involved in connecting workflow steps together. 
Let's now learn how to collect outputs from batched process calls and feed them into a single process.

### 5.2. Add a third step to collect all the greetings

When we use a process to apply a transformation to each of the elements in a channel, like we're doing here to the multiple greetings, we sometimes want to collect elements from the output channel of that process, and feed them into another process that performs some kind of analysis or summation. In the next step we're simply going to write all the elements of a channel to a single file, using the UNIX `cat` command.

#### Define the collection command and test it in the terminal

The collection step we want to add to our workflow will use the cat command to concatenate multiple uppercased greetings into a single file. 
Let's run the command by itself in the terminal to verify that it works as expected, just like we've done previously.

```bash
echo 'Hello' | tr '[a-z]' '[A-Z]' > upper_Hello_output.txt
echo 'Bonjour' | tr '[a-z]' '[A-Z]' > upper_Bonjour_output.txt
echo 'Hola' | tr '[a-z]' '[A-Z]' > upper_Hola_output.txt
cat upper_Hello_output.txt upper_Bonjour_output.txt upper_Hola_output.txt > collected_output.txt
```

The output is a text file called `collected_output.txt` that contains the uppercase versions of the original greetings.
Check the content of that file with `less collected_output.txt`; that is the result we want to achieve with our workflow.

#### Create a new process to do the collection step

Let's create a new process and call it `collect_greetings()`. We can start writing it based on the previous one, 
and add the following process definition to the workflow script:

```nextflow
// Collect uppercase greetings into a single output file
process collect_greetings {

    publishDir 'results', mode: 'copy'

    input:
        ???

    output:
        path "collected_output.txt"

    script:
    """
    ??? > 'collected_output.txt'
    """
}
```

We need to collect the greetings from all the calls to the `convert_to_upper()` process. The channel output from `convert_to_upper()` will contain the paths to the individual files containing the uppercased greetings. Hence we just need to add:

```nextflow
    input:
        path input_files
```

This is where things could get a little tricky, because we need to be able to handle an arbitrary number of input files. 
We can't write the command up front, so we need to tell Nextflow how to compose it at runtime based on what inputs flow into the process.

If we have an input channel containing the element `[file1.txt, file2.txt, file3.txt]`, we need Nextflow to turn that into `cat file1.txt file2.txt file3.txt`. 
Fortunately, Nextflow is quite happy to do that if we simply write `cat ${input_files}` in the script command.

In the process block, make the following code change:

```nextflow
    script:
    """
    cat ${input_files} > 'collected_output.txt'
    """
```
In theory this should handle any arbitrary number of input files.

#### Add the collection step to the workflow

Now we should just need to call the collection process on the output of the uppercasing step, and connect the process calls.
In the workflow block, make the following code change:

```nextflow
    // convert the greeting to uppercase
    convert_to_upper(say_hello.out)

    // collect all the greetings into one file
    collect_greetings(convert_to_upper.out)
```

This connects the output of `convert_to_upper()` to the input of `collect_greetings()`.
Run the workflow with `-resume`

```bash
nextflow run hello-workflow.nf -resume
```

It runs successfully, including the third step:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-workflow.nf` [mad_gilbert] DSL2 - revision: 6acfd5e28d

executor >  local (3)
[79/33b2f0] say_hello (2)         | 3 of 3, cached: 3 ✔
[99/79394f] convert_to_upper (3)   | 3 of 3, cached: 3 ✔
[47/50fe4a] collect_greetings (1) | 3 of 3 ✔
```

However, look at the number of calls for `collect_greetings()` on line 8. We were only expecting one, but there are three.

And have a look at the contents of the final output file `COLLECTED-outpu.txt` too. 
It seems that the collection step was run individually on each greeting, which is NOT what we wanted.
We need to do something to tell Nextflow explicitly that we want that third step to run on all the elements in the channel output by convert_to_upper().

#### Use an operator to collect the greetings into a single input

Let's add the `collect()` operator. Note that this time we're not adding the operator in the context of a channel factory, but to an output channel. 
We take the `convert_to_upper.out` and append the `collect()` operator, which gives us `convert_to_upper.out.collect()`. 
We can plug that directly into the `collect_greetings()` process call.

In the workflow block, make the following code change. 
Let's also include a couple of `view()` statements to visualize the before and after states of the channel contents.

```nextflow
    // collect all the greetings into one file
    collect_greetings(convert_to_upper.out.collect())

    // optional view statements
    convert_to_upper.out.view { greeting -> "Before collect: $greeting" }
    convert_to_upper.out.collect().view { greeting -> "After collect: $greeting" }
```

The `view()` statements can go anywhere you want; we put them after the call for readability. Run the workflow again with `-resume` 

```bash
nextflow run hello-workflow.nf -resume
```

It runs successfully, although the log output may look a little messier than this (we cleaned it up for readability).

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-workflow.nf` [soggy_franklin] DSL2 - revision: bc8e1b2726

[d6/cdf466] say_hello (1)       | 3 of 3, cached: 3 ✔
[99/79394f] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[1e/83586c] collect_greetings   | 1 of 1 ✔
Before collect: /workspaces/training/hello-nextflow/work/b3/d52708edba8b864024589285cb3445/UPPER-Bonjour-output.txt
Before collect: /workspaces/training/hello-nextflow/work/99/79394f549e3040dfc2440f69ede1fc/UPPER-Hello-output.txt
Before collect: /workspaces/training/hello-nextflow/work/aa/56bfe7cf00239dc5badc1d04b60ac4/UPPER-Holà-output.txt
After collect: [/workspaces/training/hello-nextflow/work/b3/d52708edba8b864024589285cb3445/UPPER-Bonjour-output.txt, /workspaces/training/hello-nextflow/work/99/79394f549e3040dfc2440f69ede1fc/UPPER-Hello-output.txt, /workspaces/training/hello-nextflow/work/aa/56bfe7cf00239dc5badc1d04b60ac4/UPPER-Holà-output.txt]
```

This time the third step was only called once. Looking at the output of the `view()` statements, we see the following:

- Three `Before collect`: statements, one for each greeting: at that point the file paths are individual items in the channel.
- A single `After collect`: statement: the three file paths are now packaged into a single element.

Have a look at the contents of the final output with `less results/collected_output.txt`. 
This time we have all three greetings in the final output file. Success! Remove the optional view calls to make the next outputs less verbose.
If you run this several times without `-resume`, you will see that the order of the greetings changes from one run to the next. 
This shows you that the order in which elements flow through process calls is not guaranteed to be consistent.

Let's now learn how to pass more than one input to a process.

### 3. Pass multiple input to a process and uniquely name the final output

We want to be able to name the final output file something specific in order to process subsequent batches of greetings without overwriting the final results. To that end, we're going to make the following refinements to the workflow:

- Modify the collector process to accept a user-defined name for the output file
- Add a command-line parameter to the workflow and pass it to the collector process

#### 3.1. Modify the collector process to accept a user-defined name for the output file

First, declare the additional input in the process definition. Good news: we can declare as many input variables as we want. Let's call this one batch_name.
In the process block, make the following code change:

```nextflow
    input:
        path input_files
        val batch_name
```

You can set up your processes to expect as many inputs as you want. Later on, you will learn how to manage required vs. optional inputs.
Use the `batch_name` variable in the output file name. In the process block, make the following code change:

```nextflow
    output:
        path "COLLECTED-${batch_name}-output.txt"

    script:
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    """
```

This sets up the process to use the `batch_name` value to generate a specific filename for the final output of the workflow.

#### 3.2. Add a batch command-line parameter

Now we need a way to supply the value for `batch_name` and feed it to the process call. 
You already know how to use the `params` system to declare CLI parameters. Let's use that to declare a `batch` parameter, with a default value.

In the pipeline parameters section, make the following code changes:

```nextflow
// Pipeline parameters
params.greeting = 'greetings.csv'
params.batch = 'test-batch'
```

Remember you can override that default value by specifying a value with `--batch` on the command line.

Now to pass the `batch` parameter to the process, we need to add it in the process call. In the workflow block, make the following code change:

```nextflow
    // collect all the greetings into one file
    collect_greetings(convert_to_upper.out.collect(), params.batch)
```

#### 3.3. Run the workflow

Let's try running this with a batch name on the command line.

```bash
nextflow run hello-workflow.nf -resume --batch trio
```

It runs successfully:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello-workflow.nf` [confident_rutherford] DSL2 - revision: bc58af409c

executor >  local (1)
[79/33b2f0] say_hello (2)       | 3 of 3, cached: 3 ✔
[99/79394f] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[b5/f19efe] collect_greetings   | 1 of 1 ✔
```

And produces the desired output, that we can check with `cat results/COLLECTED-trio-output.txt`.
Finally, we will learn how to emit multiple outputs and handle them conveniently.

### 4. Add an output to the collector step

When a process produces only one output, it's easy to access it (in the workflow block) using the `<process>.out` syntax. When there are two or more outputs, the default way to select a specific output is to use the corresponding (zero-based) index; for example, you would use `<process>.out[0]` to get the first output. This is not terribly convenient; it's too easy to grab the wrong index. Let's have a look at how we can select and use a specific output of a process when there are more than one.

For demonstration purposes, let's say we want to count and report the number of greetings that are being collected for a given batch of inputs. To that end, we're going to make the following refinements to the workflow:

- Modify the process to count and output the number of greetings
- Once the process has run, select the count and report it using `view` (in the workflow block)

#### 4.1. Modify the process to count and output the number of greetings

This will require two key changes to the process definition: we need a way to count the greetings, then we need to add that count to the `output` block of the process.

To count the number of greetings collected, Nextflow lets us add arbitrary code in the `script`: 
block of the process definition, which comes in really handy for doing things like this.

That means we can use the built-in `size()` function to get the number of files in the input_files array. 
Add the following to the `collect_greetings` process block:

```nextflow
    script:
        count_greetings = input_files.size()
    """
    cat ${input_files} > 'COLLECTED-${batch_name}-output.txt'
    """
```

In principle all we need to do is to add the `count_greetings` variable to the `output`: block.

However, while we're at it, we're also going to add some `emit`: tags to our output declarations. 
These will enable us to select the outputs by name instead of having to use positional indices.
Add the following to the process block:

```nextflow
    output:
        path "COLLECTED-${batch_name}-output.txt" , emit: outfile
        val count_greetings , emit: count
```

The `emit`: tags are optional, and we could have added a tag to only one of the outputs. We add them both for clarity.

#### 4.2. Report the output at the end of the workflow

Now that we have two outputs coming out of the `collect_greetings` process, the `collect_greetings.out` output contains two channels:

- `collect_greetings.out.outfile` contains the final output file
- `collect_greetings.out.count` contains the count of greetings

We could send either or both of these to another process for further work. However, in the interest of wrapping this up, 
we're just going to use `view()` to demonstrate that we can access and report the count of greetings.

Add the following to the workflow block:

```nextflow
    // collect all the greetings into one file
    collect_greetings(convert_to_upper.out.collect(), params.batch)

    // emit a message about the size of the batch
    collect_greetings.out.count.view { num_greetings -> "There were $num_greetings greetings in this batch" }
```

We could achieve a similar result with in many different ways, like using the count() operator, 
but this allows us to show how to handle multiple outputs, which is what we are after now.

### 4.3. Run the workflow

Let's run for the last time our code with our batch of greetings

```nextflow
nextflow run hello-workflow.nf -resume --batch trio
```

```batch
 N E X T F L O W   ~  version 24.10.0

Launching `hello-workflow.nf` [evil_sinoussi] DSL2 - revision: eeca64cdb1

[d6/cdf466] say_hello (1)       | 3 of 3, cached: 3 ✔
[99/79394f] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[9e/1dfda7] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```

Last line shows that we correctly retrieved the count of greetings processed. Feel free to add more greetings to the CSV and see what happens.
We have earned a long break. In next chapter we will learn how to modularize our code for better maintainability and code efficiency.