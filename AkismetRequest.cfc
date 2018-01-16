component accessors = "true" {

	property name = "author" type = "string" default = "";
	property name = "authorEmail" type = "string" default = "";
	property name = "authorURL" type = "string" default = "";
	property name = "charset" type = "string" default = "UTF-8";
	property name = "content" type = "string" default = "";
	property name = "dateUTC" type = "date" default = "";
	property name = "isTest" type = "boolean" default = "false";
	property name = "language" type = "string" default = "en_US";
	property name = "permalink" type = "string" default = "";
	property name = "postDateUTC" type = "date" default = "";
	property name = "referrer" type = "string" default = "";
	property name = "type" type = "string" default = "";
	property name = "userAgent" type = "string" default = "";
	property name = "userIP" type = "string" default = "";
	property name = "userRole" type = "string" default = "";

	AkismetRequest function init(required string applicationName, required string key, required string url, integer timeout = 5) {
		variables.userAgent = "#arguments.applicationName# | DonorDrive Akismet/0.0.1";
		variables.key = arguments.key;
		variables.url = arguments.url;
		variables.timeout = arguments.timeout;

		setDateUTC(now());
		setReferrer(cgi.http_referer);
		setUserAgent(cgi.http_user_agent);
		setUserIP(cgi.remote_addr);

		return this;
	}

	boolean function callSucceeded() {
		return structKeyExists(variables, "result") && variables.result.statusCode == "200 OK";
	}

	// https://akismet.com/development/api/#comment-check
	AkismetRequest function commentCheck(boolean throwOnError = false) {
		sendRequest("comment-check", arguments.throwOnError);

		return this;
	}

	string function getCallGUID() {
		return callSucceeded() && structKeyExists(variables.result.responseHeader, "x-akismet-guid") ? variables.result.responseHeader["x-akismet-guid"] : "";
	}

	string function getDebugInfo() {
		return callSucceeded() && structKeyExists(variables.result.responseHeader, "x-akismet-debug-help") ? variables.result.responseHeader["x-akismet-debug-help"] : "";
	}

	string function getProTip() {
		return callSucceeded() && structKeyExists(variables.result.responseHeader, "x-akismet-pro-tip") ? variables.result.responseHeader["x-akismet-pro-tip"] : "";
	}

	struct function getResult() {
		return duplicate(variables.result);
	}

	boolean function isValidComment() {
		return callSucceeded() && variables.result.fileContent == "false";
	}

	boolean function isValidKey() {
		return callSucceeded() && variables.result.fileContent == "valid";
	}

	private void function sendRequest(required string endpoint, required boolean throwOnError) {
		try {
			structDelete(variables, "result");

			cfhttp(
					method = "post",
					result = "variables.result",
					timeout = variables.timeout,
					url = "https://#variables.key#.rest.akismet.com/1.1/#arguments.endpoint#"
				) {
				cfhttpparam(type = "header", name = "User-Agent", value = variables.userAgent);

				cfhttpparam(type = "formfield", name = "blog", value = variables.url);
				cfhttpparam(type = "formfield", name = "blog_charset", value = getCharset());
				cfhttpparam(type = "formfield", name = "blog_lang", value = getLanguage());
				cfhttpparam(type = "formfield", name = "comment_author", value = getAuthor());
				cfhttpparam(type = "formfield", name = "comment_author_email", value = getAuthorEmail());
				cfhttpparam(type = "formfield", name = "comment_author_url", value = getAuthorURL());
				cfhttpparam(type = "formfield", name = "comment_content", value = getContent());
				cfhttpparam(type = "formfield", name = "comment_date_gmt", value = isDate(getDateUTC()) ? dateTimeFormat(getDateUTC(), "yyyy-mm-dd'T'HH:nn:ssZ") : "");
				cfhttpparam(type = "formfield", name = "comment_post_modified_gmt", value = isDate(getPostDateUTC()) ? dateTimeFormat(getPostDateUTC(), "yyyy-mm-dd'T'HH:nn:ssZ") : "");
				cfhttpparam(type = "formfield", name = "comment_type", value = getType());
				cfhttpparam(type = "formfield", name = "permalink", value = getPermalink());
				cfhttpparam(type = "formfield", name = "referrer", value = getReferrer());
				cfhttpparam(type = "formfield", name = "user_ip", value = getUserIP());
				cfhttpparam(type = "formfield", name = "user_role", value = getUserRole());

				if(getIsTest()) {
					cfhttpparam(type = "formfield", name = "is_test", value = getIsTest());
				}
			};
		} catch(Any e) {
			if(arguments.throwOnError) {
				rethrow;
			}
		}
	}

	// https://akismet.com/development/api/#submit-ham
	AkismetRequest function submitHam(boolean throwOnError = false) {
		sendRequest("submit-ham", arguments.throwOnError);

		return this;
	}

	// https://akismet.com/development/api/#submit-spam
	AkismetRequest function submitSpam(boolean throwOnError = false) {
		sendRequest("submit-spam", arguments.throwOnError);

		return this;
	}

	// https://akismet.com/development/api/#verify-key
	AkismetRequest function verifyKey(boolean throwOnError = false) {
		try {
			structDelete(variables, "result");

			cfhttp(
					method = "post",
					result = "variables.result",
					timeout = variables.timeout,
					url = "https://rest.akismet.com/1.1/verify-key"
				) {
				cfhttpparam(type = "formfield", name = "key", value = variables.key);
				cfhttpparam(type = "formfield", name = "blog", value = variables.url);
			};
		} catch(Any e) {
			if(arguments.throwOnError) {
				rethrow;
			}
		}

		return this;
	}

}