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

<!--- sample album URI --->
<cfset strURI = 'spotify:album:6G9fHYDCoyEErUkHrFYfs4' />

<!--- instantiate the object --->
<cfset objSpotify = createObject('component', 'com.coldfumonkeh.spotify').init(true) />

<cfset strArtist 	= 'Sonic Youth' />
<cfset strTitle 	= 'Sugar Kane' />

<!--- Get the artist URI first --->
<cfset artistXML = objSpotify.search(searchMethod='artist',query=strArtist) />
<cfset arrArtist = xmlsearch(artistXML,"//:artists/:artist") />

<cfset qArtists = queryNew('name,popularity,artistURI') />


<cfloop from="1" to="#arrayLen(arrArtist)#" index="i">
	<cfset queryAddRow(qArtists, 1) />
	<cfset querySetCell(qArtists,'name',		arrArtist[i].XmlChildren[1].XmlText) />
	<cfset querySetCell(qArtists,'popularity',	arrArtist[i].XmlChildren[2].XmlText) />
	<cfset querySetCell(qArtists,'artistURI',	arrArtist[i].XmlAttributes['href']) />
</cfloop>



<cfset artistURI = artistXML.artists.artist.XmlAttributes['href'] />

<!--- Search for the track --->
<cfset trackXML = objSpotify.search(searchMethod='track',query=strTitle) />
<cfset arrTracks = xmlsearch(trackXML,"//:tracks/:track") />

<cfset qTracks = queryNew('name,artist,artistURI,spotifyLength,length,trackURI,album,albumURI,albumReleaseDate') />

<cfloop from="1" to="#arrayLen(arrTracks)#" index="i">
	<cfif arrTracks[i].XmlName EQ 'track'>
	
		<cfset queryAddRow(qTracks, 1) />
		<cfset querySetCell(qTracks,'name',				arrTracks[i].XmlChildren[1].XmlText) />
		<cfset querySetCell(qTracks,'artist',			arrTracks[i].XmlChildren[2].XmlChildren[1].XmlText) />
		<cfset querySetCell(qTracks,'artistURI',		arrTracks[i].XmlChildren[2].XmlAttributes['href']) />
		<cfset querySetCell(qTracks,'spotifyLength',	arrTracks[i].XmlChildren[6].XmlText) />
		<cfset querySetCell(qTracks,'length',			arrTracks[i].XmlChildren[6].XmlText/60) />
		<cfset querySetCell(qTracks,'trackURI',			arrTracks[i].XmlAttributes['href']) />
		<cfset querySetCell(qTracks,'album',			xmlSearch(arrTracks[i], '//:album')[i].XmlChildren[1].XmlText) />
		<cfset querySetCell(qTracks,'albumURI',			xmlSearch(arrTracks[i], '//:album')[i].XmlAttributes['href']) />
		<cfset querySetCell(qTracks,'albumReleaseDate',	xmlSearch(arrTracks[i], '//:album')[i].XmlChildren[2].XmlText) />
	</cfif>
</cfloop>

<cfdump var="#qTracks#">
<cfabort>



<cfquery name="qDetail" dbtype="query">
SELECT * 
FROM qArtists, qTracks
WHERE 1 = 1
AND qArtists.ArtistURI = qTracks.ArtistURI
<!---WHERE artistURI = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artistURI#" />--->
</cfquery>

<cfdump var="#qDetail#">


