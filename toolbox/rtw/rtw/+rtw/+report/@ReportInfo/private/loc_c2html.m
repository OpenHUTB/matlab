

function loc_c2html( rptInfo, genTraceHyperlink, encoding )





perf_id = 'Report tokenizer';
PerfTools.Tracer.logSimulinkData( 'SLbuild', rptInfo.ModelName, rptInfo.PerfTracerTargetName,  ...
perf_id, true );
oc_perf = onCleanup( @(  )PerfTools.Tracer.logSimulinkData( 'SLbuild', rptInfo.ModelName, rptInfo.PerfTracerTargetName,  ...
perf_id, false ) );
files = rptInfo.getSortedFileInfoList;
srcFiles = files.FileName;
htmlFiles = files.HtmlFileName;


coder.internal.tokenizeForReport( srcFiles, htmlFiles, encoding, genTraceHyperlink );

if strcmp( rptInfo.Config.InCodeTrace, 'on' ) && strcmp( rptInfo.Config.IncludeHyperlinkInReport, 'on' )
perf_id = 'Report saveInlineTrace';
PerfTools.Tracer.logSimulinkData( 'SLbuild', rptInfo.ModelName, rptInfo.PerfTracerTargetName,  ...
perf_id, true );
loc_saveInCodeTrace( rptInfo );
PerfTools.Tracer.logSimulinkData( 'SLbuild', rptInfo.ModelName, rptInfo.PerfTracerTargetName,  ...
perf_id, false );
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp1HiwW9.p.
% Please follow local copyright laws when handling this file.

