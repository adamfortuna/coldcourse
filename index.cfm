<!--- Add this line to your index.cfm file right before your main framework file is included. --->
<cfset application.coldcourse.dispatch(cgi.path_info, cgi.script_name) />