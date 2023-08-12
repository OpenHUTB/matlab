classdef ( Sealed )Screener < handle




properties 
Client;
end 

properties ( Access = private, Constant )
PAGE_PATH = 'toolbox/coder/coderapp/screener/web';
WINDOW_TITLE = message( 'coderApp:screener:uiTitle' ).getString(  );
WINDOW_WIDTH = 1100;
WINDOW_HEIGHT = 800;


CHANNEL_EDIT_FILE = 'editFile';
CHANNEL_RESET_MODEL = 'resetModel';
CHANNEL_OPEN_HELP = 'openHelp';
CHANNEL_EXPORT_ANALYSIS = 'exportAnalysis';
CHANNEL_ERROR = 'error';
CHANNEL_MF0_SERVER = 'mf0/server';
CHANNEL_MF0_CLIENT = 'mf0/client';

EXPORT_PLAINTEXT = 'text';
EXPORT_WORKSPACE = 'workspace';
end 

properties ( Access = private )
Analysis;
DataModel;
Model;
MF0Channel;
MF0Sync;
end 

methods 
function obj = Screener( screenerResult )
R36
screenerResult coderapp.internal.screener.ScreenerResultView
end 
coder.internal.ddux.logger.logCoderEventData( "screenerOpen" );
obj.Client = codergui.ReportServices.WebClientFactory.run( obj.PAGE_PATH );
obj.Client.addlistener( 'Disposed', 'PostSet', @( ~, ~ )obj.delete(  ) );
obj.prepareDataModel( screenerResult );
obj.initModelSynchronizer(  );
obj.Client.WindowTitle = obj.WINDOW_TITLE;
obj.Client.WindowSize = [ obj.WINDOW_WIDTH, obj.WINDOW_HEIGHT ];
obj.subscribeAll(  );
obj.Client.show(  );
end 

function delete( obj )
if ~isempty( obj.MF0Sync )
obj.MF0Sync.stop(  );
end 

obj.Client.delete(  );
end 
end 

methods ( Access = { ?coder.ScreenerInfo } )



function show( obj )
obj.Client.show(  );
end 






function uuid = getScreenerResultUUID( obj )
uuid = obj.DataModel.Result.UUID;
end 
end 

methods ( Access = private )
function prepareDataModel( obj, screenerResult )


obj.Model = mf.zero.getModel( screenerResult );

txn = obj.Model.beginTransaction(  );
obj.DataModel = coderapp.internal.screener.ScreenerUiModel( obj.Model );
obj.DataModel.Result = screenerResult;
obj.DataModel.rerunAnalysis.registerHandler( @( src, evt )obj.handleRerunAnalysis( evt ) );

if isempty( screenerResult.Result.Input )
ipt = coderapp.internal.screener.ScreenerInput( obj.Model );
else 
ipt = screenerResult.Result.Input;
end 

obj.DataModel.Input = ipt;
txn.commit(  );
end 

function result = getScreenerResult( obj )
result = obj.DataModel.Result;
end 

function handleRerunAnalysis( obj, input )



txn = obj.Model.beginTransaction(  );

obj.DataModel.Result = coderapp.internal.screener.analyze( input );
txn.commit(  );
end 

function initModelSynchronizer( obj )
obj.MF0Channel = mf.zero.io.ConnectorChannel(  ...
obj.Client.channel( obj.CHANNEL_MF0_SERVER ),  ...
obj.Client.channel( obj.CHANNEL_MF0_CLIENT ) );
obj.MF0Sync = mf.zero.io.ModelSynchronizer( obj.Model, obj.MF0Channel );
obj.MF0Sync.start(  );
end 

function subscribeAll( obj )
obj.Client.subscribe( obj.CHANNEL_EDIT_FILE, @obj.handleEditFile );
obj.Client.subscribe( obj.CHANNEL_RESET_MODEL, @obj.handleResetModel );
obj.Client.subscribe( obj.CHANNEL_OPEN_HELP, @obj.handleOpenHelp );
obj.Client.subscribe( obj.CHANNEL_EXPORT_ANALYSIS, @obj.handleExportAnalysis );
end 

function handleResetModel( obj, ~ )


data = struct( 'channel', obj.Client.ChannelGroup, 'uuid', obj.DataModel.UUID );
obj.Client.publish( obj.CHANNEL_RESET_MODEL, data );
end 

function handleOpenHelp( obj, ~ )
try 
helpview( fullfile( docroot, 'coder/helptargets.map' ), 'learn_more_review_compatibility' );
catch 
obj.throwError( message( 'coderApp:screener:helpUnavailable' ).getString(  ) );
end 
end 

function handleExportAnalysis( obj, data )
if strcmp( data.type, obj.EXPORT_PLAINTEXT )
textReport = coderapp.internal.screener.screenerTextReport( obj.getScreenerResult(  ) );


fd = fopen( data.file, 'wt' );

if ( fd ==  - 1 )
obj.throwError( message( 'coderApp:screener:exportResultTextFailed' ).getString(  ) );
else 
fprintf( fd, '%s', textReport );
fclose( fd );

if codergui.internal.canEditInMatlab( 'native' ) || codergui.internal.canEditInMatlab( 'external' )
edit( data.file );
end 
end 
elseif strcmp( data.type, obj.EXPORT_WORKSPACE )
result = codergui.internal.ScreenerInfoBuilder.build( obj.getScreenerResult(  ), Model = obj.Model, UIHandle = obj );
assignin( 'base', data.variable, result );
else 
error( [ 'Unknown export type: ', data.type ] );
end 
end 


function handleEditFile( obj, data )
if ~isempty( data.location )
location = data.location + 1;
else 
location = 1;
end 

try 
opentoline( data.file, location, 0 );
catch me
obj.throwError( me.message );
end 
end 

function throwError( obj, message )
obj.Client.publish( obj.CHANNEL_ERROR, message );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQckbJm.p.
% Please follow local copyright laws when handling this file.

