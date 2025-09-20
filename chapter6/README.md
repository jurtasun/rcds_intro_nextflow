## RCDS 2025 - Introduction to `Nextflow` & `nf-core`

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 700>
<img src="/readme_figures/nextflow-logo.png" width = 700>

### Chapter 6. Modularization.

This chapter covers how to organize your code in an efficient and sustainable way. Specifically, we are going to demonstrate how to use **modules**. In `Nextflow`, a **module** is a single process definition that is encapsulated in a single file. To use a module in a workflow, you just add a single-line import statement; then you can integrate the process into the workflow the same way you normally would.

When we started developing our workflow, we put everything in one single code file. Splitting processes into individual modules makes it possible to reuse process definitions in multiple workflows without producing multiple copies of the code. This makes the code more shareable, flexible and maintainable.

We're going to use as starting point the example we did in previous chapter. Create a script named `hello_modules.nf`, 

```bash
touch hello_modules.nf && code hello_modules.nf
```

and put together the following syntax:

```nextflow
#!/usr/bin/env nextflow

// Pipeline parameters
params.greeting = 'exercises/data/greetings_1.csv'
params.batch = 'test_batch'

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
        val batch_name

    output:
        path "collected_${batch_name}_output.txt", emit: outfile
        val count_greetings , emit: count

    script:
        count_greetings = input_files.size()
    """
    cat ${input_files} > 'collected_${batch_name}_output.txt'
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
    collect_greetings(convert_to_upper.out.collect(), params.batch)

    // emit a message about the size of the batch
    collect_greetings.out.count.view { num_greetings -> "There were $num_greetings greetings in this batch" }

}
```

This is exactly how we left our `hello_workflow.nf` file in the next chapter. Run it once to check the execution:

```bash
nextflow run hello_modules.nf
```

You should find the expected output:

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_modules.nf` [festering_nobel] DSL2 - revision: eeca64cdb1

executor >  local (7)
[25/648bdd] say_hello (2)       | 3 of 3 ✔
[60/bc6831] convert_to_upper (1) | 3 of 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1 ✔
There were 3 greetings in this batch
```

As previously, you will find the output files in the `results` directory, as specified by the `publishDir` directive.

### 6.1. Create a directory to store modules

It is best practice to store your modules in a specific directory. You can call that directory anything you want, but the convention is to call it `modules/`.

```bash
mkdir modules
```

Here we are showing how to use local modules, meaning modules stored locally in the same folder or repository as the rest of the workflow code. 
In contrast to remote modules, which are stored in other (remote) repositories.

### 6.2. Create a module for `say_hello()`

In its simplest form, turning an existing process into a module is little more than a copy-paste operation. We're going to create a file *stub* for the module, copy the relevant code over then delete it from the main workflow file. Then all we'll need to do is add an import statement so that Nextflow will know to pull in the relevant code at runtime.

#### Create a file for the new module

Let's create an empty file for the module called say_hello.nf.

```bash
touch modules/say_hello.nf
```

This gives us a place to store the code for the `say_hello` process.

#### Move the `say_hello` process code to the module file

Copy the whole process definition over from the workflow to the module file, making sure to copy over the `#!/usr/bin/env` nextflow shebang too.

```nextflow
#!/usr/bin/env nextflow

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
```

And delete the process definition from the workflow file.

#### Add an import declaration before the workflow block

The syntax for importing a local module is straightforward:

```nextflow
include { <MODULE_NAME> } from '<path_to_module>'
```

In our case, that will be just:

```nextflow
// Include modules

// Process printing 'Hello World!' to a file
include { say_hello } from './modules/say_hello.nf'

// (...)

workflow {
```   

#### Run the workflow to verify execution remains the same

We're running the workflow with essentially the same code and inputs as before, so let's run with the `-resume` flag and see what happens.

```bash
nextflow run hello_modules.nf -resume
```

This runs quickly very quickly because everything is cached.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_modules.nf` [romantic_poisson] DSL2 - revision: 96edfa9ad3

[f6/cc0107] say_hello (1)       | 3 of 3, cached: 3 ✔
[3c/4058ba] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```
Nextflow recognized that it's still all the same work to be done, even if the code is split up into multiple files.

### 6.3. Modularize the `convert_to_upper()` process

#### Create a file stub for the new module

Create an empty file for the module called `convert_to_upper.nf`.

```bash
touch modules/convert_to_upper.nf
```

#### Move the `convert_to_upper` process code to the module file

Copy the whole process definition over from the workflow file to the module file, making sure to copy over the `#!/usr/bin/env` nextflow shebang too.

```nextflow
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
```
Once that is done, delete the process definition from the workflow file, but make sure to leave the shebang in place.

#### Add an import declaration before the workflow block

Insert the import declaration above the workflow block and fill it out appropriately.

```nextflow
// Include modules

// Process printing 'Hello World!' to a file
include { say_hello } from './modules/say_hello.nf'

// Process converting content of file to upper case
include { convert_to_upper } from './modules/convert_to_upper.nf'

// (...)

workflow {
```

#### Run the workflow to verify execution remains the same

Run this with the `-resume` flag.

```bash
nextflow run hello_modules.nf -resume
```
This should still produce the same output as previously.

```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_modules.nf` [nauseous_heisenberg] DSL2 - revision: a04a9f2da0

[c9/763d42] say_hello (3)       | 3 of 3, cached: 3 ✔
[60/bc6831] convert_to_upper (3) | 3 of 3, cached: 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```

Let's do it one last time fo have the code completely modularized.

### 6.4. Modularize the `collect_greetings()` process

#### Create a file stub for the new module

Create an empty file for the module called `collect_greetings.nf`.

```bash
touch modules/collect_greetings.nf
```

#### Move the collect_greetings process code to the module file

Copy the whole process definition over from the workflow file to the module file, making sure to copy over the `#!/usr/bin/env` nextflow shebang too.

```nextflow
#!/usr/bin/env nextflow

// Collect uppercase greetings into a single output file
process collect_greetings {

    publishDir 'results', mode: 'copy'

    input:
        path input_files
        val batch_name

    output:
        path "collected_${batch_name}_output.txt", emit: outfile
        val count_greetings , emit: count

    script:
        count_greetings = input_files.size()
    """
    cat ${input_files} > 'collected_${batch_name}_output.txt'
    """

}
```

And delete the process definition from the workflow file, but make sure to leave the shebang in place.

#### Add an import declaration before the workflow block

Insert the import declaration above the workflow block and fill it out appropriately.

```nextflow
// Include modules

// Process printing 'Hello World!' to a file
include { say_hello } from './modules/say_hello.nf'

// Process converting content of file to upper case
include { convert_to_upper } from './modules/convert_to_upper.nf'

// Collect uppercase greetings into a single output file
include { collect_greetings } from './modules/collect_greetings.nf'

workflow {
```

#### Run the workflow to verify that it does the same thing as before

Run this with the `-resume` flag.

```bash
nextflow run hello_modules.nf -resume
```

This should still produce the same output as previously.


```bash
 N E X T F L O W   ~  version 24.10.0

Launching `hello_modules.nf` [friendly_coulomb] DSL2 - revision: 7aa2b9bc0f

[f6/cc0107] say_hello (1)       | 3 of 3, cached: 3 ✔
[3c/4058ba] convert_to_upper (2) | 3 of 3, cached: 3 ✔
[1a/bc5901] collect_greetings   | 1 of 1, cached: 1 ✔
There were 3 greetings in this batch
```

You know how to modularize multiple processes in a workflow.

Congratulations, you've done all this work and absolutely nothing has changed to how the pipeline works!

Now your code is more modular, and if you decide to write another pipeline that calls on one of those processes, you just need to type one short import statement to use the relevant module. This is better than just copy-pasting the code, because if later you decide to improve the module, all your pipelines will inherit the improvements.

### 6.1 Manage software environments

A **container** is a lightweight, portable unit that packages an application together with everything it needs to run: code, runtime, libraries, and dependencies. 
Unlike virtual machines, containers *share the host operating system kernel*, which makes them faster and more efficient. 
The most widely used container platform is `Docker`, which lets you create, run, and manage containers.

Keep in mind that containers are similar to *environments* and v*irtual machines*, but not the same. 
When we run software, we often need to isolate dependencies so that projects don't interfere with each other. There are three common approaches:

#### Environments (`conda`, `venv`, `pipenv`)

- Isolate only *language-specific dependencies* (like `Python` packages). 
- They are lightweight, but rely on the host system's OS and libraries.
- (...)

#### Virtual Machines (`VirtualBox`, `VMware`, `Hyper-V`)

- Emulate *a full computer*, including its own kernel. 
- Heavier: need dedicated CPU, memory, disk space. 
- Used when you need to run an entirely different operating system.
- (...)

#### Containers (`Docker`, `Singularity`, `Podman`, `LXC`)

- Package *the entire software stack*: the application with its code, runtime, libraries, and tools.
- Share the host kernel (lighter than VMs).
- Consistent across environments runs the same on any machine with Docker.
- (...)

As a final note, you may have heared about `Kubernetes`. These are a high-level tool built from the idea of the containers, which orchestrate many containers across multiple machine, scheduling containers, handles network and storage, etc. Here we will focus on the idea of containers and how to use them for sustainable, reproducible software.
