function unpackProtectedModels( this )
































numMdls = numel( this.AllModels );

for ii = 1:numMdls
this.mdlIdx = ii;
mdlName = this.AllModels( ii ).modelName;
if ii == numMdls

if this.nonTopDut
startNode = this.getStartNodeName;
else 
startNode = this.OrigStartNodeName;
end 
if isempty( startNode )
startNode = mdlName;
end 
else 
startNode = mdlName;
end 



mdlRefs = findActiveBlocks( startNode, 'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
'BlockType', 'ModelReference' );
if ~isempty( mdlRefs )
configManager = this.getConfigManager( mdlName );
this.loadConfigfiles( this.getConfigFiles, mdlName );
unpackAll( this, configManager, mdlRefs );
end 

end 
end 

function checkProtectedModelReferenceImplParams( this, mdlRef, impl )
hMdlRef = get_param( mdlRef, 'handle' );
if isprop( get_param( hMdlRef, 'Object' ), 'ProtectedModel' ) &&  ...
strcmp( get_param( mdlRef, 'ProtectedModel' ), 'on' )


if ~slfeature( 'ProtectedModelWithGeneratedHDLCode' )
error( message( 'hdlcoder:validate:ModelRefProtectedModel' ) );
end 

if ~isa( impl, 'hdldefaults.ModelReference' )
this.addCheck( this.ModelName, 'Error', message( 'hdlcoder:validate:ProtectedModelArchitectureNotModelReference', mdlRef ) );
else 
for i = 1:numel( impl.getImplParamDefaults )
implParamStruct = impl.getImplParamDefaults{ i };
implParamName = implParamStruct.ImplParamName;
implParamVal = impl.getImplParams( implParamName );
implParamDefaultVal = implParamStruct.DefaultValue;
if ~isempty( implParamVal ) && ~isequal( implParamVal, implParamDefaultVal )
this.addCheck( this.ModelName, 'Warning', message( 'hdlcoder:validate:ProtectedModelNonDefaultHDLBlockProperty', mdlRef, implParamName ) );
end 
end 
end 
end 
end 

function unpackAll( this, configManager, mdlRefs )

protectedmodels = {  };
for mdlIdx = 1:numel( mdlRefs )
mdlRef = mdlRefs{ mdlIdx };
impl = configManager.getImplementationForBlock( mdlRef );




checkProtectedModelReferenceImplParams( this, mdlRef, impl );

if isa( impl, 'hdldefaults.ModelReference' )

isProtected = get_param( mdlRef, 'ProtectedModel' );
if strcmp( isProtected, 'on' )
try 

if ~slfeature( 'ProtectedModelWithGeneratedHDLCode' )
error( message( 'hdlcoder:validate:ModelRefProtectedModel' ) );
end 


refMdlFile = get_param( mdlRef, 'ModelFile' );



[ opts, ~ ] = Simulink.ModelReference.ProtectedModel.getOptions( refMdlFile, 'runConsistencyChecksNoPlatform' );
if ~opts.hasHDLSupport
this.addCheck( this.ModelName, 'Error', message( 'hdlcoder:validate:ProtectedModelWithNoHDLCodeGenSupport', refMdlFile ) );
end 

[ ~, refMdlName, ~ ] = fileparts( refMdlFile );
hdldisp( message( 'hdlcoder:hdldisp:UnpackingProtectedModel', refMdlName ) );

protectedmodels = [ protectedmodels, refMdlName ];%#ok



unpackDir = this.hdlGetBaseCodegendir(  );








protectedMdlFullName = which( refMdlFile );
if isempty( protectedMdlFullName )
protectedMdlFullName = refMdlFile;
end 
Simulink.ModelReference.ProtectedModel.unpack( protectedMdlFullName, 'HDL', unpackDir );



newDir = fullfile( unpackDir, refMdlName );
if exist( newDir, 'dir' ) == 7
newDirFullName = fullfile( pwd, newDir );
pathCell = regexp( path, pathsep, 'split' );
if ispc
onPath = any( strcmpi( newDirFullName, pathCell ) );
else 
onPath = any( strcmp( newDirFullName, pathCell ) );
end 




if onPath
rmpath( newDirFullName );
end 
rmdir( newDir, 's' );
end 
mkdir( newDir );

vhdlExtension = hdlget_param( this.ModelName, 'VHDLFileExtension' );
vlogExtension = hdlget_param( this.ModelName, 'VerilogFileExtension' );
compileFilePostFix = hdlget_param( this.ModelName, 'HDLCompileFilePostfix' );
mapFilePostfix = hdlget_param( this.ModelName, 'HDLMapFilePostfix' );
vhdlNamePattern = [ '*', vhdlExtension ];
vlogNamePattern = [ '*', vlogExtension ];
compileScriptPattern = [ '*', compileFilePostFix ];
mapFilePattern = [ '*', mapFilePostfix ];

codegenstatusFile = fullfile( unpackDir, 'hdlcodegenstatus.mat' );
compileScriptFile = fullfile( unpackDir, compileScriptPattern );
mapFileRegExp = fullfile( unpackDir, mapFilePattern );
verilogFilePattern = fullfile( unpackDir, vlogNamePattern );
vhdlFilePattern = fullfile( unpackDir, vhdlNamePattern );
protectedModelName = slInternal( 'getPackageNameForModel', refMdlName );
gmPrefix = hdlget_param( this.ModelName, 'GeneratedModelNamePrefix' );
protectedGMModelName = [ gmPrefix, protectedModelName ];
protectedGeneratedModel = fullfile( unpackDir, protectedGMModelName );


synthesisTarget = '';
synthesisTool = hdlget_param( this.ModelName, 'SynthesisTool' );
if strcmpi( synthesisTool, 'Altera Quartus II' )
synthesisTarget = 'Altera';
elseif strcmpi( synthesisTool, 'Xilinx ISE' )
synthesisTarget = 'Xilinx';
end 

if ~isempty( synthesisTarget )
targetSrcPath = fullfile( unpackDir, synthesisTarget );
if exist( targetSrcPath, 'dir' )
movefile( targetSrcPath, newDir );
end 
end 





movefile( codegenstatusFile, newDir );


movefile( protectedGeneratedModel, newDir );



movefile( compileScriptFile, newDir );


mapFiles = dir( mapFileRegExp );
if ~isempty( mapFiles )
mapFilesName = { mapFiles( : ).name };
mapFilesFolder = { mapFiles( : ).folder };

cellfun( @( f, n )movefile( fullfile( f, n ), fullfile( newDir, n ) ), mapFilesFolder, mapFilesName );
end 


vhdlFiles = dir( vhdlFilePattern );
if ~isempty( vhdlFiles )
vhdlFilesName = { vhdlFiles( : ).name };
srcFolders = { vhdlFiles( : ).folder };

cellfun( @( f, n )movefile( fullfile( f, n ), fullfile( newDir, n ) ), srcFolders, vhdlFilesName );
end 


verilogFiles = dir( verilogFilePattern );
if ~isempty( verilogFiles )
vlogFilesName = { verilogFiles( : ).name };
srcFolders = { verilogFiles( : ).folder };
cellfun( @( f, n )movefile( fullfile( f, n ), fullfile( newDir, n ) ), srcFolders, vlogFilesName );
end 
catch me
if strcmpi( me.identifier, 'Simulink:protectedModel:ProtectedModelWrongPassword' )
error( message( 'Simulink:protectedModel:ProtectedModelWrongPassword', refMdlFile ) );
else 
rethrow( me );
end 
end 
end 
end 
end 


if numel( protectedmodels )
checkMismatchingTopAndProtectedModelSettings( this, protectedmodels );
end 
end 

function checkMismatchingTopAndProtectedModelSettings( this, protectedmodels )



if ( exist( 'tmp_saveAllParamsProtected.m', 'file' ) )
delete( 'tmp_saveAllParamsProtected.m' );
end 
paramSet = hdlsaveparams( this.ModelName, 'tmp_saveAllParamsProtected.m', 'force_overwrite' );

topmodel = this.ModelName;
topmodelParamsUncovered = {  };


paramsToCheck = { 'TargetLanguage', 'ClockEdge',  ...
'ClockInputPort', 'FloatingPointTargetConfiguration',  ...
'HDLCodingStandard', 'ResetAssertedLevel',  ...
'ResetInputPort', 'ScalarizePorts', 'SynthesisTool' };
defaultVals = hdlcoderprops.CLI;
topmodelParams = containers.Map;


for ii = 1:numel( paramsToCheck )
param = paramsToCheck{ ii };
defaultVal = getDefaultValue( defaultVals, param );
if ~isequal( param, 'FloatingPointTargetConfiguration' )
defaultVal = lower( defaultVal );
end 
topmodelParams( param ) = defaultVal;
end 


for ii = 1:numel( paramSet )
object = paramSet( ii ).object;
param = paramSet( ii ).parameter;
val = paramSet( ii ).value;

if ~isequal( param, 'FloatingPointTargetConfiguration' )
val = lower( val );
end 


if ~any( ismember( paramsToCheck, param ) )
continue ;
end 

if isequal( topmodel, object )
topmodelParams( param ) = val;
topmodelParamsUncovered = [ topmodelParamsUncovered, param ];%#ok
end 
end 



cmdline = this.getCmdLineParams;
for ii = 1:numel( paramsToCheck )
param = paramsToCheck( ii );
index = find( strcmp( cmdline, param ) );
if ~isempty( index )
paramVal = cmdline( index + 1 );
paramVal = paramVal{ 1 };
defaultVal = getDefaultValue( defaultVals, char( param ) );
if ~isequal( char( param ), 'FloatingPointTargetConfiguration' )
paramVal = lower( paramVal );
defaultVal = lower( defaultVal );
end 
topmodelParams( char( param ) ) = paramVal;
if ~isequal( paramVal, defaultVal )
topmodelParamsUncovered = [ topmodelParamsUncovered, param ];%#ok
else 

rowsRem = strcmp( topmodelParamsUncovered, param );
topmodelParamsUncovered( rowsRem ) = [  ];%#ok
end 
end 
end 



topmodelParamsUncovered = unique( topmodelParamsUncovered );


for ii = 1:numel( paramSet )
object = paramSet( ii ).object;
param = paramSet( ii ).parameter;
val = paramSet( ii ).value;
if ~isequal( param, 'FloatingPointTargetConfiguration' )
val = lower( val );
end 

if ~any( ismember( paramsToCheck, param ) )
continue ;
end 


if isequal( topmodel, object )
continue ;
end 


if any( strcmp( protectedmodels, object ) )
rowsRem = strcmp( topmodelParamsUncovered, param );
topmodelParamsUncovered( rowsRem ) = [  ];
if isKey( topmodelParams, param )
topVal = topmodelParams( param );
if ~isequal( param, 'FloatingPointTargetConfiguration' )
topVal = lower( topVal );
end 
if isequal( param, 'FloatingPointTargetConfiguration' )
compareFloatingPointTargetConfiguration( this, param, topmodel, topVal, object, val );
elseif isequal( param, 'ScalarizePorts' )
compareScalarizePortsConfiguration( this, param, topmodel, topVal, object, val );
elseif ~isequal( lower( topVal ), lower( val ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', param, object, topVal, val ) );
end 
else 
topVal = topmodelParams( param );
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', param, object, topVal, val ) );
end 
end 
end 



if numel( protectedmodels )
for jj = 1:numel( topmodelParamsUncovered )
param = char( topmodelParamsUncovered( jj ) );
topVal = topmodelParams( param );
defaultVal = getDefaultValue( defaultVals, param );
if isequal( param, 'ScalarizePorts' )
compareScalarizePortsConfiguration( this, param, topmodel, topVal, object, defaultVal )
else 
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelDefaultMismatchWithTopModel', param, topmodel, topVal, defaultVal ) );
end 
end 
end 
delete( 'tmp_saveAllParamsProtected.m' );
end 

function compareScalarizePortsConfiguration( this, param, topmodel, topVal, object, val )
lTopVal = lower( topVal );
lVal = lower( val );
isNotCompatible = false;

if ( isequal( lTopVal, 'on' ) && isequal( lVal, 'off' ) )
isNotCompatible = true;
supportedValues = 'on/DUTLevel';
elseif ( isequal( lTopVal, 'off' ) && ~isequal( lVal, 'off' ) )
isNotCompatible = true;
supportedValues = 'off';
elseif ( isequal( lTopVal, 'dutlevel' ) && ~isequal( lVal, 'off' ) )
isNotCompatible = true;
supportedValues = 'off';
end 

if isNotCompatible
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelScalarizePortsConfigMismatch', param, val, object, topVal, topmodel, supportedValues ) );
end 
end 

function compareFloatingPointTargetConfiguration( this, param, topmodel, topVal, object, val )




if isempty( topVal ) && ~isempty( val )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', param, object, 'None', val.Library ) );
return ;
end 


libTop = topVal.Library;
libBot = val.Library;
if ~isequal( lower( libTop ), lower( libBot ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:Library';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libTop, libBot ) );
return ;
end 


libSettingsTop = topVal.LibrarySettings;
libSettingsBot = val.LibrarySettings;

if isequal( libTop, 'NativeFloatingPoint' )
if ~isequal( lower( libSettingsTop.LatencyStrategy ), lower( libSettingsBot.LatencyStrategy ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:LatencyStrategy';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.LatencyStrategy, libSettingsBot.LatencyStrategy ) );
elseif ~isequal( lower( libSettingsTop.HandleDenormals ), lower( libSettingsBot.HandleDenormals ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:HandleDenormals';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.HandleDenormals, libSettingsBot.HandleDenormals ) );
elseif ~isequal( lower( libSettingsTop.MantissaMultiplyStrategy ), lower( libSettingsBot.MantissaMultiplyStrategy ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:MantissaMultiplyStrategy';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.MantissaMultiplyStrategy, libSettingsBot.MantissaMultiplyStrategy ) );
elseif ~isequal( lower( libSettingsTop.PartAddShiftMultiplierSize ), lower( libSettingsBot.PartAddShiftMultiplierSize ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:PartAddShiftMultiplierSize';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.PartAddShiftMultiplierSize, libSettingsBot.PartAddShiftMultiplierSize ) );
elseif ~isequal( lower( libSettingsTop.Version ), lower( libSettingsBot.Version ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:Version';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.Version, libSettingsBot.Version ) );
end 
elseif isequal( libTop, 'ALTERAFPFUNCTIONS' )
if ~isequal( lower( libSettingsTop.InitializeIPPipelinesToZero ), lower( libSettingsBot.InitializeIPPipelinesToZero ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:InitializeIPPipelinesToZero';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.InitializeIPPipelinesToZero, libSettingsBot.InitializeIPPipelinesToZero ) );
end 
elseif isequal( libTop, 'ALTFP' )
if ~isequal( lower( libSettingsTop.LatencyStrategy ), lower( libSettingsBot.LatencyStrategy ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:LatencyStrategy';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.LatencyStrategy, libSettingsBot.LatencyStrategy ) );
elseif ~isequal( lower( libSettingsTop.Objective ), lower( libSettingsBot.Objective ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:Objective';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.Objective, libSettingsBot.Objective ) );
end 
elseif isequal( libTop, 'XILINXOGICORE' )
if ~isequal( lower( libSettingsTop.LatencyStrategy ), lower( libSettingsBot.LatencyStrategy ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:LatencyStrategy';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.LatencyStrategy, libSettingsBot.LatencyStrategy ) );
elseif ~isequal( lower( libSettingsTop.Objective ), lower( libSettingsBot.Objective ) )
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchFloatingConfigWithTop' ) );
mismatchParam = 'FloatingPointTargetConfig:Objective';
this.addCheck( topmodel, 'Error', message( 'hdlcoder:validate:ProtectedModelMismatchWithTopModel', mismatchParam, object, libSettingsTop.Objective, libSettingsBot.Objective ) );
end 
end 
end 

function val = getDefaultValue( defaultValStruct, paramName )
switch paramName
case 'TargetLanguage'
val = defaultValStruct.TargetLanguage;
case 'ClockEdge'
val = defaultValStruct.ClockEdge;
case 'ClockInputPort'
val = defaultValStruct.ClockInputPort;
case 'FloatingPointTargetConfiguration'
val = defaultValStruct.FloatingPointTargetConfiguration;
case 'HDLCodingStandard'
val = defaultValStruct.HDLCodingStandard;
case 'ResetAssertedLevel'
val = defaultValStruct.ResetAssertedLevel;
case 'ResetInputPort'
val = defaultValStruct.ResetInputPort;
case 'ScalarizePorts'
val = defaultValStruct.ScalarizePorts;
case 'SynthesisTool'
val = defaultValStruct.SynthesisTool;
otherwise 
val = '';
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpw9CBR1.p.
% Please follow local copyright laws when handling this file.

