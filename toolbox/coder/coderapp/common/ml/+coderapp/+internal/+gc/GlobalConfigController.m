classdef ( Hidden, Sealed )GlobalConfigController < coderapp.internal.config.AbstractController




properties ( Constant, Access = private )
HasExternal = ~isempty( which( 'codergui.dev.ExternalWebClient' ) )
HasSharedCodergui = ~isempty( which( 'codergui.ReportServices' ) )
HasDevLog = coderapp.internal.log.Logger.HAS_LOGGER_IMPL
end 

methods 
function updateWebClientType( this )
if this.HasSharedCodergui
real = codergui.ReportServices.getWebClientType(  );
else 
real = '';
end 

opts = this.get( 'AllowedValues' );
if real == "custom"
if ~any( { opts.Value } == "custom" )
opts( end  + 1 ).Value = 'custom';
opts( end  ).DisplayValue = 'Custom';
end 
else 
opts( { opts.Value } == "custom" ) = [  ];
end 
opts( { opts.Value } == "external" ).Enabled = this.HasExternal;
this.set( 'AllowedValues', opts );
this.set( 'DefaultValue', 'webwindow' );

if ~isempty( real )
this.SetAsExternal = true;
this.set( real );
end 
end 

function postSetWebClientType( this )
if this.HasSharedCodergui
codergui.ReportServices.gcSetWebClientType( this.get(  ) );
end 
end 

function initEnableLogging( this )
supported = this.HasDevLog;
this.set( 'Enabled', supported );
this.set( 'AllowedValues', unique( [ supported, false ] ) );
this.set( 'DefaultValue', false );
end 

function requireEnableLogging( this, enableLogging )
if ~enableLogging
this.set( false );
end 
end 

function initLogSinkType( this )
this.initSettingBackedParam(  );
this.postSetLogSinkType(  );
end 

function postSetLogSinkType( this )
if this.HasDevLog
coderapp.dev.log.globalSink( this.get(  ) );
this.postSetSettingBackedParam(  );
end 
end 

function initLogLevel( this )
this.import( 'AllowedValues', cellstr( enumeration( 'coderapp.internal.log.LogLevel' ) ) );
this.initSettingBackedParam(  );
end 

function postSetLogLevel( this )

coderapp.internal.log.globalLevel( this.get(  ) );

this.postSetSettingBackedParam(  );
end 

function updateLogFolder( this )
if this.HasDevLog
this.set( coderapp.dev.log.MultiFileLogSink.SHARED_FLAT.Folder );
else 
this.set( '' );
end 
end 

function postSetLogFolder( this )
if this.HasDevLog
folder = this.get(  );
for sink = coderapp.dev.log.MultiFileLogSink.SHARED
sink.Folder = folder;
end 
end 
end 

function updateSpareLogFolder( this )
if this.HasDevLog
this.set( coderapp.dev.log.MultiFileLogSink.SHARED_FLAT.Spare );
else 
this.set( false );
end 
end 

function postSetSpareLogFolder( this )
if this.HasDevLog
spare = this.get(  );
for sink = coderapp.dev.log.MultiFileLogSink.SHARED
sink.Spare = spare;
end 
end 
end 

function initSettingBackedParam( this )
settingValue = this.getSettingValue(  );
if ~isempty( settingValue )
this.SetAsExternal = true;
this.import( 'Value', settingValue );
this.SetAsExternal = false;
end 
end 

function postSetSettingBackedParam( this )
if this.UserModified
setting = this.getSetting( true );
if ~isempty( setting )
if isequal( this.metadata( 'persist' ), false )
setting.TemporaryValue = this.get(  );
else 
setting.PersonalValue = this.get(  );
end 
end 
else 
setting = this.getSetting(  );
if ~isempty( setting )
if setting.hasPersonalValue(  )
setting.clearPersonalValue(  );
end 
if setting.hasTemporaryValue(  )
setting.clearTemporaryValue(  );
end 
end 
end 
end 
end 

methods ( Access = private )
function pass = checkJava( this )
import matlab.internal.lang.capability.Capability;
persistent envPassed;
if isempty( envPassed )
envPassed = Capability.isSupported( Capability.ComplexSwing );
end 
needsJava = this.metadata( 'requiresJava' );
pass = isempty( needsJava ) || ~needsJava || envPassed;
end 

function setting = getSetting( this, create )
R36
this
create( 1, 1 )logical = false
end 

setting = matlab.settings.Setting.empty(  );
name = this.metadata( 'setting' );
if isempty( name )
return 
end 
group = this.getSettingsGroup(  );
if isempty( group )
return 
end 

tokens = strsplit( name, '.' );
for i = 1:numel( tokens ) - 1
if group.hasGroup( tokens{ i } )
group = group.( tokens{ i } );
elseif create
group = group.addGroup( tokens{ i } );
else 
return 
end 
end 

if group.hasSetting( tokens{ end  } )
setting = group.( tokens{ end  } );
elseif create
default = this.get( 'DefaultValue' );
setting = group.addSetting( tokens{ end  },  ...
'ValidationFcn', valueToSettingValidator( default ) );
end 
end 

function value = getSettingValue( this )
setting = this.getSetting(  );
if ~isempty( setting ) && ( setting.hasTemporaryValue(  ) || setting.hasPersonalValue(  ) )
value = setting.ActiveValue;
else 
value = [  ];
end 
end 
end 

methods ( Static )
function level = importLogLevel( levelArg )
level = char( coderapp.internal.log.LogLevel.toLevel( levelArg, true ) );
end 

function level = exportLogLevel( levelStr )
R36
levelStr{ mustBeTextScalar( levelStr ) }
end 

level = coderapp.internal.log.LogLevel( levelStr );
end 
end 

methods ( Static, Hidden )
function group = getSettingsGroup(  )
s = settings;
if s.hasGroup( 'coder' ) && s.coder.hasGroup( 'globalconfig' )
group = s.coder.globalconfig;
else 
group = [  ];
end 
end 
end 
end 


function validator = valueToSettingValidator( value )
if islogical( value )
validator = @matlab.settings.mustBeLogicalScalar;
elseif isinteger( value )
validator = @matlab.settings.mustBeIntegerScalar;
elseif isnumeric( value )
validator = @matlab.settings.mustBeNumericScalar;
elseif ischar( value ) || isstring( value )
validator = @matlab.settings.mustBeStringScalar;
else 
validator = function_handle.empty(  );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpyptRCP.p.
% Please follow local copyright laws when handling this file.

