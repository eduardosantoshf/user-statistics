# FirstSOProject

Using Bash scripts to see some stats about how users are using the operative system and display that on the terminal.

## Course
This project was developed under the [Operating Systems](https://www.ua.pt/en/uc/12293) course of [University of Aveiro](https://www.ua.pt/).

## How to run
The **userstats.sh** script allows viewing the number of sessions, total connection time (in minutes), maximum and minimum duration of the sessions of the selected users in the selected period.

User selection can be done:
* Through its own group (option **-g**)
* Through a regular expression that is verified with the users name (option **-u**)

The period selection is made by specifying the start date of the session from which the sessions are to be considered (option **-s**) and the session start date from which sessions should not be considered (option **-e**).

The display is sorted in ascending order of the username, but it can also appear sorted in other ways:
* Descending order (option **-r**)
* By number of sessions (option **-n**)
* By total time (option **-t**)
* By maximum time (option **-a**)
* By minimum time (option **-i**)

Run **userstats.sh**:
```console
$ ./userstats.sh [insert options]
```

The **comparestats.sh** script compares 2 files that safeguard the output of the userstats.sh command and produces a preview of the changes.

Run **comparestats.sh**:
```console
$ ./comparestats.sh [insert file #1] [insert file #2]
```

## Authors
* **Bruno Bastos**
* **Eduardo Santos**: [eduardosantoshf](https://github.com/eduardosantoshf)
