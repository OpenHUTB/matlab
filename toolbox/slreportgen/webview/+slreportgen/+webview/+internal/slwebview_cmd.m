function [ out1, out2 ] = slwebview_cmd( wvDoc, options )






R36
wvDoc
options.ShowProgressBar slreportgen.webview.enum.OnOffSwitchState = false;
options.ViewFile slreportgen.webview.enum.OnOffSwitchState = false;
options.StringOutput logical = true;
end 


if ( isprop( 0, 'TerminalProtocol' ) && ~strcmpi( get( 0, 'TerminalProtocol' ), 'x' ) )

throw(  ...
MException( message( 'slreportgen_webview:exporter:NoExportWithoutDisplay' ) ) );
end 

sysName = wvDoc.HomeDiagram.Name;


if options.ShowProgressBar
progressBar = slreportgen.webview.ui.ProgressBar(  );
progressBar.ShowMessagePriority = progressBar.ImportantMessagePriority;
progressBar.setTitle(  ...
message( 'slreportgen_webview:webview:ExportWaitbarMsg', sysName ).getString(  ) );

if options.ViewFile
webviewWeight = 0.9;
dispWeight = 0.1;
else 
webviewWeight = 1;
dispWeight = 0;
end 
progressBar.addChild( wvDoc.ProgressMonitor, webviewWeight );
progressBar.addChild( slreportgen.webview.ProgressMonitor( 0, 1 ), dispWeight );

progressBar.setMessage(  ...
message( 'slreportgen_webview:exporter:ExportingSystem', sysName ),  ...
progressBar.ImportantMessagePriority );
progressBar.show(  );
pm = progressBar;
else 
pm = wvDoc.ProgressMonitor;
end 


wvDoc.open(  );
wvDoc.fill(  );
wvDoc.close(  );


if pm.isCanceled(  )


cancelCleanup( wvDoc );
out1 = string.empty(  );
out2 = string.empty(  );
else 

packageType = lower( wvDoc.PackageType );
if any( strcmp( packageType, [ "zipped", "both" ] ) )
movefile( wvDoc.OutputPath, zipPath( wvDoc ), "f" );
end 


if options.ViewFile
viewInSystemBrowser( wvDoc );
end 

switch packageType
case 'zipped'
out1 = zipPath( wvDoc );
out2 = string.empty(  );
case 'unzipped'
out1 = htmlPath( wvDoc );
out2 = string.empty(  );
otherwise 
out1 = zipPath( wvDoc );
out2 = htmlPath( wvDoc );
end 
pm.done(  );
end 

if ~options.StringOutput
out1 = char( out1 );
out2 = char( out2 );
end 
end 

function cancelCleanup( wvDoc )
if any( strcmpi( wvDoc.PackageType, [ "zipped", "both" ] ) ) && isfile( wvDoc.OutputPath )
delete( wvDoc.OutputPath );
end 

if any( strcmpi( wvDoc.PackageType, [ "unzipped", "both" ] ) )
[ fpath, fname ] = fileparts( wvDoc.OutputPath );
unzipFolder = fullfile( fpath, fname );
if isfolder( unzipFolder )
rmdir( unzipFolder, "s" );
end 
end 
end 

function out = htmlPath( wvDoc )
[ fpath, fname ] = fileparts( wvDoc.OutputPath );
out = fullfile( fpath, fname, "webview.html" );
end 

function out = zipPath( wvDoc )
[ fpath, fname ] = fileparts( wvDoc.OutputPath );
out = fullfile( fpath, fname + ".zip" );
end 

function viewInSystemBrowser( wvDoc )
if any( strcmpi( wvDoc.PackageType, [ "unzipped", "both" ] ) )
htmlFile = htmlPath( wvDoc );
else 
tempViewPath = fullfile( tempdir, "mlreportgen" );
if isfolder( tempViewPath )
rmdir( tempViewPath, "s" );
end 
mkdir( tempViewPath );

wvDoc.ProgressMonitor.setMessage(  ...
message( "slreportgen_webview:exporter:UnzippingFiles" ),  ...
wvDoc.ProgressMonitor.ImportantMessagePriority );

wvDocZipPath = zipPath( wvDoc );
[ ~, zipName ] = fileparts( wvDocZipPath );
unzip( wvDocZipPath, fullfile( tempViewPath, zipName ) );
htmlFile = fullfile( tempViewPath, zipName, "webview.html" );
end 

wvDoc.ProgressMonitor.setMessage(  ...
message( "slreportgen_webview:exporter:DisplayingWebview" ),  ...
wvDoc.ProgressMonitor.ImportantMessagePriority );
web( htmlFile, '-browser' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmDtfCc.p.
% Please follow local copyright laws when handling this file.

