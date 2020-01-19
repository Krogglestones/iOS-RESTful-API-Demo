# iOS-RESTful-API-Demo
A RESTful API demo from Pluralsight that calls Github's Gist API and adds a new gist programmatically.

In order to create a new gist for your Github Profile, you'll need to make 1 code adjustment:

1) In the DataService.swift file, look for a function called "createAuthCredentials()"

2) Change the authString variable from "XXXX:XXXX" to "yourGithubUserName:githubPassword"

Clicking the "new" button will now add a "Hello World" gist to your Github Profile.
