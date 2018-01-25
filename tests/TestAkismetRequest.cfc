component extends = "mxunit.framework.TestCase" {

	function setup() {
		variables.akismetRequest = new lib.akismet.AkismetRequest(
			applicationName = "MXUnit Test",
			key = "[ YOUR KEY HERE ]",
			url = "[ YOUR BLOG URL HERE ]"
		);

		variables.akismetRequest.setIsTest(true);
	}

	function testCommentCheck_ham() {
		variables.akismetRequest
			.setAuthorRole("administrator")
			.setContent("MX Unit Test")
			.commentCheck(true);

		debug(variables.akismetRequest.getResult());
		assertTrue(variables.akismetRequest.callSucceeded());
		assertTrue(variables.akismetRequest.isValidComment());
	}

	function testCommentCheck_spam() {
		variables.akismetRequest
			.setAuthor("viagra-test-123")
			.setAuthorEmail("akismet-guaranteed-spam@example.com")
			.setContent("MX Unit Test")
			.commentCheck(true);

		debug(variables.akismetRequest.getResult());
//		debug(variables.akismetRequest.getProTip());
//		debug(variables.akismetRequest.getCallGUID());
//		debug(variables.akismetRequest.getDebugInfo());
		assertTrue(variables.akismetRequest.callSucceeded());
		assertFalse(variables.akismetRequest.isValidComment());
	}

	function testSubmitHam() {
		variables.akismetRequest
			.setAuthorRole("administrator")
			.setContent("MX Unit Test Ham")
			.submitHam(true);

		debug(variables.akismetRequest.getResult());
		assertTrue(variables.akismetRequest.callSucceeded());
	}

	function testSubmitSpam() {
		variables.akismetRequest
			.setAuthorRole("administrator")
			.setContent("MX Unit Test Spam")
			.submitSpam(true);

		debug(variables.akismetRequest.getResult());
		assertTrue(variables.akismetRequest.callSucceeded());
	}


	function testVerifyKey() {
		variables.akismetRequest.verifyKey(true);
		debug(variables.akismetRequest.getResult());
		assertTrue(variables.akismetRequest.callSucceeded());
		assertTrue(variables.akismetRequest.isValidKey());
	}


}