<cfcomponent>
	<cffunction name="onApplicationStart" returnType="boolean" output="false"> 
	   <!--- If in production mode, of if you never really change the courses, you can throw this here --->
	   <cfset application.coldcourse = createObject("component","model.Coldcourse").init("/config/coldcourse.config.cfm")>
		<cfreturn true> 
	</cffunction> 
	
	<cffunction name="onApplicationEnd" returnType="void"  output="false"> 
		<cfargument name="applicationScope" required="true">
		<!--- Place Here any application end code --->
	</cffunction>
	
	<cffunction name="onRequestStart">
	   <!--- If you're in development more and want to reload your configuration changes right away, leave this here --->
	   <cfset application.coldcourse = createObject("component","model.Coldcourse").init("/config/coldcourse.config.cfm")>
	</cffunction>
	
	<cffunction name="onSessionStart" returnType="void" output="false"> 
		<!--- Place Here any session start code --->
	</cffunction> 
	
	<cffunction name="onSessionEnd" returnType="void" output="false"> 
		<cfargument name="sessionScope" type="struct" required="true"> 
		<cfargument name="appScope" type="struct" required="false"> 
		<!--- Place Here any session end code --->
	</cffunction> 

</cfcomponent>