<!--- -------------------------------------------
	Configure your setup here...
	You'll have to configure if you're in development or production mode
	in your Application.cfc file.  This file is executed directly in Coldcourse.cfc
	for fastest results.  You'll set the path to this file in Application.cfc. You 
   should never need to change Coldcourse.cfc, but if you do see something that needs 
   changing feel free to submit a bug/ticket to	http://coldcourse.riaforge.com.
	
	All credits to Rob Cameron & Per Djurner of Coldfusion On Wheels 
	(http://www.cfwheels.com/) for innovating this routing method in Coldfusion.
	
	- Adam Fortuna
-------------------------------------------- --->

<!---
	Do you want ColdCourse to be on or off? If it's off it'll just short circuit
	any page requests that come in, in effect it'll do nothing. Only framework 
	specific actions will work if this is set to off.
--->
<cfset setEnabled(true)>

<!--- 
	The framework event is the main variable passed into index.cfm on each page call.
	For Model-Glue, Mach-II, Coldbox this will be "event" by default. For Fusebox
	this would be "fuseaction" unless changed.
	Examples: 
		<cfset setFrameworkEvent("event")>
		<cfset setFrameworkEvent("fuseaction")>
--->
<cfset setFrameworkEvent("event")>

<!--- 
	The separater between parts of your event. In all frameworks this is the same at the 
	moment actually, but since Model-Glue and MachII allow for any names for events 
	you'll need some sort of convention, like having all two part events with a "." 
	separating them.
--->
<cfset setFrameworkSeparator(".")>

<!--- 
	If a controller is set, but no action, it'll use this value for the action.
	For example, the URL http://localhost/home will be the same as 
	http://localhost/home/index. This can also be kept as just an empty string 
	if you have want your framework	to accept things like "fuseaction=home.".
 --->
<cfset setFrameworkActionDefault("index")>

<!--- 
	This determines if non-coldcourse urls should be routed back to coldcourse.
	In other words, if someone goes to http://localhost/index.cfm?fuseaction=home.main
	should we redirect (301, permanantly moved) to the coldcourse url: 
	http://localhost/home/main ?

	This will also make sure that any trailing index pages get redirected as well, so 
	if you go to http://localhost/home/index it would redirect to http://localhost/home 
	if index is your framework action default.

	For SEO purposes it's always best to have one URL for everything, not 3!
--->
<cfset setUniqueURLs(true)>

<!--- 
	The Base URL for your site. This will only be used for forwarding requests if 
	UniqueURLs is enabled.
   
   If you want your URLs to look like http://localhost/controller/action then you should
   put "http://localhost" here. For this option you'll need .htaccess or isapi rewrite support.
   
   If you want your URLs to look more like http://localhost/index.cfm/controller/action, then
   put "http://localhost/index.cfm" here. No additional setup is required to use this setting.
--->
<cfset setBaseURL("http://urldemo")>


<!--- -------------------------------------------
	Add your Courses here...
	The syntax of these is the same as that of Coldfusion on Wheels, and similar to Ruby 
	on Rails.  The idea is that the number of variables in a URL will be the first indicator
	of which course to use.
	
	Here's the general setup:
	<cfset addCourse(	pattern="controller/action/:id",	# Set the pattern
						controller="controller_name",		# Set the controller
						action="action_name" )>				# Set the action
						
	Notice how the "pattern" argument has three parts. In this case if a request comes in that starts with
	"/controller/action", such as "http://localhost/controller/action/oneOtherItem", this course will match.
	The "oneOtherItem" variable will be set to a URL variable with the name ID 
	<cfset url["ID"] = "oneOtherItem"> before then routing to the "controller_name" controller and the 
	"action_name" action. If you were using fusebox, this would be the same as the URL
	http://localhost/index.cfm?fuseaction=controller_name.action_name&id=oneOtherItem
	
	It's important to remember that courses are evaulauted in order and go with the first one that matches.
	For instance if you have a course for /:controller/:action/:username, and another course later for 
	/:controller/:action/:id, then the second course will NEVER be run. If instead you change your first 
	course to something more generic such as /user/:action/:username, and specify (controller="user") as
	a second paramter, then only URLs that start with /user will qualify for having the thrid argument of
	username, while everywhere else will use a third argument of ID.
	
	THe Coldfusion on Wheels help files say it best:
	By the way, what's with the : syntax?  In the Ruby programming language, any variable 
	starting with a : is a symbol. Symbols are just like strings but they always point to 
	the same place in memory and are therefore more efficient.  They don't work that way 
	here in ColdFusion, but they make a good variable marker without worrying about where 
	to put quotes and stuff
	
	Examples:
	<cfset addCourse(	pattern="blog/entry/:year/:month/:day",
						controller="blog",
						action="entry" )>
	<cfset addCourse(	pattern="profile/view/:username",
						controller="profile",
						action="view" )>	
	<cfset addCourse(":controller/:action/:id")>
	<cfset addCourse(":controller/:action")>
	<cfset addCourse(":controller")>			
-------------------------------------------- --->
					
<!--- CUSTOM COURSES GO HERE (they will be checked in order) --->


<!--- If nothing else matches, fall back to the standard courses (you probably shouldn't edit these) --->
<cfset addCourse(":controller/:action/:id")>
<cfset addCourse(":controller/:action")>
<cfset addCourse(":controller")>

