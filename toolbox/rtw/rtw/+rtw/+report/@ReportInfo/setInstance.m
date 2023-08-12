function setInstance( model, obj )
set_param( model, 'CoderReportInfo', obj );
ssHdl = rtwprivate( 'getSourceSubsystemHandle', model );
if ~isempty( ssHdl )
set_param( bdroot( ssHdl ), 'CoderReportInfo', obj );
ssHdl = rtwprivate( 'getSourceSubsystemHandle', bdroot( ssHdl ) );
if ~isempty( ssHdl )
set_param( bdroot( ssHdl ), 'CoderReportInfo', obj );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpW6AsZv.p.
% Please follow local copyright laws when handling this file.

