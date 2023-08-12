classdef ( Hidden, Sealed )ConfigurationFacade < handle



properties ( Constant, Hidden )
AVAILABLE = ~isempty( which( 'coderapp.internal.config.Configuration' ) )
CAN_VIEW = coderapp.internal.gc.ConfigurationFacade.AVAILABLE && ~isempty( which( 'coderapp.internal.config.ui.GenericConfigDialog' ) )
SCHEMA_PATH = fullfile( matlabroot, 'toolbox/coder/coderapp/common/globalconfig_schema/_generated/globalconfig.xml' )
SNAPSHOT_PATH = fullfile( matlabroot, 'toolbox/coder/coderapp/common/globalconfig_schema/_generated/snapshot.json' )
end 

properties ( Constant, Access = private )
SINGLETON = coderapp.internal.gc.ConfigurationFacade(  )
end 

properties ( Access = private )
RealListenerHandle
ChangeListeners containers.Map
end 

methods ( Static )
function removeHandle = addChangeListener( callback )
R36
callback( 1, 1 )function_handle
end 

nargoutchk( 1, 1 );
facade = coderapp.internal.gc.ConfigurationFacade.SINGLETON;
listenerUuid = facade.doAddChangeListener( callback );
if ~isempty( listenerUuid )
removeHandle = onCleanup( @(  )facade.doRemoveChangeListener( listenerUuid ) );
else 
removeHandle = [  ];
end 
end 
end 

methods ( Static, Hidden )
function snapshot = getCurrentSnapshot(  )
configuration = getHelper( Create = false );
if isempty( configuration )

snapshot = getStaticSnapshot(  );
else 
snapshot = configuration.get( 'snapshot' );
end 
end 

function value = getValue( key )
configuration = getHelper( Create = false );
if isempty( configuration )
snapshot = getStaticSnapshot(  );
if isfield( snapshot, key )
value = snapshot.( key );
return 
else 
configuration = getHelper(  );
end 
end 
value = configuration.export( key );
end 

function setValue( strict, varargin )
R36
strict( 1, 1 )logical
end 
R36( Repeating )
varargin
end 

configuration = getHelper(  );
if strict || ~configuration.IsProcessing
configuration.import( varargin{ : } );
end 
end 

function configuration = getConfiguration(  )
configuration = getHelper(  );
end 

function resetAll(  )
configuration = getHelper( Create = false );
if ~isempty( configuration )
configuration.reset( coderapp.internal.gc.ConfigurationFacade.getKeys(  ) );
end 
end 

function resetKeys( keys )
configuration = getHelper( Create = false );
if ~isempty( configuration )
configuration.reset( keys );
end 
end 

function out = getKeys(  )
persistent keys;
if isempty( keys )
configuration = getHelper(  );
keys = configuration.Keys;
keys( configuration.getEntityType( keys ) ~= "Param" ) = [  ];
keys( configuration.isInternal( keys ) ) = [  ];
end 
out = keys;
end 

function out = tabCompleteValues( key, value )
configuration = getHelper(  );
out = configuration.valueTabCompleter( configuration, key, value, true );
end 
end 

methods ( Static, Hidden )
function configuration = loadConfiguration(  )
coderapp.internal.gc.ConfigurationFacade.assertAvailable(  );
file = coderapp.internal.gc.ConfigurationFacade.SCHEMA_PATH;
if ~isfile( file )
coderapp.internal.gc.ConfigurationFacade.revalidate(  );
end 
configuration = coderapp.internal.config.Configuration( file,  ...
'ScriptOptions', { 'Format', false }, 'EnableLogging', false );
end 

function revalidate(  )
coderapp.internal.gc.ConfigurationFacade.assertAvailable(  );
coderapp.internal.buildtools.config.validateSchemas(  ...
'toolbox/coder/coderapp/common/globalconfig_schema/globalconfig.schemaMap.json',  ...
'', PostValidate = 'coderapp.internal.gc.ConfigurationFacade.updateSnapshot' );
getHelper( Create = false, Reset = true );
end 

function updateSnapshot( schema )
coderapp.internal.gc.ConfigurationFacade.assertAvailable(  );
configuration = coderapp.internal.config.Configuration( schema, EnableLogging = false );
getHelper( UseInstance = configuration );
snapshot = configuration.get( 'snapshot' );
fprintf( 'Updating snapshot of initial globalconfig state...\n' );
[ ~, ~ ] = mkdir( fileparts( coderapp.internal.gc.ConfigurationFacade.SNAPSHOT_PATH ) );
fid = fopen( coderapp.internal.gc.ConfigurationFacade.SNAPSHOT_PATH, 'w', 'n', 'UTF-8' );
fprintf( fid, '%s', jsonencode( snapshot, PrettyPrint = true ) );
fclose( fid );
end 

function refreshWebClientType(  )
refreshByKey( 'WebClientType' );
end 

function refreshLogFolder(  )
refreshByKey( 'LogFolder' );
end 

function refreshSpareLogFolder(  )
refreshByKey( 'SpareLogFolder' );
end 

function assertAvailable(  )
assert( coderapp.internal.gc.ConfigurationFacade.AVAILABLE,  ...
'Configuration class not available' );
end 
end 

methods ( Access = private )
function this = ConfigurationFacade(  )
this.ChangeListeners = containers.Map(  );
end 

function uuid = doAddChangeListener( this, callback )
if ~this.AVAILABLE
uuid = '';
return 
end 
uuid = matlab.lang.internal.uuid(  );
this.ChangeListeners( uuid ) = callback;
if isempty( this.RealListenerHandle )
this.RealListenerHandle = listener( getHelper(  ), 'ConfigurationChanged', @( ~, evt )this.multiCastChange( evt ) );
end 
end 

function doRemoveChangeListener( this, listenerUuid )
if ~this.ChangeListeners.isKey( listenerUuid )
return 
end 
this.ChangeListeners.remove( listenerUuid );
if isempty( this.ChangeListeners ) && ~isempty( this.RealListenerHandle )
this.RealListenerHandle = [  ];
end 
end 

function multiCastChange( this, evt )
callbacks = this.ChangeListeners.values(  );
for i = 1:numel( callbacks )
callbacks{ i }( evt );
end 
end 
end 
end 


function refreshByKey( key )
if coderapp.internal.gc.ConfigurationFacade.AVAILABLE
configuration = getHelper(  );
if ~configuration.IsProcessing
configuration.refresh( key );
end 
end 
end 


function instance = getHelper( opts )
R36
opts.Create( 1, 1 )logical = true
opts.Reset( 1, 1 )logical = false
opts.UseInstance( 1, 1 )coderapp.internal.config.Configuration
end 

persistent singleton;
if isfield( opts, 'UseInstance' )
singleton = opts.UseInstance;
end 
if opts.Create && ( opts.Reset || isempty( singleton ) )
singleton = coderapp.internal.gc.ConfigurationFacade.loadConfiguration(  );
end 
if ~opts.Create && opts.Reset && ~isempty( singleton )
singleton = [  ];
end 
instance = singleton;
end 


function snapshot = getStaticSnapshot(  )
persistent cached;
if isempty( cached )
file = coderapp.internal.gc.ConfigurationFacade.SNAPSHOT_PATH;
if isfile( file )
try 
cached = jsondecode( fileread( file ) );
for fld = reshape( string( fieldnames( cached ) ), 1, [  ] )
cached.( fld ) = evalin( 'base', cached.( fld ) );
end 
catch 
end 
end 
end 
snapshot = cached;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp_QnCwy.p.
% Please follow local copyright laws when handling this file.

