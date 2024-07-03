---
title: "Cut and Run tutorial"
author:
- name: Arvin Zaker
  affiliation: University of Ottawa
output: pdf_document
papersize: letter
geometry: margin=2.54cm
---

# Step 1: Install dependencies

## Install git (optional)

Please google this to install git for your system.

## Install nix

This info is from the [nixos website](https://nixos.org/download)

### Windows
If you have windows, first install [Windows Subsystem for linux](https://learn.microsoft.com/en-us/windows/wsl/install)

Then press start and open the linux terminal.

In the terminal, run the following command:

```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### MacOS

Open terminal and run:

```
sh <(curl -L https://nixos.org/nix/install)
```

### Linux

Install the nix from your package manager. If not available, run:

```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

## Enable nix flakes

In the same terminal, run the following two commands to enable flakes:

```
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```
# Step 2: Setup the project folder

## Download the data files

Download the files  
Make sure all the `.fastq.gz` files are in the same place as each other.

## Download the project scripts


## Place them in one place


## Open the terminal in the project folder



# Step 2: Setup the development environment

In your project folder, simplify run

```
nix develop
```

After you enter the nix shell, run:

```
curl -s https://get.nextflow.io | bash
```

And thats it! The beauty of nix allows it to be this simple to make everything ready.

# Run the analysis

We have a 

```
./nextflow run nf-core/cutandrun -r 3.2.1 --input ./sheet.csv  --outdir ./results/ --genome GRCh38 -profile docker -c ./nextflow.config
```

# MISC

If you want a one-command to put for compute canada, use this command:


```
nix develop --command curl -s https://get.nextflow.io | bash && chmod +x ./nextflow && ./nextflow run nf-core/cutandrun -r 3.2.1 --input ./sheet.csv  --outdir ./results/ --genome GRCh38 -profile docker
```
