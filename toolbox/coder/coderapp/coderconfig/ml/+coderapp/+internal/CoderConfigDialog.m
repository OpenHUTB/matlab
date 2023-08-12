classdef ( Sealed )CoderConfigDialog < coderapp.internal.config.ui.ConfigDialog


properties ( Constant )
Factory = coder.internal.gui.Serviceable( [  ], @coderapp.internal.CoderConfigDialog )
end 

properties ( Constant, Access = private )
SharedConfigurations = containers.Map(  )
end 

properties ( SetAccess = immutable )
ConfigClass( 1, : )char
end 

properties ( SetAccess = immutable, GetAccess = private )
Reusing( 1, 1 )logical = false
end 

properties ( Dependent )
Config
end 

properties ( Dependent, GetAccess = private, SetAccess = immutable )
ProductionKey
end 

methods 
function this = CoderConfigDialog( cfgArg, varargin )
R36
cfgArg{ mustBeSupportedConfigOrEmpty( cfgArg ) } = [  ]
end 
R36( Repeating )
varargin
end 

ip = inputParser(  );
ip.KeepUnmatched = true;
ip.addParameter( 'ReuseConfigurations', true, @islogical );
ip.addParameter( 'Show', true, @islogical );
ip.addParameter( 'WorkspaceVariable', '', @ischar );
ip.parse( varargin{ : } );
extras = namedargs2cell( ip.Unmatched );

reuse = false;
configurationArg = [  ];
boundConfig = [  ];
if isempty( cfgArg )
configurationArg = cfgArg;
cfgArg = 'coder.EmbeddedCodeConfig';
elseif isa( cfgArg, 'coderapp.internal.config.Configuration' )
configurationArg = cfgArg;
cfgArg = 'coder.EmbeddedCodeConfig';
prodKey = 'config';
boundKey = '';
else 
reuse = ip.Results.ReuseConfigurations;
boundConfig = cfgArg;
end 

shouldDestroy = true;
if isempty( configurationArg )
[ schema, boundKey, prodKey ] = coderapp.internal.CoderConfigDialog.getSchema( cfgArg );
if reuse
map = coderapp.internal.CoderConfigDialog.SharedConfigurations;
if map.isKey( boundKey )
configurationArg = map( boundKey );
map.remove( boundKey );
shouldDestroy = false;
end 
end 
if isempty( configurationArg )
configurationArg = schema;
end 
end 

this@coderapp.internal.config.ui.ConfigDialog( configurationArg,  ...
'Controller', coderapp.internal.coderconfig.CoderConfigUiController(  ...
'ProductionKey', prodKey,  ...
'MonitorWorkspace', true,  ...
'WorkspaceVariable', ip.Results.WorkspaceVariable ),  ...
'Page', 'toolbox/coder/coderapp/coderconfig/web/coderconfigdialog',  ...
'BoundObject', boundConfig,  ...
'BoundObjectKey', boundKey,  ...
'DeferSetup', true,  ...
'Show', false,  ...
extras{ : } );

if isobject( cfgArg )
this.ConfigClass = class( cfgArg );
else 
this.ConfigClass = cfgArg;
end 
this.manageInstances( 'add', this );
this.Reusing = reuse;
this.DestroyConfiguration = shouldDestroy;

if ip.Results.Show
this.show(  );
end 
end 

function delete( this )
if ~isempty( this.Configuration ) && this.Reusing
this.DestroyConfiguration = ~this.returnConfigurationInstance(  );
end 
this.manageInstances( 'remove', this );
delete@coderapp.internal.config.ui.ConfigDialog( this );
end 

function set.Config( this, config )
assert( isempty( config ) || this.Configuration.Schema == this.getSchema( config ),  ...
'Not a compatible config type for this dialog''s schema: %s', class( config ) );
this.resetConfiguration(  );
this.BoundObject = config;
end 

function config = get.Config( this )
if ~isempty( this.BoundObjectKey )
config = this.BoundObject;
elseif ~isempty( this.ProductionKey )
config = this.Configuration.get( this.ProductionKey );
else 
config = [  ];
end 
end 

function prodKey = get.ProductionKey( this )
prodKey = this.Controller.ProductionKey;
end 

function importConfig( this, config )
assert( isempty( config ) || ismember( this.ConfigClass, superclasses( class( config ) ) ),  ...
'Not a supported config class for this dialog: %s', class( config ) );
this.finishSetup(  );
if ~isempty( config ) && ~isempty( this.ProductionKey )
this.Configuration.import( this.ProductionKey, config );
end 
end 
end 

methods ( Access = private )
function returned = returnConfigurationInstance( this )
map = coderapp.internal.CoderConfigDialog.SharedConfigurations;

if ~map.isKey( this.BoundObjectKey )
this.resetConfiguration(  );
map( this.BoundObjectKey ) = this.Configuration;%#ok<NASGU>
returned = true;
else 
returned = false;
end 
end 

function resetConfiguration( this )
if ~isempty( this.Configuration.get( this.BoundObjectKey ) )
this.Configuration.set( this.BoundObjectKey, [  ] );
end 
modifiedKeys = this.Configuration.Keys;
modifiedKeys = modifiedKeys( this.Configuration.isUserModified( modifiedKeys ) );
for i = 1:numel( modifiedKeys )
this.Configuration.reset( modifiedKeys{ i } );
end 
end 
end 

methods ( Static, Access = private )
function instance = getSharedConfiguration( schema, boundObjKey )
R36
schema
boundObjKey
end 
map = coderapp.internal.CoderConfigDialog.SharedConfigurations;
if reuse && map.isKey( boundObjKey )
instance = map( boundObjKey );
map.remove( boundObjKey );
else 
instance = coderapp.internal.config.Configuration( schema );
end 
end 
end 

methods ( Static, Hidden )
function [ schema, boundObjectKey, productionKey ] = getStandaloneSchema( configClass, reload )

R36
configClass = ''
reload( 1, 1 ){ mustBeNumericOrLogical( reload ) } = false
end 

warning( 'Deprecation Warning: Use coderapp.internal.CoderConfigDialog.getSchema instead' );
[ schema, boundObjectKey, productionKey ] = coderapp.internal.CoderConfigDialog.getSchema( configClass, reload );
end 

function [ schema, boundObjectKey, productionKey ] = getSchema( configClass, reload )
R36
configClass = ''
reload( 1, 1 ){ mustBeNumericOrLogical( reload ) } = false
end 

[ schema, info ] = coderapp.internal.getConfigSchema( ConfigType = toConfigClass( configClass ), Reload = reload );
boundObjectKey = info.boundObjectKey;
productionKey = info.productionKey;
end 

function instance = getInstance( config, varName )
R36
config( 1, 1 )handle
varName{ mustBeTextScalar( varName ) } = ''
end 
instance = coderapp.internal.CoderConfigDialog.manageInstances(  ...
'get', config, 'WorkspaceVariable', varName );
end 

function closeAll(  )
coderapp.internal.CoderConfigDialog.manageInstances( 'purge' );
end 

function clearAll(  )

coderapp.internal.CoderConfigDialog.closeAll(  );

map = coderapp.internal.CoderConfigDialog.SharedConfigurations;
map.remove( map.keys(  ) );

coderapp.internal.CoderConfigDialog.getSchema( [  ], true );
end 
end 

methods ( Static, Access = private )
function varargout = manageInstances( mode, arg, varargin )
R36
mode{ mustBeMember( mode, { 'add', 'remove', 'get', 'purge', 'findByVariable' } ) }
arg = [  ]
end 
R36( Repeating )
varargin
end 
persistent instances;
if ~isobject( instances )
instances = coderapp.internal.CoderConfigDialog.empty(  );
end 
switch mode
case 'add'
narginchk( 2, 2 );
assert( isa( arg, 'coderapp.internal.CoderConfigDialog' ) );
instances( end  + 1 ) = arg;
case 'remove'
narginchk( 2, 2 );
assert( isa( arg, 'coderapp.internal.CoderConfigDialog' ) );
instances = setdiff( instances, arg, 'stable' );
case 'get'
narginchk( 1, Inf );
mustBeSupportedConfigOrEmpty( arg );
ip = inputParser(  );
ip.KeepUnmatched = true;
ip.addParameter( 'WorkspaceVariable', '', @ischar );
ip.parse( varargin{ : } );
varargout{ 1 } = doGetInstance( instances, arg, ip.Results.WorkspaceVariable, varargin );
case 'purge'
narginchk( 1, 1 );
for instance = instances
instance.delete(  );
end 
case 'findByVariable'
narginchk( 2, 2 );
varargout{ 1 } = [  ];
for instance = instances
if isvalid( instance ) && strcmp( instance.Controller.WorkspaceVariable, arg )
varargout{ 1 } = instance;
break 
end 
end 
otherwise 
assert( false, 'Missing branch for "%s"', mode );
end 
end 
end 
end 


function instance = doGetInstance( instances, cfg, varName, factoryArgs )
if ~isempty( cfg ) && isobject( cfg ) && ~isempty( instances )
for instance = instances
if ~isvalid( instance ) || ( ~isempty( varName ) && ~strcmp( instance.Controller.WorkspaceVariable, varName ) )
continue 
end 


monitoring = instance.Controller.MonitorWorkspace;
if monitoring
instance.Controller.MonitorWorkspace = false;
end 

if isempty( instance.Config ) || instance.Config ~= cfg

if instance.Configuration.Schema == coderapp.internal.CoderConfigDialog.getSchema( cfg )

coder.internal.ddux.logger.logCoderEventData( "configAppOpen", class( cfg ) );
instance.Config = cfg;
else 

instance.delete(  );
end 
elseif instance.Config == cfg

end 
if isvalid( instance )
if monitoring
instance.Controller.MonitorWorkspace = true;
end 
return 
end 
end 
end 

coder.internal.ddux.logger.logCoderEventData( "configAppOpen", class( cfg ) );
instance = coderapp.internal.CoderConfigDialog.Factory.run( cfg, factoryArgs{ : } );
end 


function configClass = toConfigClass( configClass )
if isempty( configClass )
configClass = 'coder.EmbeddedCodeConfig';
elseif isobject( configClass )
configClass = class( configClass );
else 
mustBeTextScalar( configClass );
end 
end 


function mustBeSupportedConfigOrEmpty( configArg )
assert( isempty( configArg ) || isa( configArg, 'coderapp.internal.config.Configuration' ) ||  ...
ismember( class( configArg ), {  ...
'coder.Config', 'coder.EmbeddedCodeConfig', 'coder.CodeConfig',  ...
'coder.MexCodeConfig', 'coder.MexConfig', 'coder.GpuCodeConfig',  ...
'coder.HardwareImplementation' } ), 'Must be a supported config object or empty' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpPx4XrR.p.
% Please follow local copyright laws when handling this file.

