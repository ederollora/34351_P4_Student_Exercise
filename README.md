# P4 exercise for course 343451

## Introduction

Welcome to the your first contact with the P4 language! We have prepared a set of 4 exercises so that you can gain experience little by little. The exercise 1 will be done along with the teaching assistants, we will agree on a timeslot so that you can have an introductory session in P4.  Exercises 2 and 3 are supposed to be done by the students alone, although the level will still be acceptable. The final (4) exercise will consist of building an *answering machine* so that switches answer to ARP, ICMP and DHCP requests instead of end hosts or servers (i.e. a switch will answer an ARP request instead of a host.

1. [Basic Forwarding](./exercises/1_basic)

2. [Calculator](./exercises/2_calc)

3. [Source Routing](./exercises/3_source_routing)

4. [Answering Machine](./exercises/4_answering_machine)


## Slides

Please take a look at the [slides](http://bit.ly/p4d2-2018-spring) made available but the P4 language consortium and the [P4 tutorial](./P4_tutorial.pdf) in the current directory.

A P4 Cheat Sheet is also available [online](https://drive.google.com/file/d/1Z8woKyElFAOP6bMd8tRa_Q4SA1cd_Uva/view?usp=sharing)
so that you can have a quick document to look at for syntax reference or P4 specific constructs.

## How to build your VM

To complete the exercises described above, you need a Virtual Machine (VM) with all the necessary tools. We encourage you to build a VM instead of using your host (if unix) operating system. You will need to install [Vagrant](https://www.vagrantup.com/downloads.html) in your computer as well as [VirtualBox](https://www.virtualbox.org/wiki/Downloads). Vagrant is a very useful tool to build VMs based on blueprints such as *Vagrantfiles*. Vagrant will make use of the Virtualbox executable to create and deploy VMs. If you are not able to build the machine using Vagrant we will finally provide you with the VM file. However, we would really like you to use Vagrant as the process of creating the VM is extremely easy since all the necessary files have been extended from the official P4 consortium's deployment. It is a matter of running a couple of commands and installing two applications. The process of the actual VM building though, will take a long time.  

To build the VM:
- Create a Github account so that we can give you access to the repository.
- Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) in your computer and also [Vagrant](https://www.vagrantup.com/downloads.html) as said before.
- Install [Git](https://git-scm.com/downloads) or [Git with a GUI](https://git-scm.com/downloads/guis) like [GitHub Desktop](https://desktop.github.com/) or [Gitkraken](https://www.gitkraken.com/) and clone [this](https://github.com/ederollora/34351_P4_Student_Exercise) repository in your host operating system. Alternatively, if you don't want to install Git or a Git GUI client in your host's machine, you can download the repository as a ZIP file and uncompress it in your computer from [here](https://github.com/ederollora/34351_P4_Student_Exercise).
- Open the terminal console of your operating system and navigate to the folder of the repository you have just cloned or uncompressed (if you downloaded as ZIP).
- Then `cd` to the `vm` folder inside this repository folder: `cd vm`
- And run: `vagrant up`. This will take the `Vagrantfile` in the `vm` folder and start building your virtual machine according to the configuration in the `Vagrantfile`. You will see that a window pops up form virtualbox, don't close it. This means that the VM has been created but as you see in your host's terminal commands are still being executed. If you encounter any error if might be that you are not running `vagrant up` in the correct directory. Make sure that `Vagrantfile` is in the same directoriy as you are running the command.
- When the VM is finished (expect 1 or 2 hours to build it), make sure no errors were found in your host's terminal while the VM was being built. Check the latest output in the console once it has finished.
- Restart the VM for the last time with the VirtualBox window maximized.
- You should now see the user interface of your machine with several Desktop icons (Chrome, Wireshark, Atom, etc.) that we have built for you.
- Use Atom to do the exercises as it has a P4 language syntax highlighter installed.
- Finally, clone again [this](https://github.com/ederollora/34351_P4_Student_Exercise) repository in your new VM.
- One problem you may encounter is that your keyboard layout is wrong (unless you use the US layout). We will assist on this, or you can take a look [here](https://askubuntu.com/a/788319).
