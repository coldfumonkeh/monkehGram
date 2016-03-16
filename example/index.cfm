<cfscript>

// Instantiate the component
objmonkehGram = new com.coldfumonkeh.monkehGram.monkehGram(
						client_id		= 'Your client ID value',
						client_secret 	= 'Your client secret value',
						redirect_uri	= 'Your redirect URI',
						access_token	= 'Your access token'
					);
		

if ( structKeyExists(URL, 'code') ) {
	userData = objMonkehGram.access_token(
		code			= URL.code,
		parse_results	= true
	);
} else if ( structKeyExists(URL, 'auth') ) {
	writeDump(objMonkehGram.authorize(
		response_type	= "code",
		scope			= "basic public_content follower_list comments relationships likes" // basic public_content follower_list comments relationships likes
	));
}

// This is a just a test file. To run the initial authorisation, append the URL value ?auth to your query string

/*writeDump(objMonkehGram.getSelfRecentMedia(parse_results=true));*/
/*writeDump(objMonkehGram.getUserByID('1833075547'));*/
/*writeDump(objMonkehGram.getSelfMediaLiked(count=2,max_like_id=134));*/
/*writeDump(objMonkehGram.userSearch(q='monkeh.me'));*/
/*writeDump(objMonkehGram.mediaSearch(lat='48.858844', lng='2.294351'));*/
/*writeDump(objMonkehGram.getMediaById(media_id = '1195955321412555489_1833075547'));*/
/*writeDump(objMonkehGram.getSelfFollowedBy());*/

</cfscript>
