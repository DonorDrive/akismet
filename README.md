# Akismet
A ColdFusion client for Akismet
- https://akismet.com/development/

## Installation
The unit tests assume that Akismet resides inside a ```lib``` directory (under webroot, or explicitly mapped in the application).

## Usage
The library comprises of a single CFC: ```AkismetRequest```. Instantiation requires the name of the application, the API key, and the URL associated with the blog/site:
```
akismetRequest = new lib.akismet.AkismetRequest(
	applicationName = "MyTestApplication",
	key = [API KEY],
	url = "https://my.domain.com/"
);
```

Additional values are simple properties of the ```AkismetRequest``` and may be chained after instantiation:
```
akismetRequest
  .setAuthor("author")
  .setAuthorEmail("email@example.com")
  .setAuthorIPAddress(cgi.remote_addr)
  .setAuthorUserAgent(cgi.http_user_agent)
  .setContent("this is some content")
  .setDateUTC(local2utc(now()))
  .setIsTest(false)
  .setLanguage("en")
  .setPermalink("https://my.domain.com/this/is/the/path/to/the/post")
  .setReferrer(cgi.http_referer)
  .setType("comment");
```

The Akismet API has 4 methods, all of which are supported by the ```AkismetRequest``` component. Each method supports a single optional parameter: ```boolean throwOnError = false```
- ```verifyKey()``` - authenticates the key to be used with the other 3 methods
- ```commentCheck()``` - asserts whether the furnished content is spammy or not
- ```submitHam()``` - informs Akismet the furnished content is ham (a legitimate message)
- ```submitSpam()``` - informs Akismet the furnished content is spam

After an API method has been invoked, the ```callSucceeded()``` method may be checked, and the request may subsequently be inspected.
```
akismetRequest = new lib.akismet.AkismetRequest(...)
  .setAuthorEmail("akismet-guaranteed-spam@example.com")
  .commentCheck();

if(akismetRequest.callSucceeded()) {
  if(akismetRequest.isValidComment()) {
    // comment is valid, proceed
  } else {
    // spam!
    if(akismetRequest.getProTip() == "discard") {
      // this message is confirmed spam by Akismet
    } else {
      // review this message
    }
  }
} else {
  // the API call failed
}
```

For the purpose of debugging, the raw HTTP result can be retrieved after an API method has been called, using ```getResult()``` 
