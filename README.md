Repository **AppendStationFiles**
---------------------------------

Tools for structure standardization of hystorical data collected by
[Institute of Alpine Environment - Eurac
Research](http://www.eurac.edu/en/research/mountains/alpenv/Pages/default.aspx)

Introduction
------------

This repository provide three scripts for the standardization of data
structure of the old data files and the new ones. We want to minimize
the number of files in order to extract mainenance information and to
homogenize headers in order to have a clear data structure. The scripts
recive inputs interactively and allow to the user a lot of different
configuration to perform the same procedures to differet data formats
and structures. The general workflow is: 1. Produce a file config
containing the structure inforamtions of files to process, for example
the first row of data or the date format etc... Input masks guide you to
fill in the proper way this file config. This step is done running the
scritp **01\_file\_config\_creator.R**

1.  Append files with the same header. All the files with the same
    structure are merged in order to reduce the number of files and to
    reconstruc the history of the stations. This is done with the script
    **02\_append\_files.R**

2.  To homogenize old station and new station data file format we build
    a script to convert the hobo files to campbell files. This
    conversion is done by **03\_convert\_hobo\_to\_campbell** using the
    function hobo\_to\_campbell contained in the package
    DataQualityCheckEuracAlpEnv

Goals
-----

1.  Append files with the same header.

2.  Convert files structure to TOA5 format to have the possibility to
    check data with exisisting Data Quality Check script.

How to install
--------------

-   Clone the repository from
    [GitLab](https://gitlab.inf.unibz.it/Christian.Brida/appendstationfiles.git).
    Writing on a GIT consolle (For example
    [gitforwindows](https://gitforwindows.org/),
    [gitshell](https://desktop.github.com/)):

<!-- -->

    git clone https://gitlab.inf.unibz.it/Christian.Brida/appendstationfiles.git

-   Updates: It could happend that in the devoloping phase we found a
    bug or we develop new features. To have the last version of scripts
    and functions please:

        git pull  # from a git consolle in the package! 

    and then repeat the procedure to install the package

Repository structure
--------------------

-   **Scripts**: Scripts to use to produce file configurator, append
    files with the same header and convert hobo stations to

-   **Data**: In data there are 2 examples of station, an old station
    with hobo logger and a new stations with cr1000 logger having a
    table format TOA5

-   **Settings**: here there are an example of file settings. Different
    configuration are used to read and check hobo station and campbell
    station.

How to use
----------

1.  Prepare file configuration: in the folder *Script* open the script
    **01\_file\_config\_creator.R**, eventually change the default
    setting dir (only for visualization in the input mask), select all
    and run!

2.  Append files: in the folder *Script* open the script
    **02\_append\_files.R**, set were the default (hobo/campbell) file
    configuration are, run the script passing the folder of the station.
    It creates automatically output directory.

3.  Convert hobo to campbell: in the folder *Script* open the script
    **03\_convert\_hobo\_to\_campbell.R**, set were the default
    (hobo/campbell) file configuration are, run the script passing the
    folder of the station. NOTE: It automatically search files in the
    subfolder output and save the result in the subfolder
    output\_campbell\_format

Contributors & Contacts:
------------------------

-   Brida Christian - Institute for Alpine Environment -
    [website](http://www.eurac.edu/it/aboutus/people/Pages/staffdetails.aspx?persId=39787),
    [GitLab](https://gitlab.inf.unibz.it/Christian.Brida)
-   Zandonai Alessandro - Institute for Alpine Environment -
    [website](http://www.eurac.edu/it/aboutus/people/Pages/staffdetails.aspx?persId=23703)
