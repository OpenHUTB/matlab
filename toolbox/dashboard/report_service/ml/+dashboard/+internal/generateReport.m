function path = generateReport( absoluteRootFolder, location, reportType, artifactScope, debug, appID, layoutID, layoutClassName, launchReport )




R36
absoluteRootFolder( 1, 1 )string
location( 1, 1 )string
reportType( 1, 1 )string
artifactScope
debug( 1, 1 )logical = false
appID( 1, 1 )string = "DashboardApp"
layoutID( 1, 1 )string = ""
layoutClassName = 'metric.dashboard.Configuration'
launchReport( 1, 1 )logical = true
end 

project = currentProject;

location = dashboard.internal.utils.getReportName( location, reportType, layoutID );

layout = dashboard.internal.getDashboardLayout( absoluteRootFolder, appID, layoutID, layoutClassName );
reportClassConstructor = str2func( layout.ReportClass );
reportClass = reportClassConstructor( location, reportType, project, layout );
path = reportClass.generate( artifactScope, launchReport, debug );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpHd4RdW.p.
% Please follow local copyright laws when handling this file.

