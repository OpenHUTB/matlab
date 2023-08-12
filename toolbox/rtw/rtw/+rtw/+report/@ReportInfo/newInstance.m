function obj = newInstance( model )
rtw.report.ReportInfo.clearInstance( model )
obj = rtw.report.ReportInfo( model );
set_param( model, 'CoderReportInfo', obj );
ssH = rtwprivate( 'getSourceSubsystemHandle', model );
if ~isempty( ssH )
set_param( bdroot( ssH ), 'CoderReportInfo', obj );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTtfCVE.p.
% Please follow local copyright laws when handling this file.

