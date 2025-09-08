## RCDS 2025 - Introduction to `Nextflow` for reproducible scientific workflow

### Jesús Urtasun Elizari, ICL Research Computing & Data Science

ICL email address `jurtasun@ic.ac.uk`

LMS email address `Jesus.Urtasun@lms.mrc.ac.uk`

<img src="/readme_figures/imperial_ecri.png" width = 700>
<img src="/readme_figures/nextflow-logo.png" width = 700>

### Find the content of the course in GitHub:
[https://github.com/jurtasun/rcds_intro_nextflow](https://github.com/jurtasun/rcds_intro_nextflow)

This course provides an introduction to `Nextflow` and `nf-core` automated pipelines for reproducible scientific workflows.
Even though it is commonly used in biological and clinical sciences, such as genomics and bioinformatics, 
`Nextflow` is a multi-purpose, versatile and powerful scripting language that can be applied to many different fields and tasks.
The topics covered will include basic concepts on `bash` scripting and Linux OS, introduction `Groovy` as the language upon which `Nextflow` is written,
and an overview on container technologies. All these will be covered at introductory level; 
then we will show how `Nextflow` can be used to build automatized and workflows for robust and reproducible data analysis.

The course is organized in seven chapters, covering the topics listed below. All will be followed by a practical session and hands-on coding.
No prior experience on programming, statistics or data analysis is required for the attendance of this course, 
as all topics will be properly introduce as the course progresses.

## Roadmap of the course

### Chapter 1. Introduction to `Groovy`.

- Introduction to `Groovy` basic syntax and applications.
- Maps, parameters, data processing.
- Closures, collections, connection to `Nextflow`.

### Chapter 2. Basic `Nextflow` syntax.

- Channels: data flow, queue and value channels.
- Processes: executing functions.
- Operators: produce, chain and manipulate channels.

### Chapter 3. Hello world with `Nextflow`.

- Channels, processes, operators in a real case.
- General structure and workflow of a `Nextflow` pipeline.
- Hello world with `Nexftlow`.

### Chapter 4. Channels and operators.

- Provide variable inputs via a channel explicitly.
- Adapt workflow to run on multiple input values.
- Use an operator to transform the contents of a channel.

### Chapter 5. General workflow.

- Add steps to make more flexible workflow.
- Add a batch command-line parameter.
- Add an output to the collector step.

### Chapter 6. Containers and modularization.

- Modularize a `Nextflow` pipeline.
- The idea of containers: Docker and Singularity.
- Containers 'manually', containers in `Nextflow`.

### Chapter 7. `Nextflow` config and `nf-core`.

- The `hello-config` directory.
- Symbolic links, containers, submission script through `Nextflow` config.
- Load pipelines from `nf-core`, run on HPC and parallelization.

### Setup

We will be working with the terminal of Linux OS, Visual Studio Code as main editor, and `Groovy` / `Nextflow` languages.
They do not need to be installed in your local computer, since we will use `Codespaces` provided by Github, 
which already implement an interface ready to program an execute the code. If you want to follow the course in your local machine,
please follow the steps below to install `Groovy`, `Java Development Kit` (JDK), and `Nextflow`.

### Getting Started

1. Download this repository to your computer as a ZIP file and unpack it.

2. Open the terminal and navigate to the unpacked directory to work with the .nf examples.

3. Open a `Codespace` where we will be using either Visual Studio Code fro the practical sessions.

### Install and run `Nextflow` locally in your machine

1. Install `homebrew`

Go to the `homebrew` site [https://brew.sh](https://brew.sh) and run the following command.
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. Install `Java Development Kit` (open source implementation of `Java`)

Check the latest JDK relase [https://formulae.brew.sh/formula/openjdk#default](https://formulae.brew.sh/formula/openjdk#default) and run the following command.
```bash
brew install openjdk@21
```

3. Install `Nextflow`

Visit the nextdlow site [https://www.nextflow.io](https://www.nextflow.io) and follow the steps for installation.

Run the following command to check java version.
```bash
java -version
```

Run the following command to download `Nextflow`.
```bash
curl -s https://get.nextflow.io | bash
```

Check the path variable on your computer.
```bash
echo $PATH
```

Here is where all sotfwares installed with homebrew are stored. Move the downloaded `nextflow` executable file there.
```bash
sudo mv nextflow /opt/homebrew/bin/
```

Move to the previous address and run the executable file there.
```bash
cd /opt/homebrew/bin/ && ./nextflow run hello
```

Run the same thing connecting to the `hello` repository of `nextflow`.
```bash
nextflow run hello
```

Congrats! You have `Nextflow` succesfully installed in your computer.

4. Install docker (outside of HPC)

Visit the Docker website [https://www.docker.com](https://www.docker.com) and follow the installation instrunctions.

Move `docker.dmg` file to Applications folder.

Check successfull installation of docker, and run `Nextflow` adding the `-with-docker` argument.
```bash
nextflow run hello -with-docker
```

5. Install singularity (for HPC)
Visit the Singularity website [https://docs.sylabs.io/guides/3.5/admin-guide/installation.html](https://docs.sylabs.io/guides/3.5/admin-guide/installation.html) and follow the installation instructions.

Check successfull installation of singulariy.
```bash
nextflow run hello -with-docker
```

### Evaluation

Your feedback is very important to the Graduate School as we are continually trying to improve the training we offer.
At the end of the course, please help us by completing the evaluation form at [...]

<hr>
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
