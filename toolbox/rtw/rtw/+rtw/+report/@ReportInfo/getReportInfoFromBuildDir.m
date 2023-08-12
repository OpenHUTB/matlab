function obj = getReportInfoFromBuildDir( buildFolder )




buildInfoFile = fullfile( buildFolder, 'buildInfo.mat' );
if ~exist( buildInfoFile, 'file' )
DAStudio.error( 'RTW:report:invalidBuildFolder', buildFolder );
end 
load( buildInfoFile, 'buildInfo' );


postLoadUpdate( buildInfo, buildFolder );

obj = detachReportInfo( buildInfo );
if ~isa( obj, 'rtw.report.ReportInfo' )
DAStudio.error( 'RTW:report:ReportInfoNotFound', buildFolder );
end 

obj.setTransientData( buildInfo );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzO1CW6.p.
% Please follow local copyright laws when handling this file.

