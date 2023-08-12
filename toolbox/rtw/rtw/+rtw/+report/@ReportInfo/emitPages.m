function emitPages( obj )




model = obj.ModelName;
suffix = obj.getModelNameSuffix;
baseName = [ model, suffix ];
reportFolder = obj.getReportDir;
if rtw.report.ReportInfo.featureReportV2
reportFolder = fullfile( reportFolder, 'pages' );
if ~isfolder( reportFolder )
mkdir( reportFolder );
end 
end 

bHyperlink = strcmp( obj.Config.IncludeHyperlinkInReport, 'on' );
bWebview = obj.hasWebview(  );

headJs = '';
libJs = '';
hiliteCallback = '';
if bWebview
libJs = { 'rtwreport_utils.js' };
end 


onLoadCallback = 'try {if (top) {if (top.rtwPageOnLoad) top.rtwPageOnLoad(''%s''); else local_onload();}} catch(err) {};';

htmlLinkManager = Simulink.report.HTMLLinkManager;
htmlLinkManager.SystemMap = obj.SystemMap;
htmlLinkManager.hasWebview = bWebview;
htmlLinkManager.IncludeHyperlinkInReport = bHyperlink;
htmlLinkManager.ModelName = obj.ModelName;
htmlLinkManager.BuildDir = obj.getBuildDir(  );

if ~isempty( obj.SourceSubsystem )
htmlLinkManager.SourceSubsystem = obj.SourceSubsystem;
end 
htmlLinkManager.JavaScriptHilite = hiliteCallback;



sidx = 1;
assert( isa( obj.Pages{ 1 }, 'rtw.report.Summary' ), 'The summary page is required to be the first reportPage' )
for k = 1:length( obj.Pages )
p = obj.Pages{ k };
p.setLinkManager( htmlLinkManager );
p.setJavaScript( libJs, headJs, sprintf( onLoadCallback, p.getId ) );
p.ReportFolder = reportFolder;
p.IsEnMessage = false;
p.RelativePathToSharedUtilRptFromRpt = obj.RelativePathToSharedUtilRptFromRpt;
if isempty( p.ReportFileName )
p.ReportFileName = [ baseName, '_', p.getDefaultReportFileName ];
end 

end 

for k = length( obj.Pages ): - 1:1
p = obj.Pages{ k };
if p.isEnable( obj.Config )
if obj.UpdateReport && ~isa( p, 'rtw.report.Traceability' )


if isa( p, 'rtw.report.CodeMetrics' )
p.generate( obj );
else 
p.update( obj.Config, obj.LastConfig );
end 
elseif isa( p, 'rtw.report.Traceability' ) || isa( p, 'rtw.report.CodeMetrics' )
p.generate( obj );
elseif ~isempty( obj.SourceSubsystem ) && isa( p, 'rtw.report.CoderAssumptions' )

p.ModelName = bdroot( obj.SourceSubsystem );
p.generate;
else 
p.generate;
end 
else 
p.generateDisableReport;
end 

if ( ~isa( p, 'rtw.report.Summary' ) )

AdditionalInformation = obj.Pages{ k }.getAdditionalInformation(  );
if ( ~isempty( AdditionalInformation ) )
obj.Pages{ sidx }.addAdditionalInformation( AdditionalInformation );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp6TTaLq.p.
% Please follow local copyright laws when handling this file.

