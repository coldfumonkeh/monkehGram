component {
	
	public any function init() {
		return this;
	}


	/**
	* @hint This function makes the relevant HTTP request to the API endpoints and return the entire response.
	* 
	* @request_url The URL for the request 
	* @request_method The HTTP method (typically GET or POST)
	* @parameters A struct of key value pairs to send through as formfield parameters.
	*/
	private any function makeRequest(
		required string request_url,
		required string request_method,
		struct parameters = {}
	) {	
		var httpService = new http();
			httpService.setMethod(arguments.request_method);
			httpService.setUrl(arguments.request_url);
			if ( arguments.request_method == 'POST' ) {
				for ( key in arguments.parameters ) {
					httpService.addParam(type='formfield', name=lcase(key), value=arguments.parameters[key]);
				}
			}
		var result = httpService.send().getPrefix();
		return result;
	}
	
	/**
	* @parse If true the results will be returned as a CFML structure.
	* @jsonResults The data from the request.
	*/
	private function parseResults(
		required boolean parse,
		required string jsonResults
	) {
		return arguments.parse ? deserializeJSON(arguments.jsonResults) : arguments.jsonResults;
	}
	
	/**
	* @params A structure of arguments from the calling method.
	* @hint This method will create a string of extra URL parameter values to append to the request URL. Unwanted values will be stripped out.
	*/
	private string function buildParams(required struct params) {
		var strParams = '';
		var stuArgs = structCopy(arguments.params);
		structDelete(stuArgs, 'parse_results');
		for ( key in stuArgs ) {
			if ( len(stuArgs[key]) ) {
				strParams = strParams & '&' & lcase(key) & '=' & stuArgs[key];
			}
		}
		return strParams;
	}
}