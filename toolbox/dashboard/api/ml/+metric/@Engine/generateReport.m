function loc = generateReport( obj, NameValueArgs )





R36
obj metric.Engine
NameValueArgs.Location{ mustBeTextScalar } = ""
NameValueArgs.Type{ mustBeTextScalar, mustBeMember( NameValueArgs.Type, [ "pdf", "html-file" ] ) } = "pdf"
NameValueArgs.LaunchReport( 1, 1 )logical = true
NameValueArgs.ArtifactScope{ mustBeText } = ""
NameValueArgs.Debug( 1, 1 )logical = false
NameValueArgs.App{ mustBeTextScalar, mustBeMember( NameValueArgs.App, [ "DashboardApp", "DesignCostEstimation" ] ) } = "DashboardApp"
NameValueArgs.Dashboard{ mustBeTextScalar } = dashboard.internal.LayoutConstants.ModelUnitTestingDashboard
NameValueArgs.layoutClassName = "metric.dashboard.Configuration"
end 

appID = convertCharsToStrings( NameValueArgs.App );
location = convertCharsToStrings( NameValueArgs.Location );
reportType = convertCharsToStrings( NameValueArgs.Type );
layoutID = convertCharsToStrings( NameValueArgs.Dashboard );


if ~strcmp( appID, "DashboardApp" ) &&  ...
strcmp( layoutID, dashboard.internal.LayoutConstants.ModelUnitTestingDashboard )


layoutID = "";
end 

[ filepath, name, ext ] = fileparts( location );

if name == ""
name = "untitled";
end 

if filepath == ""
filepath = pwd;
end 

artifactScope = convertCharsToStrings( NameValueArgs.ArtifactScope );
if artifactScope == ""
artifactScope = {  };
end 

launchReport = NameValueArgs.LaunchReport;
if ( appID == "DesignCostEstimation" )

if ( ~dig.isProductInstalled( "Fixed-Point Designer" ) )
error( message( 'dashboard:api:toolboxNotInstalled' ) );
end 
loc = metric.internal.generateReportForDCE( name, filepath, reportType, obj.ProjectPath, artifactScope, launchReport );
return ;
end 

debug = NameValueArgs.Debug;
layoutClassName = convertCharsToStrings( NameValueArgs.layoutClassName );


rps = dashboard.internal.ReportService( obj.ProjectPath );
loc = rps.generateReport(  ...
fullfile( filepath, strcat( name, ext ) ),  ...
reportType,  ...
artifactScope,  ...
debug,  ...
appID,  ...
layoutID,  ...
layoutClassName,  ...
launchReport ...
 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpT6CTrg.p.
% Please follow local copyright laws when handling this file.

