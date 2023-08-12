function openReportCallback( sys, varargin )






model = bdroot( sys );
load_system( model );

try 
reportInfo = rtw.report.getReportInfo( sys, varargin{ : } );
if isa( reportInfo, 'rtw.report.ReportInfo' )

if locCheckReportOptionsUpToDate( reportInfo )

reportInfo.link( model );
reportInfo.show(  );
else 

reportInfo.link( model );
end 
end 
catch ME
switch ME.identifier
case { 'RTW:report:BuildFolderNotExist'
'RTW:report:relativeBuildFolderNotFound' }
rtw.report.openReportInfoDlg( sys );
otherwise 
throwAsCaller( ME );
end 
end 

end 



function out = locCheckReportOptionsUpToDate( reportInfo )

notFound = ~exist( reportInfo.getReportFileFullName, 'file' );
optionsChanged = reportInfo.reportOptionsChanged;

if notFound || optionsChanged
regenOpt = DAStudio.message( 'RTW:report:btnRegenerate' );
openOpt = DAStudio.message( 'RTW:report:btnOpenReport' );
cancelOpt = DAStudio.message( 'RTW:report:btnCancel' );
if notFound
result = questdlg( DAStudio.message( 'RTW:report:txtGenerateOpen', regenOpt ),  ...
DAStudio.message( 'RTW:report:titleCreateReport' ),  ...
regenOpt, cancelOpt, cancelOpt );
else 
result = questdlg( DAStudio.message( 'RTW:report:txtRegenerateOpen', regenOpt, openOpt ),  ...
DAStudio.message( 'RTW:report:titleReportNotCurrent' ),  ...
regenOpt, openOpt, cancelOpt, cancelOpt );
end 
switch result
case regenOpt
rtw.report.ReportDlg.regenOptAction( reportInfo );
case openOpt
rtw.report.ReportDlg.openOptAction( reportInfo );
case cancelOpt

end 
out = false;
else 
out = true;
end 

end 

function locThrowOutdatedReportWarning(  )
warnState = warning( 'off', 'backtrace' );
c = onCleanup( @(  )warning( warnState.state, 'backtrace' ) );
MSLDiagnostic( 'RTW:report:txtWarningReport' ).reportAsWarning;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmptjsPit.p.
% Please follow local copyright laws when handling this file.

