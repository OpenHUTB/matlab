function reportLocation = createReportMCOS( leftSource, rightSource, mcosView, reportPath, formatString )




R36
leftSource( 1, 1 )comparisons.internal.FileSource
rightSource( 1, 1 )comparisons.internal.FileSource
mcosView( 1, 1 )
reportPath( 1, : )char
formatString( 1, : )char
end 

sources = { leftSource, rightSource };

[ reportFolder, reportName, ext ] = fileparts( reportPath );
if ( ~strcmpi( ext, [ '.', formatString ] ) )
reportName = [ reportName, ext ];
end 

format = comparisons.internal.report.tree.ReportFormat.( upper( formatString ) );

reportLocation = slcomparisons.internal.report.createReport(  ...
mcosView, sources, reportFolder, reportName, format );

import comparisons.internal.isMOTW
if ~isMOTW
rptview( reportLocation )
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCEm_yZ.p.
% Please follow local copyright laws when handling this file.

