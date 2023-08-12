function viewer = showReportViewer( reportFile, opts )






















R36
reportFile char{ mustBeTextScalar( reportFile ) } = ''
opts.Show( 1, 1 )logical = true
opts.Debug( 1, 1 )logical = coderapp.internal.globalconfig( 'WebDebugMode' )
opts.RemoteControl( 1, 1 )logical
opts.Title char{ mustBeTextScalar( opts.Title ) } = ''
opts.Async( 1, 1 )logical = true
opts.OwningBlock{ mustBeA( opts.OwningBlock, [ "double", "char", "string" ] ) } = ''
opts.Passthrough cell = {  }
end 

if ~isempty( opts.OwningBlock )
blockSid = getBlockSid( opts.OwningBlock );
else 
blockSid = '';
end 

if ~isempty( opts.Passthrough )
args = reshape( opts.Passthrough, 1, [  ] );
else 
args = {  };
end 

if ~isempty( reportFile )
if ~codergui.internal.util.isAbsolute( reportFile )
if isunix(  ) && strncmp( reportFile, '~/', 2 )
reportFile = fullfile( strtrim( evalc( '!echo $HOME' ) ), reportFile( 3:end  ) );
else 
reportFile = fullfile( pwd, reportFile );
end 
elseif endsWith( reportFile, '.html' )
openOldReport( reportFile, opts.Title );
viewer = [  ];
return 
end 

if ~opts.Debug
viewer = getExistingViewer( reportFile, blockSid );
if ~isempty( viewer )
viewer.show(  );
return 
end 
end 

[ examinedReportFile, reportType ] = examineReportFile( reportFile );
args = [ args ...
, reshape( reportType.getReportViewerArgs(  ), 1, [  ] ),  ...
{ 'ReportFile', examinedReportFile, 'ReportType', reportType } ...
 ];
end 

args( end  + 1:end  + 4 ) = { 'Async', opts.Async, 'Debug', opts.Debug };
if ~isempty( reportFile )
args( end  + 1:end  + 2 ) = { 'WaitForReady', true };
end 
if ~isempty( blockSid )
args( end  + 1:end  + 2 ) = { 'BlockSid', blockSid };
end 
if isfield( opts, 'RemoteControl' )
args( end  + 1:end  + 2 ) = { 'RemoteControl', opts.RemoteControl };
end 

viewer = codergui.ReportServices.ViewerFactory.run( args{ : } );
if ~isempty( opts.Title )
viewer.CustomTitle = opts.Title;
end 
if opts.Show
viewer.show(  );
end 
end 


function viewer = getExistingViewer( reportFile, blockSid )
currentViewers = codergui.ReportViewer.getReportViewers( reportFile );
for i = 1:numel( currentViewers )
viewer = currentViewers{ 1 };
if isa( viewer.Client, 'codergui.internal.WebWindowWebClient' ) &&  ...
( isempty( blockSid ) || isequal( blockSid, viewer.BlockSid ) )
return ;
end 
end 
viewer = [  ];
end 


function [ reportArg, reportType ] = examineReportFile( reportFile )
reportArg.fileSystem = codergui.internal.fs.ReportFileSystem.fromReportFile( reportFile );
manifest = reportArg.fileSystem.loadMatFile( 'manifest.mat', 'manifest' );
manifest = manifest.manifest;
reportArg.manifest = manifest;
reportType = codergui.ReportServices.getReportType( manifest );
reportArg.file = reportFile;
end 


function openOldReport( reportFile, title )
if ~isempty( which( 'emlcprivate' ) )
emlcprivate( 'emcOpenReport', reportFile, title );
else 
open( reportFile );
end 
end 


function sid = getBlockSid( arg )
if isnumeric( arg )
arg = idToHandle( sfroot, arg );
end 
sid = Simulink.ID.getStateflowSID( arg );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpsc0beD.p.
% Please follow local copyright laws when handling this file.

