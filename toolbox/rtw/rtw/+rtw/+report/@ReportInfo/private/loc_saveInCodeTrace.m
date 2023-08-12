

function loc_saveInCodeTrace( rptInfo )



t = coder.trace.getTraceInfoByReportInfo( rptInfo );

if isempty( t )
return ;
end 
jsFileName = fullfile( rptInfo.getReportDir, 'traceInfo_flag.js' );
coder.trace.internal.writeTraceJsFile( t, jsFileName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp_xICAX.p.
% Please follow local copyright laws when handling this file.

