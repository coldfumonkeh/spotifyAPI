<!---
Name: account.cfc
Author: Matt Gifford AKA coldfumonkeh (http://www.mattgifford.co.uk)
Date: 19.02.2010

Copyright  2010 Matt Gifford AKA coldfumonkeh. All rights reserved.
Product and company names mentioned herein may be
trademarks or trade names of their respective owners.

Subject to the conditions below, you may, without charge:

Use, copy, modify and/or merge copies of this software and
associated documentation files (the 'Software')

Any person dealing with the Software shall not misrepresent the source of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--->
<cfcomponent displayname="spotify" output="false">

	<cfset variables.instance = structNew() />
	
	<cffunction name="init" access="public" output="false" returntype="com.coldfumonkeh.spotify" hint="I am the constructor method">
		<cfargument name="structOutput" required="false" type="boolean" default="false" hint="If set to true, I will return xmlparse data." />
		<cfscript>
			setBaseURI('http://ws.spotify.com/');
			setVersion('1');
			setOutput(arguments.structOutput);   	        
        </cfscript>
		<cfreturn this />
	</cffunction>
	
	<!--- MUTATORS AND ACCESSORS --->
	<cffunction name="setBaseURI" access="private" output="false" returntype="void" hint="I set the baseURI value in the variables.instance struct.">
		<cfargument name="baseURI" required="true" type="string" />
		<cfset variables.instance.baseURI = arguments.baseURI />
	</cffunction>
	
	<cffunction name="getBaseURI" access="public" output="false" returntype="string" hint="I return the baseURI value.">
		<cfreturn variables.instance.baseURI />
	</cffunction>
	
	<cffunction name="setVersion" access="private" output="false" returntype="void" hint="I set the version value in the variables.instance struct.">
		<cfargument name="version" required="true" type="string" />
		<cfset variables.instance.version = arguments.version />
	</cffunction>
	
	<cffunction name="getVersion" access="public" output="false" returntype="string" hint="I return the version value.">
		<cfreturn variables.instance.version />
	</cffunction>
	
	<cffunction name="setOutput" access="private" output="false" returntype="void" hint="I set the structOutput value in the variables.instance struct.">
		<cfargument name="structOutput" required="true" type="boolean" />
		<cfset variables.instance.structOutput = arguments.structOutput />
	</cffunction>
	
	<cffunction name="getOutput" access="public" output="false" returntype="boolean" hint="I return the structOutput value.">
		<cfreturn variables.instance.structOutput />
	</cffunction>
	
	<!--- PUBLIC METHODS --->
	
	<!--- SEARCH RELATED METHODS --->
	<cffunction name="search" access="public" output="false" returntype="any" hint="I perform the search method on the API.">
		<cfargument name="searchMethod" required="true" 	type="string" 				hint="Available search methods. Album, Artist or Track." />
		<cfargument name="query"		required="true" 	type="string" 				hint="The string to search for. The function will URLEncode the supplied string." />
		<cfargument name="page"			required="false" 	type="string" default="1" 	hint="the page of the result set to return; defaults to 1" />
			<cfset var strURL = '' />
				<cfset acceptedSearch = 'album,artist,track' />
				<cfset isAcceptable = listContains(acceptedSearch,arguments.searchMethod, ',') />
				
				<cfif isAcceptable EQ 0>
					<cfdump var="The searchMethod you supplied was incorrect. It must be either #acceptedSearch#" />
					<cfabort>
				</cfif>
				<cfset strURL = strURL & getBaseURI() & 'search/' & getVersion() &
								 '/' & arguments.searchMethod & '?q=' 
								 	& urlEncodedFormat(arguments.query) & '&page=' & arguments.page />
				<cfset response = makeCall(strURL) />
		<cfreturn checkStatusCode(response) />
	</cffunction>
	
	<cffunction name="lookup" access="public" output="false" returntype="any" hint="I perform the lookup method on the API.">
		<cfargument name="URI" 			required="true" 	type="string" 				hint="The Spotify URI" />
		<cfargument name="detailLevel"	required="false" 	type="string" default="Off" hint="Off, Low, High. Will determine the level of data returned. Only applies to Album or Artist searches." />
			<cfset var strURL 		= '' />
			<cfset var strExtras 	= '' />
			<cfset var findOne 		= '' />
			<cfset var findTwo 		= '' />
			<cfset var lookThis 	= '' />
			<cfset var detail		= '' />
				<cfset findOne = findNoCase(':',arguments.URI) />
				<cfset findTwo = findNoCase(':', arguments.URI, findOne+1) />
				<cfset lookThis = mid(arguments.URI, findOne+1, findTwo-(findOne+1)) />
				<cfif lookThis NEQ 'track'>
					<cfif lookThis EQ 'album'>
						<cfset detail = 'track' />
					<cfelseif lookThis EQ 'artist'>
						<cfset detail = 'album' />
					</cfif>
					<cfswitch expression="#arguments.detailLevel#">
						<cfcase value="Off"><cfset strExtras = '' /></cfcase>
						<cfcase value="Low"><cfset strExtras = detail /></cfcase>
						<cfcase value="High"><cfset strExtras = detail & 'detail' /></cfcase>
					</cfswitch>
				</cfif>
				<cfset strURL = strURL & getBaseURI() & 'lookup/' & getVersion() &
								 '/?uri=' & arguments.URI & '&extras=' & strExtras />
				<cfset response = makeCall(strURL) />
		<cfreturn checkStatusCode(response) />
	</cffunction>
	
	<!--- UTIL FUNCTIONS --->
	
	<cffunction name="makeCall" access="private" output="false" returntype="Any" hint="I make the remote call to the API service.">
		<cfargument name="callURL" required="true" type="string" hint="I am the URL for remote API call" />
			<cfset var cfhttp = '' />
				<cfhttp url="#arguments.callURL#" method="get" />
		<cfreturn cfhttp />
	</cffunction>
		
	<cffunction name="checkStatusCode" access="private" output="false" hint="I check the status code from all API calls">
		<cfargument name="data" required="true" type="struct" hint="The data returned from the API." />
			<cfset var strSuccess = false />
			<cfset var strMessage = '' />
			<cfswitch expression="#arguments.data.Statuscode#">
				<cfcase value="200 OK">
					<cfset strSuccess = true />
					<cfset strMessage = 'Success!' />
				</cfcase>
				<cfcase value="304 Not Modified">
					<cfset strSuccess = false />
					<cfset strMessage = 'There was no new data to return.' />
				</cfcase>
				<cfcase value="400 Bad Request">
					<cfset strSuccess = false />
					<cfset strMessage = 'The request was invalid.' />
				</cfcase>
				<cfcase value="403 Forbidden">
					<cfset strSuccess = false />
					<cfset strMessage = 'The request is understood, but it has been refused, perhaps due to rate limiting.' />
				</cfcase>
				<cfcase value="404 Not Found">
					<cfset strSuccess = false />
					<cfset strMessage = 'The URI requested is invalid or the resource requested, such as a user, does not exist.' />
				</cfcase>
				<cfcase value="406 Not Acceptable">
					<cfset strSuccess = false />
					<cfset strMessage = 'Returned by the Search API when an invalid format is specified in the request.' />
				</cfcase>
				<cfcase value="500 Internal Server Error">
					<cfset strSuccess = false />
					<cfset strMessage = 'Something is broken.' />
				</cfcase>
				<cfcase value="503 Service Unavailable">
					<cfset strSuccess = false />
					<cfset strMessage = 'The API is temporarily unavailable. Try again later.' />
				</cfcase>
			</cfswitch>
			<cfif !strSuccess>
				<cfthrow message="#arguments.data.Statuscode# - #strMessage#" />
				<cfabort />
			<cfelse>
				<cfif getOutput()>
					<cfreturn xmlParse(arguments.data.fileContent) />
				<cfelse>
					<cfreturn arguments.data.fileContent />
				</cfif>
			</cfif>
	</cffunction>

</cfcomponent>