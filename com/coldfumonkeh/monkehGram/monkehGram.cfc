component accessors="true" extends="base" {
	
	property name="client_id" 		type="string";
	property name="client_secret" 	type="string";
	property name="redirect_uri" 	type="string";
	property name="access_token" 	type="string";
	property name="baseURL"			type="string" default="https://api.instagram.com/";
	
	
	public any function init(
		required string client_id,
		required string client_secret,
		required string redirect_uri,
		required string access_token
	) {
		setClient_id(arguments.client_id);
		setClient_secret(arguments.client_secret);
		setRedirect_uri(arguments.redirect_uri);
		setAccess_token(arguments.access_token);
		return this;
	}
	
	
	/* OAuth Authentication */
	
	/**
	* @hint - Manages the authorisation process between client and provider. Will redirect user to authentication screen.
	*
	* @response_type
	* @scope
	*/
	public void function authorize(
		required string response_type,
		string scope = ""
	) {
		var strReqURL = getbaseUrl() & 'oauth/authorize/?client_id=' & getclient_id() & '&redirect_uri=' & encodeForURL(getRedirect_uri()) & '&response_type=' & arguments.response_type;
		if ( len(arguments.scope) ) {
			strReqURL = strReqURL & '&scope=' & encodeForURL(arguments.scope);
		}
		location(strReqURL);
	}
	
	/**
	* @hint - Grants the access token after a successful authorisation
	*
	* @grant_type
	* @code
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*/
	public any function access_token(
		required string grant_type ="authorization_code",
		required string code,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'oauth/access_token/';
		var stuParams = {
			client_id 		= getclient_id(),
			client_secret	= getclient_secret(),
			redirect_uri	= getRedirect_uri(),
			grant_type		= arguments.grant_type,
			code			= arguments.code
		};
		var result = makeRequest(strReqURL, 'POST', stuParams);
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	
	/* API Endpoints and Methods */
	
	/* GET /users/self */
	/**
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*/
	public any function getSelfInfo(
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/self/?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/:user-id */
	/**
	* @user_id The user id of the user you wish to access.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get the most recent media published by the owner of the access_token.
	*/
	public any function getUserById(
		required string user_id,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/' & arguments.user_id & '/?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/self/media/recent */
	/**
	* @count Count of media to return.
	* @min_id Return media later than this min_id.
	* @max_id Return media earlier than this min_id.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get the most recent media published by the owner of the access_token.
	*/
	public any function getSelfRecentMedia(
		numeric count,
		numeric min_id,
		numeric max_id,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/self/media/recent/?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/:user-id/media/recent */
	/**
	* @user_id The user id of the user you wish to access.
	* @count Count of media to return.
	* @min_id Return media later than this min_id.
	* @max_id Return media earlier than this min_id.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get the most recent media published by a user. This endpoint requires the public_content scope if the user-id is not the owner of the access_token.
	*/
	public any function getUserRecentMedia(
		required string user_id,
		numeric count,
		numeric min_id,
		numeric max_id,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/' & arguments.user_id & '/media/recent/?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/self/media/liked */
	/**
	* @count Count of media to return.
	* @max_like_id Return media liked before this id.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get the list of recent media liked by the owner of the access_token.
	*/
	public any function getSelfMediaLiked(
		numeric count,
		numeric max_like_id,
		boolean parse_results = false
	) {		
		var strReqURL = getbaseUrl() & 'v1/users/self/media/liked/?access_token=' & getAccess_token() & buildParams(arguments);
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/search */
	/**
	* @q A query string.
	* @count Number of users to return.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get a list of users matching the query.
	*/
	public any function userSearch(
		required string q,
		numeric count,
		boolean parse_results = false
	) {		
		var strReqURL = getbaseUrl() & 'v1/users/search?access_token=' & getAccess_token() & buildParams(arguments);
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	
	/* MEDIA API */
	
	/* GET /media/:media-id */
	/**
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get information about a media object. Use the type field to differentiate between image and video media in the response. You will also receive the user_has_liked field which tells you whether the owner of the access_token has liked this media. The public_content permission scope is required to get a media that does not belong to the owner of the access_token.
	*/
	public any function getMediaById(
		required string media_id,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/media/' & arguments.media_id & '/?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	
	/* GET /media/shortcode/:shortcode */
	/**
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint This endpoint returns the same response as GET /media/media-id. A media object's shortcode can be found in its shortlink URL. An example shortlink is http://instagram.com/p/tsxp1hhQTG/. Its corresponding shortcode is tsxp1hhQTG.
	*/
	public any function getMediaByShortcode(
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/media/shortcode/D?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	
	/* GET /media/search */
	/**
	* @lat Latitude of the center search coordinate. If used, lng is required.
	* @lng Longitude of the center search coordinate. If used, lat is required.
	* @distance Default is 1km (distance=1000), max distance is 5km.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Search for recent media in a given area.
	*/
	public any function mediaSearch(
		required string lat,
		required string lng,
		string distance,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/media/search?access_token=' & getAccess_token() & buildParams(arguments);
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	
	/* RELATIONSHIPS API */
	
	/* GET /users/self/follows */
	/**
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get the list of users this user follows.
	*/
	public any function getSelfFollows(
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/self/follows?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/self/followed-by */
	/**
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get the list of users this user is followed by.
	*/
	public any function getSelfFollowedBy(
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/self/followed-by?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/self/requested-by */
	/**
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint List the users who have requested this user's permission to follow.
	*/
	public any function getSelfRequestedBy(
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/self/requested-by?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* GET /users/:user-id/relationship */
	/**
	* @user_id The user id of the user you wish to access.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Get information about a relationship to another user. Relationships are expressed using the following terms in the response: outgoing_status: Your relationship to the user. Can be 'follows', 'requested', 'none'. incoming_status: A user's relationship to you. Can be 'followed_by', 'requested_by', 'blocked_by_you', 'none'.
	*/
	public any function getUserRelationship(
		required string user_id
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/' & arguments.user_id & '/relationship?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'GET');
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
	/* POST /users/:user-id/relationship */
	/**
	* @user_id The user id of the user you wish to access.
	* @parse_results If true the results are returned as a CFML structure. If false (default) it is returned as JSON.
	*
	* @hint Modify the relationship between the current user and the target user. You need to include an action parameter to specify the relationship action you want to perform. Valid actions are: 'follow', 'unfollow' 'approve' or 'ignore'. Relationships are expressed using the following terms in the response: outgoing_status: Your relationship to the user. Can be 'follows', 'requested', 'none'. incoming_status: A user's relationship to you. Can be 'followed_by', 'requested_by', 'blocked_by_you', 'none'.
	*/
	public any function updateUserRelationship(
		required string user_id,
		required string action,
		boolean parse_results = false
	) {
		var strReqURL = getbaseUrl() & 'v1/users/' & arguments.user_id & '/relationship?access_token=' & getAccess_token();
		var result = makeRequest(strReqURL, 'POST', {action = arguments.action});
		return parseResults(arguments.parse_results, result.fileContent);
	}
	
}