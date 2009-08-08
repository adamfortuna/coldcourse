<cfcomponent name="Coldcourse" output="false">

	<!---
		The dispatch(), findcourse() and addCourse() methods
		are modified versions of those found in the Coldfusion on Wheels
		framework. 
	--->

	<cffunction name="init" access="public" output="false" returntype="any">
		<cfargument name="configPath" type="string" required="true" />
		
		<cfset variables._courses = ArrayNew(1) />

		<!--- The config file is native to running in this function --->
		<cfinclude template="#arguments.configPath#" />
		
		<cfreturn this />
	</cffunction>
	
	
	<cffunction name="dispatch" access="public" output="false" returntype="void"
				hint="Run at every page call, so should be fast!">
		<cfargument name="course" type="any" required="true"  />
		<cfargument name="script_name" type="any" required="true" />
		
		<!------ Find which route this URL matches -------->
		<cfset var acourse = "" />
		<cfset var key = "" />

		<cfif NOT enabled><cfreturn /></cfif>

		<cfset checkForInvalidURL(arguments.course, arguments.script_name) />

		<cfset acourse = findCourse(arguments.course) />
		<!--- Now course should have all the key/pairs from the URL we need to pass to our view --->
		<cfloop collection="#acourse#" item="key">
			<cfset url[key] = acourse[key] />
		</cfloop>
		
		<cfset routeToDestination(acourse) />
		
	</cffunction>
			
			
	<cffunction name="routeToDestination" access="private" output="false">
		<cfargument name="course" required="true" type="any" />
		
		<!--- If they're accessing a default action explicity, and unique URLs are on --->
		<cfif variables.uniqueURLs
				AND StructKeyExists(arguments.course,"controller") 
				AND StructKeyExists(arguments.course,"action")
				AND arguments.course.action EQ variables.frameworkActionDefault>
			<cfheader statuscode="301" statustext="Moved permanently" />
			<cfheader name="Location" value="#variables.baseURL#/#arguments.course.controller##serializeURL()#" />
			<cfabort />
			
		<!--- If controller is set --->		
		<cfelseif StructKeyExists(arguments.course,"controller")>
			<cfparam name="arguments.course.action" default="#variables.frameworkActionDefault#" />
			<cfset url[variables.frameworkEvent] = arguments.course.controller & variables.frameworkSeparator & arguments.course.action />
		</cfif>
      
		<!--- Remove what we set.. like a ninja --->
		<cfset StructDelete(url, "controller") />
		<cfset StructDelete(url, "action") />
	</cffunction>
	
			
	<cffunction name="checkForInvalidURL" access="private" output="false" returntype="void">	
		<cfargument name="course" required="true" type="any" />	
		<cfargument name="script_name" required="true" type="any" />
		<cfset var controller = "" />
		<cfset var action = "" />
		<cfset var newpath = "" />

		<cfset httpRequestData = GetHttpRequestData()/>
		<cfif variables.uniqueURLs 
			  AND StructKeyExists(URL, variables.frameworkEvent)
			  AND (arguments.course EQ "/index.cfm")>
			<cfif StructKeyExists(URL, variables.frameworkEvent)>
				<cfset controller = ListFirst(URL[variables.frameworkEvent], variables.frameworkSeparator) />
				<cfset action = ListLast(URL[variables.frameworkEvent], variables.frameworkSeparator) />
			</cfif>
			<cfif len(controller)>
				<cfset newpath = "/" & controller />
			</cfif>
			<cfif len(controller) AND len(action) AND action NEQ variables.frameworkActionDefault>
				<cfset newpath = newpath & "/" & action />
			</cfif>
			<cfif httpRequestData.method EQ "GET">
				<cfheader statuscode="301" statustext="Moved permanently" />
			<cfelse>
				<cfheader statuscode="303" statustext="See Other" />
			</cfif>
			
			<cfheader name="Location" value="#variables.baseURL##newpath##serializeURL(httpRequestData.content)#" />
			<cfabort />
		</cfif>
	</cffunction>
		
	<cffunction name="serializeURL" access="private" output="false" returntype="string">
		<cfargument name="formVars" required="true" default="" type="string">
		<cfset var vars = arguments.formVars>
		<cfset var key = "">
		<cfloop collection="#url#" item="key">
			<cfif NOT ListFindNoCase("course,controller,action,#variables.frameworkEvent#",key)>
				<cfset vars = ListAppend(vars, "#lcase(key)#=#url[key]#", "&")>
			</cfif>
		</cfloop>
		<cfif len(vars) EQ 0><cfreturn ""></cfif>
		<cfreturn "?" & vars>
	</cffunction>
	
	<cffunction name="findCourse" access="private" output="false" returntype="Struct" 
				hint="Figures out which course matches this request">
		<cfargument name="action" type="any">
		
		<cfset var varMatch = "" />
		<cfset var valMatch = ""/>
		<cfset var vari = "" />
		<cfset var vali = "" />
		<cfset var requestString = arguments.action />
		<cfset var routeParams = arrayNew(1) />
		<cfset var thisRoute = structNew() />
		<cfset var thisPattern = "" />
		<cfset var match = structNew() />
		<cfset var foundRoute = structNew() />
		<cfset var returnRoute = structNew() />
		<cfset var params = structNew() />
		<cfset var key = "" />
		<cfset var i = "" />
		
		<!--- fix URL variables (IIS only) --->
		<cfif requestString CONTAINS "?">
			<cfset varMatch = REFind("\?.*=", requestString, 1, "TRUE") />
			<cfset valMatch = REFind("=.*$", requestString, 1, "TRUE") />
			<cfset vari = Mid(requestString, (varMatch.pos[1]+1), (varMatch.len[1]-2)) />
			<cfset vali = Mid(requestString, (valMatch.pos[1]+1), (valMatch.len[1]-1)) />
			<cfset url[vari] = vali />
			<cfset requestString = Mid(requestString, 1, (var_match.pos[1]-1)) />
		</cfif>
		
		<!--- Remove the leading slash in the request (if there was something more than just a slash to begin with) to match our routes --->
		<cfif len(requestString) GT 1>
			<cfset requestString = right(requestString,len(requestString)-1) />
		</cfif>
		<cfif right(requestString,1) IS NOT "/">
			<cfset requestString = requestString & "/" />
		</cfif>
		
		<!--- Compare route to URL --->
		<!--- For each route in /config/routes.cfm --->
		<cfloop from="1" to="#arrayLen(variables._courses)#" index="i">
			<cfset arrayClear(routeParams) />
			<cfset thisRoute = variables._courses[i] />
			
			<!--- Replace any :parts with a regular expression for matching against the URL --->
			<cfset thisPattern = REReplace(thisRoute.pattern, ":.*?/", "(.+?)/", "all") />
			
			<!--- Try to match this route against the URL --->
			<cfset match = REFindNoCase(thisPattern,requestString,1,true) />
			
			<!--- If a match was made, use the result to route the request --->
			<cfif match.len[1] IS NOT 0>
				<cfset foundRoute = thisRoute />
				
				<!--- For each part of the URL in the route --->
				<cfloop list="#thisRoute.pattern#" delimiters="/" index="thisPattern">
					<!--- if this part of the route pattern is a variable --->
					<cfif find(":",thisPattern)>
						<cfset arrayAppend(routeParams,right(thisPattern,len(thisPattern)-1)) />
					</cfif>
				</cfloop>
				
				<!--- And leave the loop 'cause we found our route --->
				<cfbreak />
			</cfif>
			
		</cfloop>
		
		<!--- Populate the params structure with the proper parts of the URL --->
		<cfloop from="1" to="#arrayLen(routeParams)#" index="i">
			<cfset "params.#routeParams[i]#" = mid(requestString,match.pos[i+1],match.len[i+1]) />
		</cfloop>
		<!--- Now set the rest of the variables in the route --->
		<cfloop collection="#foundRoute#" item="key">
			<cfif key IS NOT "pattern">
				<cfset params[key] = foundRoute[key] />
			</cfif>
		</cfloop>
		
		<cfreturn params />
	</cffunction>
	
	
	
	
	
	
	
	<!--- Functions after here are only called during initialization --->
	<cffunction name="setFrameworkEvent" access="public" output="false" returntype="void"
				hint="The url event used by this framework.">
		<cfargument name="frameworkEvent" type="string" required="true" />
		<cfset variables.frameworkEvent = arguments.frameworkEvent />
	</cffunction>
	
	<cffunction name="setFrameworkSeparator" access="public" output="false" returntype="void"
				hint="The url separator used by this framework.">
		<cfargument name="frameworkSeparator" type="string" required="true" />
		<cfset variables.frameworkSeparator = arguments.frameworkSeparator />
	</cffunction>
	
	<cffunction name="setFrameworkActionDefault" access="public" output="false" returntype="void"
				hint="The url separator used by this framework.">
		<cfargument name="frameworkActionDefault" type="string" required="true" />
		<cfset variables.frameworkActionDefault = arguments.frameworkActionDefault />
	</cffunction>

	<cffunction name="setUniqueURLs" access="public" output="false" returntype="void"
				hint="The default file called by this framework.">
		<cfargument name="uniqueURLs" type="boolean" required="true" />
		<cfset variables.uniqueURLs = arguments.uniqueURLs />
	</cffunction>
	
	<cffunction name="setBaseURL" access="public" output="false" returntype="void"
				hint="The default file called by this framework.">
		<cfargument name="baseURL" type="string" required="true" />
		<cfset variables.baseURL = arguments.baseURL />
	</cffunction>
	
	<cffunction name="setEnabled" access="public" output="false" returntype="void"
				hint="The default file called by this framework.">
		<cfargument name="enabled" type="boolean" required="true" />
		<cfset variables.enabled = arguments.enabled />
	</cffunction>
	
	<cffunction name="addCourse" access="private" hint="Adds a route to dispatch">
		<cfargument name="pattern" type="string" required="true" hint="The pattern to match against the URL." />
		
		<cfset var thisCourse= structNew() />
		<cfset var arg = "" />		
			
		<cfloop collection="#arguments#" item="arg">
			<cfset thisCourse[arg] = arguments[arg] />
		</cfloop>
		
		<!--- Add a trailing slash to ease pattern matching --->
		<cfif right(thisCourse.pattern,1) IS NOT "/">
			<cfset thisCourse.pattern = thisCourse.pattern & "/" />
		</cfif>
		
		<cfset arrayAppend(variables._courses,thisCourse) />
	
	</cffunction>
	
	

</cfcomponent>