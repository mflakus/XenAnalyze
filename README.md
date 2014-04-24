XenAnalyze
==========

This is a place for my graduate work.  Mostly just configuration files and scripts to build virtual machines for testing and analysis


NOTES from Karen/Deron:
==========

Deron, I'm copying the three group members on this email so everyone has everyone's email address.  
Group members, Deron has said it is okay for you to email him directly with questions 
Karen



Hello,

Please forward this information to the students in CS533.    This is the location of all my files for my project.   I am really excited that they would like to work on this and I hope they find the subject as interesting (and challenging) as I have.



The first thing would be to fork the curent project on github.   Create a user login on github and then fork the project:
https://help.github.com/articles/fork-a-repo

The project name is:
    FeCastle/XenAnalyze

Once you get that you can assign users to the forked project and you can clone it.    If you don't want to use github, you can download it in a zip file as well.

Here are the "important" files:
    HowTo.txt:   How to build the Xen Server and Guest machines.  And some other instructions on how to setup things:  like the database for the tests.
    config:   Directory has a few config files.   May be useful to get first machines built.
    scripts:  A whole bunch of programs I wrote to manage virtual machines, run tests, collect performance data, and save or print the results.

Here are the programs in the 'scripts' directory:
- analyze.py DiskIO.py:  Not currently used, but this uses a Python library to collect the data.    Python has an amazing library to do all this.  
- collectGuest.pl collectHost.pl Collect.pm:  This is currently used to collect all the data from either the Guest or Host, and pass the data using XenBus.
- passData.sh (common.sh):  This is a small shell script that controls the benchmark between the guest and host.  
- getScaleFactor:  This is the benchmark, but has code to do a bunch of other things.
- updateGuest.sh:  Small script to copy all the code to the guests.  This will help since code has to run on the guests.

Here are some cool things that could be done:
- Change the benchmark to do more writes (Update and Insert), and collect I/O read and write data.  Then see if the interference is the same/similar to read I/O
- Use a different benchmark  to generate a different workload (Network, memory, I/O).
- Analyze other counters in guest and host.  I looked at NUMA counters, but could not conclude significant information.  I think this would be interesting to compare guests across NUMA zones.
- Analyze the sum of all counters of all guest machines versus the calculated overhead.  This is very interesting, but not very consistent.   The current tool will calculate this for you.
- Overcommit memory and see how this impacts guests.  I found this difficult to configure and setup for Xen.  
- Add 2+ physical disks and assign 1 disk to each VM (Pin disk like CPU Pin).  How does interference compare to a shared disk?
 
Please feel free to ask any questions.  

Deron
fecastle@gmail.com

