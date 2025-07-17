## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 500>

### Chapter 3. `Hello world` with `Nextflow`

In this first chapter we will illustrate with h a very basic `Hello World` example, 
and we will progressively build up to introduce the usage of foundational `Nextflow` logic and components. 
We will demonstrate the basic syntax and structure of a programming language or software framework.
The example we will do consists of printing the phrase "Hello, World!" to the output device, such as the console or terminal, or writing it to a file.

Let's demonstrate how to write a simple sentence with a `bash` command directly in the terminal, to show what it does before we wrap it in `Nextflow`.
Write the following command in your terminal:

```bash
echo 'Hello World!'
```

We can modify this command such that the message is stored in in a file with the `>` character, rather than printed on screen.

```bash
echo 'Hello World!' > output.txt
```

And then check the content of the file with:

```bash
less output.txt
```

type `q` to quit the visualization mode. Equivalently, you can check the content of the file without entering the view mode with:

```bash
cat output.txt
```

Once we know how to run a simple command in the terminal that outputs some text, and how to write the output to a file,
we can see how this would look like written as a `Nextflow` workflow.

### 1. Hello World with `Nextflow`

Let's create a file called `hellow_world.nf` with the `touch` command:

```bash
touch hello_world.nf
```

And open it with our text editor `VSCode`.

```bash
code hello_world.nf
```

Now let's put together the following syntax.

```nextflow
#!/usr/bin/env nextflow

// Use echo to print 'Hello World!' to a file
process say_hello {

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
```
As you can see, a `Nextflow` script involves two main types of core components: one or more **processes**, and the **workflow** itself. 
Each **process** describes the operation - or operations - the corresponding step in the pipeline should perform, 
while the **workflow** describes the logic, the data flow that connects the various steps.

Let's take a closer look at the process block first, then we'll look at the workflow block.

#### 1.1. The `process` definition

The first block of code describes a **process**. Its definition starts with the keyword `process`, 
followed by the process name and finally the process body delimited by curly braces. 
The process body must contain a script block which specifies the command to run, which can be anything you would be able to run in a command line terminal.

Here we have a process called `say_hello` that writes its output to a file named `output.txt`.

```nextflow
// Use echo to print 'Hello World!' to a file
process say_hello {

    output:
        path 'output.txt'

    script:
    """
    echo 'Hello World!' > output.txt
    """

}
```

This is a very minimal process definition that just contains an `output` definition and the `script` to execute.

The `output` definition includes the `path` identifier, which tells `Nextflow` this should be handled as a path 
(includes both directory paths and files). Another common qualifier is `val`, which we will use later in the example.

Keep in mind that this is just an example, and we hardcoded the output filename in two separate places (the script and the output blocks). 
If we change one but not the other, the script will break. Later, you'll learn how to use variables to avoid this problem.

In a real-world pipeline, a process usually contains additional blocks such as directives and inputs, which we'll introduce later as well.

#### 1.2. The `workflow` definition

The second block of code describes the **workflow** itself. The definition starts with the keyword `workflow`, 
followed by an optional name, then the workflow body delimited by curly braces.

Here we have a **workflow** that consists of one call to the `say_hello` process.

```nextflow
// Define workflow
workflow {

    // emit a greeting
    say_hello()

}
```

This is a very minimal **workflow** definition. In a real-world pipeline, the workflow typically contains multiple calls to **processes** connected by **channels**, 
and the processes expect one or more variable inputs.

You'll learn how to add variable inputs later and how to add more processes and connect them by channels in further chapters of this course.

### 2. Run the `hello_world.nf` `Nextflow` script

#### 2.1. Run and check execution

Let's try this out this in practice. In the terminal, run the code with the following command:

```nextflow
nextflow run hello_world.nf
```

You console output should look something like this:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_world.nf` [voluminous_gauss] DSL2 - revision: 060e42a3e2

executor >  local (1)
[ca/e2bae8] say_hello | 1 of 1 ✔
```

Congratulations, you just ran your first `Nextflow` workflow! The most important output here is the last line:
```output
[ca/e2bae8] say_hello | 1 of 1 ✔
```

This tells us that the `say_hello` process was successfully executed once (`1 of 1 ✔`).
Importantly, this line also tells you where to find the output of the say_hello process call. Let's look at that now.

#### 2.2. Check output in the `work` directory

When you run `Nextflow` for the first time in a given directory, 
it creates a directory called `work` where it will write all files (and any symlinks) generated during the execution.

Within the `work` directory, `Nextflow` organizes outputs and logs per process call. For each process call, `Nextflow` creates a nested subdirectory, named with a hash in order to make it unique, where it will stage all necessary inputs (using symlinks by default), write helper files, and write out logs and any outputs of the process.

The path to that subdirectory is shown in truncated form in square brackets in the console output. Looking at what we got for the run shown above, the console log line for the say_hello process starts with `[ca/e2bae8]`. That corresponds to the following directory path: `work/ca/e2bae82f46e3f6a18d601126f37fe4/`

Let's take a look at what's in there.

```bash
ls -l work
```

The log files are set to be invisible in the terminal, so if you want to use `ls` or `tree` to view them, 
you'll need to set the relevant option for displaying invisible files.

```bash
ls -l work
```
or equivalently

```bash
tree -a work
```

You should see something like this, though the exact subdirectory names will be different on your system:

```bash
work
└── ca
    └── e2bae82f46e3f6a18d601126f37fe4
        ├── .command.begin
        ├── .command.err
        ├── .command.log
        ├── .command.out
        ├── .command.run
        ├── .command.sh
        ├── .exitcode
        └── output.txt
```

These are the helper and log files than you can check for debugging a run:

- `.command.begin`: Metadata related to the beginning of the execution of the process call
- `.command.err`: Error messages (`stderr`) emitted by the process call
- `.command.log`: Complete log output emitted by the process call
- `.command.out`: Regular output (`stdout`) by the process call
- `.command.run`: Full script run by `Nextflow` to execute the process call
- `.command.sh`: The command that was actually run by the process call
- `.exitcode`: The exit code resulting from the command

The `.command.sh` file is especially useful because it tells you what command `Nextflow` actually executed. In this case it's very straightforward, but later in the course you'll see commands that involve some interpolation of variables. When you're dealing with that, you need to be able to check exactly what was run, especially when troubleshooting an issue.

The actual output of the `say_hello` process is `output.txt`. Open it and you will find the Hello World! greeting, which was the expected result of our first workflow.

Let's now learn how to manage the workflow executions conveniently.

### 3. Directives and manage executions

Here we will learn to use the `publishDir` directive to store in an output folder all the main results from your pipeline run, the `resume` feature for when you need to re-launch the same workflow, and how to delete older work directories with `nextflow clean`.

#### 3.1. Publish outputs

As we have just seen, the output produced by our pipeline is buried in a working directory several layers deep. 
This is done on purpose; `Nextflow` is in control of this directory and we are not supposed to interact with it. 
However, that makes it inconvenient to retrieve outputs that we care about.

Fortunately, `Nextflow` provides a way to manage this more conveniently, called the `publishDir` directive, which acts at the process level. 
This directive tells `Nextflow` to publish the output of the process to a designated output directory. By default, 
the outputs are published as symbolic links from the `work` directory.

Let's add a `publishDir` directive to the `say_hello` process. 
In the file hello_world.nf, make the following code modification:

*Before:*
```bash
process say_hello {

    output:
        path 'output.txt'

```
*After:*
```bash
process say_hello {

    publishDir 'results', mode: 'copy'

    output:
        path 'output.txt'

```

Run the modified script:

```bash
nextflow run hello_world.nf
```

The log output should look very similar:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_world.nf` [scruffy_lamarck] DSL2 - revision: b91d39aaa6

executor >  local (1)
[fd/04e105] say_hello | 1 of 1 ✔
```

This time, Nextflow has created a new directory called `results/`. Our `output.txt` file is in this directory. 
If you check the contents it should match the output in the work subdirectory. This is how we publish results files outside of the working directories conveniently.

When you're dealing with very large files that you don't need to retain for long, you may prefer to set the `publishDir` directive to make a symbolic link to the file instead of copying it. However, if you delete the work directory as part of a cleanup operation, you will lose access to the file, so always make sure you have actual copies of everything you care about before deleting anything.

#### 3.2. Re-launch a workflow with `-resume`

Nextflow has an option called `-resume` that allows you to do this. Specifically, in this mode, any processes that have already been run with the exact same code, settings and inputs will be skipped. This means Nextflow will only run processes that you've added or modified since the last run, or to which you're providing new settings or inputs.

There are two key advantages to doing this:

- You can iterate more rapidly since you only have to run the process(es) you're actively working on in order to test your changes.
- You can fix aun issue and relaunch the pipeline, and it will resume running from the point of failure, which can save you a lot of time and compute.

To use it, simply add `-resume` to your command and run it:

```bash
nextflow run hellow_world.nf -resume
```

The output should look again familiar:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_world.nf` [golden_cantor] DSL2 - revision: 35bd3425e5

[fd/04e105] say_hello | 1 of 1, cached: 1 ✔
```

But we find now the `cached:` bit that has been added in the process status line (line 5), 
indicating that Nextflow has recognized that it has already done this work and simply re-used the result from the previous successful run.

You can also see that the work subdirectory hash is the same as in the previous run. 
Nextflow is literally pointing to the previous execution and saying "I already did that over there."

### 4. Work on multiple inputs

In its current state, our workflow uses a greeting hardcoded into the process command. 
To add some flexibility we can use an input variable, so we can more easily change the greeting at runtime. 
This requires us to make three changes to our script:

- Tell the process to expect a variable input by adding an `input:` block
- Edit the process to use that input
- Set up a command-line parameter and provide its value as an input to the process call

Let's make these changes one at a time. 

#### 4.1. Add an input block to the process definition

First, add an input block to the process definition. In the process block, make the following modifications:

*Before:*
```bash
process say_hello {

    publishDir 'results', mode: 'copy'

    output:
        path 'output.txt'

```

*After:*
```bash
process say_hello {

    publishDir 'results', mode: 'copy'

    input:
        val greeting

    output:
        path 'output.txt'

```

Now the `greeting` variable is prefixed by val to tell Nextflow it's a value entered by keyboard, not a path.

#### 4.2. Edit the process command to use the input variable

Now let's edit the process `script` section to use the input variable, instead of the original hardcoded value. 
In the process block, make the following code change:

*Before:*
```bash
script:
"""
echo 'Hello World!' > output.txt
"""
```

*After:*
```bash
script:
"""
echo '$greeting' > output.txt
"""
```

Make sure to add the `$` symbol to tell Nextflow this is a variable name that needs to be replaced - also called *interpolated* - with the actual value.

#### 4.3. Set up a CLI parameter and provide it as input to the process call

Now we need to actually set up a way to provide an input value to the `say_hello()` process call. 
Nextflow has a built-in workflow parameter system called `params`, which makes it easy to declare and use CLI parameters. 
The general syntax is to declare `params.<parameter_name>` to tell Nextflow to expect a `--<parameter_name>` parameter on the command line.

The way we create this value is by adding the `--greeting` parameter in our execution, and then declare `params.greeting` somewhere in the workflow. 
In principle we can write it anywhere; but since we're going to want to give it to the `say_hello()` process call, 
we can plug it in there directly by writing `say_hello(params.greeting)`.

In the workflow block of `hellow_world.nf` file, make the following code change:

*Before:*
```bash
// emit a greeting
say_hello()
```

*After:*
```bash
// emit a greeting
say_hello(params.greeting)
```

This tells Nextflow to run the `say_hello` process on the value provided through the `--greeting` parameter.

#### 4.1.4. Run the workflow command again

Let's run our modified script

```bash
nextflow run hello_world.nf --greeting 'Bonjour le monde!'
```

If we made all three edits correctly, we should get another successful execution:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_world.nf` [elated_lavoisier] DSL2 - revision: 7c031b42ea

executor >  local (1)
[4b/654319] say_hello | 1 of 1 ✔
```

If we now open the output file we should find that it now contains the updated version of the greeting.
