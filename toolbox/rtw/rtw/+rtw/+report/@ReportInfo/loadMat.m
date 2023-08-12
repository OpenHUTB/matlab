function obj = loadMat( sys, varargin )





















buildFolder = rtw.report.ReportInfo.detectBuildFolder( sys, varargin{ : } );
if iscell( buildFolder )
obj = rtw.report.ReportInfo.empty( length( buildFolder ), 0 );
for k = 1:length( buildFolder )
obj( k ) = rtw.report.ReportInfo.loadMat( '', buildFolder{ k } );
obj( k ).initStartDirBasedOnBuildDir(  );
end 
return 
end 
obj = rtw.report.ReportInfo.getReportInfoFromBuildDir( buildFolder );
obj.initStartDirBasedOnBuildDir(  );
if ~obj.isValidateReportInfo( sys )
DAStudio.error( 'RTW:report:ReportInfoNotMatch', buildFolder, sys );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqW986G.p.
% Please follow local copyright laws when handling this file.

