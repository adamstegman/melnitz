# Melnitz

[Working title][melnitz].
Sorts the mail and presents it in a dashboard so you can act on it instead of trying to figure out threads on your own.

## Usage

TODO: configuration within the UI (issue #7)

## Design

Melnitz will sort your email with a particular focus on JIRA, Crucible, uCern, and uCern Wiki.
There are three sections:

* Personal
* Issues
* Projects
* uCern

### Personal

Personal emails are the ones that Melnitz has no particular rules about.
They are considered "personal", to be handled by you.

### Issues

Issue emails are those from JIRA and Crucible.
They are grouped by story, the "parent" JIRA issue.
Subtask JIRAs are in the same thread as the story.
The JIRA API is used to sort these by "importance" to you:

1. Issues you are assigned to
2. Issues you have contributed to
3. Issues you have commented on
4. Issues you have reported
5. Issues you have no connection with

It is assumed that Crucible review titles contain the JIRA issue number.

### Projects

Project notation is the project name surrounded by square brackets, e.g. "[provider_portal]".
Emails with a project in the subject are grouped together under this tab.
Those emails are then grouped under each project by the thread they are in, grouping JIRA emails by story as explained above.

### uCern

uCern emails are grouped by thread and uCern Wiki emails by page under this tab.

## Development

Install at least version 7 of the JDK.

Download the [EWS Java dependency][ewsapi] and extract it to `vendor/lib`.

    mkdir -p vendor/lib
    cp ~/Downloads/EWSJavaAPI_1.2/EWSJavaAPI_1.2.jar vendor/lib/

Download the remaining dependencies and then start the Rails server.

    bundle
    jbundle
    script/rails server

### Packaging and release

TODO

## License

Copyright © 2013 Adam Stegman

Distributed under the MIT License.

[ewsapi]: http://archive.msdn.microsoft.com/ewsjavaapi
[maven]: http://maven.apache.org/
[melnitz]: http://en.wikipedia.org/wiki/Janine_Melnitz
