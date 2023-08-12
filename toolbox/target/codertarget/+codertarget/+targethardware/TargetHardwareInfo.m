classdef ( Sealed = true )TargetHardwareInfo < codertarget.Info





properties ( Access = 'public' )
DefinitionFileName;
TargetName = '';
TargetFolder = '';
TargetType = 0;
Name = '';
DisplayName = '';
Aliases = {  };
DeviceID = '';
SubFamily = '';
ProdHWDeviceType = '';
NumOfCores = 1;
EnableProdHWDeviceType = false;
ToolChainInfo = struct( 'Name', {  }, 'LoaderName', {  }, 'LoadCommand', {  }, 'LoadCommandArgs', {  }, 'IsLoadCommandMATLABFcn', {  } );
ProcessingUnitInfo;
ParameterInfoFile = '';
AttributeInfoFile = '';
ForwardingInfoFile = '';
SchedulerInfoFiles = {  };
RTOSInfoFiles = {  };
ASAP2ToolInfo = '';
MATLABPILInfo = struct( 'GetPropsFcn', '' );
ESBCompatible = 0;
BoardForwardingFcn = [  ];
Release = '';
SupportSoCBProfiling = 0;
TaskMap = struct( 'isSupported', false, 'useAutoMap', false );
SupportsPeripherals = false;
SupportsOnlySimulation = false;
BaseProductID = 0;
PreferenceName = '';
SupportsConnectedIO = false;
DefaultIOBlocksMode = 'deployed';
end 

properties ( Access = 'private' )
regRoot = fullfile( '$(TARGET_ROOT)', 'registry' );
end 

methods 
function h = TargetHardwareInfo( filePathName, targetName )
if ( nargin > 1 )
h.TargetName = targetName;
end 
if ( nargin > 0 )
h.DefinitionFileName = filePathName;
h.deserialize(  );
end 
end 
function register( h )
h.serialize(  );
end 
function ret = getDefinitionFileName( h )
ret = h.DefinitionFileName;
end 
function setDefinitionFileName( h, name )
h.DefinitionFileName = name;
end 
function ret = getName( h )
ret = h.Name;
end 
function setName( h, name )
h.Name = name;
end 
function ret = getPreferenceName( h )
ret = h.PreferenceName;
end 
function setPreferenceName( h, name )
h.PreferenceName = name;
end 
function ret = getDisplayName( h )
ret = h.DisplayName;
end 
function setDisplayName( h, name )
h.DisplayName = name;
end 
function ret = getTargetName( h )
ret = h.TargetName;
end 
function setDeviceID( h, name )
h.DeviceID = name;
end 
function ret = getDeviceID( h )
ret = h.DeviceID;
end 
function setProdHWDeviceType( h, name )
h.ProdHWDeviceType = name;
end 
function ret = getProdHWDeviceType( h )
ret = h.ProdHWDeviceType;
end 
function setRelease( h, release )
h.Release = release;
end 
function ret = getRelease( h )
ret = h.Release;
end 
function setBaseProductID( h, baseProductID )
validateattributes( baseProductID, { 'codertarget.targethardware.BaseProductID', { 'nonempty' } } );
h.BaseProductID = baseProductID;
end 
function out = getBaseProductID( h )
out = h.BaseProductID;
end 
function setSubFamily( h, name )
h.SubFamily = name;
end 
function ret = getSubFamily( h )
ret = h.SubFamily;
end 
function setNumOfCores( h, val )
h.NumOfCores = val;
end 
function val = getNumOfCores( h )
val = h.NumOfCores;
end 
function setTargetName( h, name )
h.TargetName = name;
end 
function ret = getProcessingUnit( h )
ret = { h.ProcessingUnitInfo( : ).Name };
end 
function ret = hasProcessingUnit( h )
ret = ~isempty( h.ProcessingUnitInfo );
end 
function addProcessingUnit( h, procUnit )
h.addProcessingUnitInfo( procUnit );
end 
function deleteProcessingUnit( h, procUnit )
pu = h.getProcessingUnit(  );
pu_index = ismember( pu, procUnit );
if nnz( pu_index )
h.ProcessingUnitInfo = h.ProcessingUnitInfo( ~pu_index );
end 
end 
function ret = getToolChain( h )
ret = { h.ToolChainInfo( : ).Name };
end 
function addToolChain( h, toolChain )
h.addToolChainInfo( struct( 'name',  ...
toolChain, 'loadername', '', 'loadcommand', '', 'loadcommandargs',  ...
'', 'IsLoadCommandMATLABFcn', false ) );
end 
function deleteToolChain( h, toolChain )
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChain );
if nnz( tc_index )
h.ToolChainInfo = h.ToolChainInfo( ~tc_index );
end 
end 
function ret = getLoadCommand( h, toolChainName )






ret = {  };
if nargin == 2
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
ret = { h.ToolChainInfo( tc_index ).LoadCommand };
end 
else 
ret = { h.ToolChainInfo( : ).LoadCommand };
end 
end 
function setLoaderName( h, value, toolChainName )






if nargin == 3
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
h.ToolChainInfo( tc_index ).LoaderName = value;
end 
else 
for jj = 1:numel( h.ToolChainInfo )
h.ToolChainInfo( jj ).LoaderName = value;
end 
end 
end 
function setLoadCommand( h, value, toolChainName )






if nargin == 3
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
h.ToolChainInfo( tc_index ).LoadCommand = value;
end 
else 
for jj = 1:numel( h.ToolChainInfo )
h.ToolChainInfo( jj ).LoadCommand = value;
end 
end 
end 
function ret = getASAP2ToolInfo( h )
ret = h.ASAP2ToolInfo;
end 
function addASAP2ToolInfo( h, asap2tool )
h.ASAP2ToolInfo = asap2tool;
end 
function ret = getSchedulerInfoFiles( h )
ret = h.SchedulerInfoFiles;
end 
function addSchedulerInfoFile( h, name )
h.SchedulerInfoFiles{ end  + 1 } = name;
end 
function ret = getRTOSInfoFiles( h )
ret = h.RTOSInfoFiles;
end 
function ret = getToolChainInfo( h )
ret = h.ToolChainInfo;
end 
function addRTOSInfoFile( h, name )
h.RTOSInfoFiles{ end  + 1 } = name;
end 
function ret = getParameterInfoFile( h )
ret = h.ParameterInfoFile;
end 
function setParameterInfoFile( h, name )
h.ParameterInfoFile = name;
end 
function ret = getAttributeInfoFile( h )
ret = h.AttributeInfoFile;
end 
function setAttributeInfoFile( h, name )
h.AttributeInfoFile = name;
end 
function setForwardingInfoFile( h, name )
h.ForwardingInfoFile = name;
end 
function ret = getForwardingInfoFile( h )
ret = h.ForwardingInfoFile;
end 
function ret = getLoadCommandArgs( h, toolChainName )






ret = {  };
if nargin == 2
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
ret = { h.ToolChainInfo( tc_index ).LoadCommandArgs };
end 
else 
ret = { h.ToolChainInfo( : ).LoadCommandArgs };
end 
end 
function setLoadCommandArgs( h, value, toolChainName )






if nargin == 3
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
h.ToolChainInfo( tc_index ).LoadCommandArgs = value;
end 
else 
for jj = 1:numel( h.ToolChainInfo )
h.ToolChainInfo( jj ).LoadCommandArgs = value;
end 
end 
end 
function ret = getIsLoadCommandMATLABFcn( h, toolChainName )






ret = {  };
if nargin == 2
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
ret = { h.ToolChainInfo( tc_index ).IsLoadCommandMATLABFcn };
end 
else 
ret = { h.ToolChainInfo( : ).IsLoadCommandMATLABFcn };
end 
end 
function setIsLoadCommandMATLABFcn( h, value, toolChainName )






if nargin == 3
tc = h.getToolChain(  );
tc_index = ismember( tc, toolChainName );
if nnz( tc_index )
h.ToolChainInfo( tc_index ).IsLoadCommandMATLABFcn = value;
end 
else 
for jj = 1:numel( h.ToolChainInfo )
h.ToolChainInfo( jj ).IsLoadCommandMATLABFcn = value;
end 
end 
end 
function names = getRegisteredSchedulers( h )
names = {  };
if codertarget.target.isTargetRegistered( h.getTargetName )
targetFolder = codertarget.target.getTargetFolder( h.getTargetName(  ) );
folder = codertarget.target.getSchedulerRegistryFolder( targetFolder );
schedulerFiles = codertarget.utils.getFilesInFolder( folder );
names = cell( 1, numel( schedulerFiles ) );
for i = 1:numel( schedulerFiles )
names{ i } = schedulerFiles( i ).name;
end 
end 
end 
function names = getSchedulerFilePaths( h )
schedulers = h.getSchedulerInfoFiles(  );
names = cell( 1, length( schedulers ) );
for i = 1:numel( schedulers )
names{ i } = h.getRegistryPathName( 'schedulers', schedulers{ i } );
end 
end 
function names = getRTOSFilePaths( h )
rtos = h.getRTOSInfoFiles(  );
names = cell( 1, length( rtos ) );
for i = 1:numel( rtos )
names{ i } = h.getRegistryPathName( 'rtos', rtos{ i } );
end 
end 
function ret = getIsEnableProdHWDeviceType( h )
ret = h.EnableProdHWDeviceType;
end 
function setIsEnableProdHWDeviceType( h, val )
if ~ischar( val ) && ~islogical( val )
DAStudio.error( 'codertarget:targetapi:InvalidLogicalProperty',  ...
'EnableProdHWDeviceType' );
end 
if isempty( val )
val = false;
elseif ischar( val )
val = ~isequal( val, 'false' ) && ~isequal( val, '0' );
end 
h.EnableProdHWDeviceType = val;
end 

function ret = getSupportsOnlySimulation( h )
ret = h.SupportsOnlySimulation;
end 
function setSupportsOnlySimulation( h, val )
if ~ischar( val ) && ~islogical( val )
DAStudio.error( 'codertarget:targetapi:InvalidLogicalProperty',  ...
'SupportsOnlySimulation' );
end 
if isempty( val )
val = false;
elseif ischar( val )
val = ~isequal( val, 'false' ) && ~isequal( val, '0' );
end 
h.SupportsOnlySimulation = val;
end 

function ret = getSupportsConnectedIO( h )
ret = h.SupportsConnectedIO;
end 

function setSupportsConnectedIO( h, val )
validateattributes( val, { 'char', 'logical', 'numeric' }, {  }, '', '''SupportsConnectedIO''' );
if isnumeric( val )
val = logical( val );
elseif ischar( val )
validatestring( val, { 'true', '1', 'false', '0', '' }, '', '''SupportsConnectedIO''' );
val = isequal( val, 'true' ) || isequal( val, '1' );
end 
h.SupportsConnectedIO = val;
end 

function mode = getDefaultIOBlocksMode( h )
mode = h.DefaultIOBlocksMode;
end 

function setDefaultIOBlocksMode( h, val )
if isempty( val )
val = 'deployed';
end 
validatestring( val, { 'deployed', 'connected', '' }, '', 'property ''DefaultIOBlocksMode''' );

h.DefaultIOBlocksMode = val;
end 

function set.TargetFolder( h, val )
if isempty( val )
h.TargetFolder = '';
else 
if ~ischar( val ) && ~isstring( val )
DAStudio.error( 'codertarget:targetapi:InvalidStringProperty', 'TargetFolder' );
end 
h.TargetFolder = val;
end 
end 
function ret = getAliases( h )
ret = h.Aliases;
end 
function set.Aliases( h, val )
if isempty( val )
h.Aliases = {  };
elseif ischar( val ) || iscell( val ) || isstring( val )
h.Aliases = cellstr( val );
end 
end 
function set.BoardForwardingFcn( h, val )
if isempty( val )
h.BoardForwardingFcn = '';
else 
if ~ischar( val ) && ~isstring( val )
DAStudio.error( 'codertarget:targetapi:InvalidStringProperty', 'OpenModelFcn' );
end 
h.BoardForwardingFcn = val;
end 
end 
function ret = getBoardForwardingFcn( h )
ret = h.BoardForwardingFcn;
end 
end 

methods ( Hidden = true, Access = 'public' )
function addProcessingUnitInfo( h, procUnitInfoArray )

if numel( procUnitInfoArray ) > 1
h.ProcessingUnitInfo =  ...
codertarget.targethardware.ProcessingUnitInfo( h.DefinitionFileName );
end 
for jj = 1:numel( procUnitInfoArray )
thisVal = procUnitInfoArray( jj );
if isa( thisVal, 'codertarget.targethardware.ProcessingUnitInfo' )
procUnitToAdd = thisVal;
elseif isstruct( thisVal )
procUnitName = thisVal.name;
procUnitToAdd =  ...
codertarget.targethardware.ProcessingUnitInfo( h.DefinitionFileName, procUnitName );
else 
if ~ischar( thisVal ) && ~isstring( thisVal )
DAStudio.error( 'codertarget:targetapi:InvalidStringProperty', 'Name' );
end 
procUnitToAdd =  ...
codertarget.targethardware.ProcessingUnitInfo( h.DefinitionFileName, thisVal );
end 
h.ProcessingUnitInfo =  ...
[ h.ProcessingUnitInfo, procUnitToAdd ];
end 
end 
function addToolChainInfo( h, value )
for jj = 1:numel( value )
h.ToolChainInfo( end  + 1 ) = struct( 'Name', '', 'LoaderName', '', 'LoadCommand', '', 'LoadCommandArgs', '', 'IsLoadCommandMATLABFcn', false );
try 
h.ToolChainInfo( end  ).Name = value( jj ).name;
if isfield( value( jj ), 'loadername' )
h.ToolChainInfo( end  ).LoaderName = value( jj ).loadername;
else 
h.ToolChainInfo( end  ).LoaderName = value( jj ).name;
end 
h.ToolChainInfo( end  ).LoadCommand = value( jj ).loadcommand;
h.ToolChainInfo( end  ).LoadCommandArgs = value( jj ).loadcommandargs;
if ischar( value( jj ).IsLoadCommandMATLABFcn )
h.ToolChainInfo( end  ).IsLoadCommandMATLABFcn = isequal( value( jj ).IsLoadCommandMATLABFcn, 'true' );
elseif islogical( value( jj ).IsLoadCommandMATLABFcn )
h.ToolChainInfo( end  ).IsLoadCommandMATLABFcn = value( jj ).IsLoadCommandMATLABFcn;
end 
catch ex
h.ToolChainInfo = h.ToolChainInfo( 1:end  - 1 );
DAStudio.error( 'codertarget:targetapi:StructureInputInvalid',  ...
'toolchain', '''name'', ''loadcommand'', ''loadcommandargs'' and ''IsLoadCommandMATLABFcn''' );
end 
end 
end 
function setTaskMap( h, value )
for i = 1:numel( value )
try 

if ~ischar( value.issupported ) && ~islogical( value.issupported )
DAStudio.error( 'codertarget:targetapi:InvalidLogicalProperty',  ...
'issupported' );
end 
if ~ischar( value.useautomap ) && ~islogical( value.useautomap )
DAStudio.error( 'codertarget:targetapi:InvalidLogicalProperty',  ...
'useautomap' );
end 
if ischar( value.issupported ) && startsWith( value.issupported, 'matlab:' )
h.TaskMap.isSupported = value.issupported;
else 
h.TaskMap.isSupported = ~isequal( value.issupported, 'false' ) && ~isequal( value.issupported, '0' );
end 
if ischar( value.useautomap ) && startsWith( value.useautomap, 'matlab:' )
h.TaskMap.useAutoMap = value.useautomap;
else 
h.TaskMap.useAutoMap = ~isequal( value.useautomap, 'false' ) && ~isequal( value.useautomap, '0' );
end 
catch ex
h.TaskMap = h.TaskMap;
DAStudio.error( 'codertarget:targetapi:StructureInputInvalid',  ...
'taskmap', '''issupported'', ''useautomap''' );
end 
end 
end 
function setSupportsPeripherals( h, val )
if ~ischar( val ) && ~islogical( val )
DAStudio.error( 'codertarget:targetapi:InvalidLogicalProperty',  ...
'SupportsPeripherals' );
end 
if isempty( val )
val = false;
elseif ischar( val )
val = ~isequal( val, 'false' ) && ~isequal( val, '0' );
end 
h.SupportsPeripherals = val;
end 
end 

methods ( Access = 'private' )
function ret = getProcessingUnitInfoForSerialize( h )
for jj = 1:numel( h.ProcessingUnitInfo )
ret( jj ) = h.ProcessingUnitInfo( jj ).getProcessingUnitInfoForSerialize(  );%#ok<AGROW>
end 
end 

function ret = getToolChainInfoForSerialize( h )
n = numel( h.ToolChainInfo );
ret = repmat( struct( 'name', '', 'loadcommand', '', 'loadcommandargs', '', 'IsLoadCommandMATLABFcn', '' ), [ 1, n ] );
for jj = 1:n
ret( jj ).name = h.ToolChainInfo( jj ).Name;
if ~isempty( h.ToolChainInfo( jj ).LoaderName )
ret( jj ).loadername = h.ToolChainInfo( jj ).LoaderName;
else 
ret( jj ).loadername = h.ToolChainInfo( jj ).Name;
end 
ret( jj ).loadcommand = h.ToolChainInfo( jj ).LoadCommand;
ret( jj ).loadcommandargs = h.ToolChainInfo( jj ).LoadCommandArgs;
ret( jj ).IsLoadCommandMATLABFcn = h.ToolChainInfo( jj ).IsLoadCommandMATLABFcn;
end 
end 

function ret = getTaskMap( h )

ret.issupported = h.TaskMap.isSupported;
ret.useautomap = h.TaskMap.useAutoMap;
end 

function ret = getMATLABPILInfoForSerialize( h )
if ~isempty( h.MATLABPILInfo ) && ~isempty( h.MATLABPILInfo.GetPropsFcn )
ret = struct( 'GetPropsFcn', h.MATLABPILInfo.GetPropsFcn );
else 
ret = '';
end 
end 

function ret = getParameterInfoForSerialize( h )
ret = '';
paramInfoFile = h.getParameterInfoFile(  );
if ~isempty( paramInfoFile )
ret = h.getRegistryPathName( 'parameters', paramInfoFile );
end 
end 

function ret = getAttributeInfoForSerialize( h )
ret = '';
attribInfoFile = h.getAttributeInfoFile(  );
if ~isempty( attribInfoFile )
ret = h.getRegistryPathName( 'attributes', attribInfoFile );
end 
end 
function ret = getForwardingInfoForSerialize( h )
ret = '';
forwardingInfoFile = h.getForwardingInfoFile(  );
if ~isempty( forwardingInfoFile )
ret = h.getRegistryPathName( 'forwarding', forwardingInfoFile );
end 
end 
function name = getRegistryPathName( h, folder, name )
[ regPath, name, ext ] = fileparts( name );
if isempty( regPath )
name = fullfile( h.regRoot, folder, [ name, ext ] );
else 
name = fullfile( regPath, [ name, ext ] );
end 
name = codertarget.utils.replacePathSep( name );
end 

function ret = getShortDefinitionFileName( h )
[ ~, name, ext ] = fileparts( h.DefinitionFileName );
ret = [ name, ext ];
end 

function serialize( h )
docObj = h.createDocument( 'productinfo' );
docObj.item( 0 ).setAttribute( 'version', '2.0' );
h.setElement( docObj, 'name', h.getName(  ) );
h.setElement( docObj, 'alias', h.getAliases(  ) );
h.setElement( docObj, 'preferencename', h.getPreferenceName(  ) );
h.setElement( docObj, 'release', h.getRelease(  ) );
h.setElement( docObj, 'baseproductid', double( h.getBaseProductID(  ) ) );
h.setElement( docObj, 'displayname', h.getDisplayName(  ) );
h.setElement( docObj, 'deviceid', h.getDeviceID(  ) );
h.setElement( docObj, 'subfamily', h.getSubFamily(  ) );
if ~isempty( h.ProcessingUnitInfo )
h.setElement( docObj, 'processingunit', h.getProcessingUnitInfoForSerialize(  ) );
end 
h.setElement( docObj, 'numofcores', h.getNumOfCores(  ) );
h.setElement( docObj, 'productionhwdevicetype', h.getProdHWDeviceType(  ) );
h.setElement( docObj, 'enableprodhwdevicetype', h.EnableProdHWDeviceType );
h.setElement( docObj, 'supportsonlysimulation', h.SupportsOnlySimulation );
h.setElement( docObj, 'asap2toolinfo', h.getASAP2ToolInfo(  ) );
h.setElement( docObj, 'toolchain', h.getToolChainInfoForSerialize(  ) );
h.setElement( docObj, 'parameterinfo', h.getParameterInfoForSerialize(  ) );
h.setElement( docObj, 'attributeinfo', h.getAttributeInfoForSerialize(  ) );
h.setElement( docObj, 'forwardinginfo', h.getForwardingInfoForSerialize(  ) );
h.setElement( docObj, 'boardforwardingfcn', h.getBoardForwardingFcn(  ) );
h.setElement( docObj, 'scheduler', h.getSchedulerFilePaths(  ) );
h.setElement( docObj, 'rtosinfo', h.getRTOSFilePaths(  ) );
h.setElement( docObj, 'matlabpilinfo', h.getMATLABPILInfoForSerialize(  ) );
h.setElement( docObj, 'esbcompatible', h.ESBCompatible );
h.setElement( docObj, 'supportssocbprofiling', h.SupportSoCBProfiling );
h.setElement( docObj, 'taskmap', h.getTaskMap );
h.setElement( docObj, 'supportsperipherals', h.SupportsPeripherals );
h.setElement( docObj, 'supportsconnectedio', h.SupportsConnectedIO );
h.setElement( docObj, 'defaultioblocksmode', h.DefaultIOBlocksMode );

targetFolder = codertarget.target.getTargetFolder( h.getTargetName(  ) );
folder = codertarget.target.getTargetHardwareRegistryFolder( targetFolder );
name = fullfile( folder, h.getShortDefinitionFileName(  ) );
h.write( name, docObj );
sl_refresh_customizations;
end 

function deserialize( h )
docObj = h.read( h.DefinitionFileName );

prodInfoList = docObj.getElementsByTagName( 'productinfo' );
rootItem = prodInfoList.item( 0 );
prodInfo = struct;
if rootItem.hasAttributes
prodInfo.( char( rootItem.getAttributes.item( 0 ).getName ) ) = char( rootItem.getAttributes.item( 0 ).getValue );
end 
if ~isfield( prodInfo, 'version' )
prodInfo = struct( 'version', '1.0' );
end 
switch ( prodInfo.version )
case '2.0'
h.deserialize_version2( rootItem );
case '1.0'
h.deserialize_version2( rootItem );
toolchains = h.getElement( rootItem, 'toolchaininfo', 'cell' );
loadcommand = h.getElement( rootItem, 'loadcommandinfo', 'cell' );
loadcommandargs = h.getElement( rootItem, 'loadcommandargs', 'char' );
for ii = 1:numel( toolchains )
h.addToolChain( toolchains{ ii } );
h.setLoadCommand( loadcommand{ ii }, toolchains{ ii } );
h.setLoadCommandArgs( loadcommandargs, toolchains{ ii } );
end 
end 
end 

function deserialize_version2( h, rootItem )
h.Name = h.getElement( rootItem, 'name', 'char' );
h.PreferenceName = h.getElement( rootItem, 'preferencename', 'char' );
h.Release = h.getElement( rootItem, 'release', 'char' );
h.Aliases = h.getElement( rootItem, 'alias', 'cell' );
h.BoardForwardingFcn = h.getElement( rootItem, 'boardforwardingfcn', 'char' );
h.DisplayName = h.getElement( rootItem, 'displayname', 'char' );
h.DeviceID = h.getElement( rootItem, 'deviceid', 'char' );
h.SubFamily = h.getElement( rootItem, 'subfamily', 'char' );
numOfCores = h.getElement( rootItem, 'numofcores', 'numeric' );
if isnumeric( numOfCores )
h.NumOfCores = numOfCores;
end 
h.ProdHWDeviceType = h.getElement( rootItem, 'productionhwdevicetype', 'char' );
h.setIsEnableProdHWDeviceType( h.getElement( rootItem, 'enableprodhwdevicetype', 'logical' ) );
h.setSupportsOnlySimulation( h.getElement( rootItem, 'supportsonlysimulation', 'logical' ) );
h.addProcessingUnitInfo( h.getElement( rootItem, 'processingunit', 'struct' ) );
h.addToolChainInfo( h.getElement( rootItem, 'toolchain', 'struct' ) );
h.ParameterInfoFile = h.getElement( rootItem, 'parameterinfo', 'char' );
h.AttributeInfoFile = h.getElement( rootItem, 'attributeinfo', 'char' );
h.ForwardingInfoFile = h.getElement( rootItem, 'forwardinginfo', 'char' );
h.SchedulerInfoFiles = h.getElement( rootItem, 'scheduler', 'cell' );
h.RTOSInfoFiles = h.getElement( rootItem, 'rtosinfo', 'cell' );
h.ASAP2ToolInfo = h.getElement( rootItem, 'asap2toolinfo', 'char' );
info = h.getElement( rootItem, 'matlabpilinfo', 'struct' );
id = h.getElement( rootItem, 'baseproductid', 'numeric' );
if ~isempty( id )
h.BaseProductID = codertarget.targethardware.BaseProductID( id );
end 
if ~isempty( info )
h.MATLABPILInfo = info;
end 
esbCompatible = h.getElement( rootItem, 'esbcompatible', 'numeric' );
if isnumeric( esbCompatible )
h.ESBCompatible = esbCompatible;
end 
supportSoCBProfiling = h.getElement( rootItem, 'supportssocbprofiling', 'numeric' );
if isnumeric( supportSoCBProfiling )
h.SupportSoCBProfiling = supportSoCBProfiling;
end 
h.setTaskMap( h.getElement( rootItem, 'taskmap', 'struct' ) );
h.setSupportsPeripherals( h.getElement( rootItem, 'supportsperipherals', 'logical' ) );
h.setSupportsConnectedIO( h.getElement( rootItem, 'supportsconnectedio', 'logical' ) );
h.setDefaultIOBlocksMode( h.getElement( rootItem, 'defaultioblocksmode', 'char' ) );
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpXuxVmn.p.
% Please follow local copyright laws when handling this file.

