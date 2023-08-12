classdef ( Sealed = true )ProcessingUnitInfo < codertarget.Info





properties ( Access = 'public' )
DefinitionFileName;
TgtHardwareName = '';
TargetFolder = '';
Name = 'None';
DeviceID = 'Custom Processor->Custom Processor';
ProdHWDeviceType = 'Custom Processor->Custom Processor';
NumOfCores = 1;
EnableProdHWDeviceType = false;
ToolChainInfo = struct( 'Name', {  }, 'LoaderName', {  }, 'LoadCommand', {  }, 'LoadCommandArgs', {  }, 'IsLoadCommandMATLABFcn', {  } );
ProcessorCoreInfo = struct( 'Name', {  }, 'DeviceID', {  }, 'Vendor', {  } );
ParameterInfoFile = '';
AttributeInfoFile = '';
SchedulerInfoFiles = {  };
RTOSInfoFiles = {  };
Type = 'cpu';
IsMaster = true;
MasterSlaveSyncInfoFile;
PUAttachedTo = '';
end 

properties ( Access = 'private' )
regRoot = fullfile( '$(TARGET_ROOT)', 'registry' );
end 


methods 
function h = ProcessingUnitInfo( varargin )
p = inputParser;
p.addOptional( 'filePathName', '', @isfile );
p.addOptional( 'progUnitName', 'None', @ischar );
p.addOptional( 'tgtHardwareName', '', @ischar );
p.parse( varargin{ : } )

if ~isempty( p.Results.tgtHardwareName )
h.TgtHardwareName = tgtHardwareName;
end 
h.DefinitionFileName = p.Results.filePathName;
h.Name = p.Results.progUnitName;
h.TargetFolder = fileparts( fileparts( fileparts( h.DefinitionFileName ) ) );
if ~isempty( h.DefinitionFileName )
h.deserialize(  );
end 
end 

function register( h )
h.serialize(  );
end 
function out = getMasterSlaveSyncInfo( h )
infoFile = strrep( h.MasterSlaveSyncInfoFile,  ...
'$(TARGET_ROOT)', h.TargetFolder );
out = codertarget.targethardware.MasterSlaveSyncInfo(  ...
infoFile );
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
function setTgtHardwareName( h, name )
h.TgtHardwareName = name;
end 
function ret = getTgtHardwareName( h )
ret = h.TgtHardwareName;
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
function setNumOfCores( h, val )
h.NumOfCores = val;
end 
function val = getNumOfCores( h )
val = h.NumOfCores;
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
function ret = getParameterInfoFile( h )
ret = h.ParameterInfoFile;
end 
function ret = getAttributeInfoFile( h )
ret = h.AttributeInfoFile;
end 
function ret = getMasterSlaveSyncInfoFile( h )
ret = h.MasterSlaveSyncInfoFile;
end 
function ret = getSchedulerInfoFiles( h )
ret = h.SchedulerInfoFiles;
end 
function ret = getRTOSInfoFiles( h )
ret = h.RTOSInfoFiles;
end 
function ret = getToolChainInfo( h )
ret = h.ToolChainInfo;
end 
function addSchedulerInfoFile( h, name )
h.SchedulerInfoFiles{ end  + 1 } = name;
end 
function addRTOSInfoFile( h, name )
h.RTOSInfoFiles{ end  + 1 } = name;
end 
function setMasterSlaveSyncInfoFile( h, name )
h.MasterSlaveSyncInfoFile = name;
end 
function setParameterInfoFile( h, name )
h.ParameterInfoFile = name;
end 
function setAttributeInfoFile( h, name )
h.AttributeInfoFile = name;
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
function setIsMaster( h, val )
if ~ischar( val ) && ~islogical( val )
DAStudio.error( 'codertarget:targetapi:InvalidLogicalProperty',  ...
'IsMaster' );
end 
if isempty( val )
val = false;
elseif ischar( val )
val = ~isequal( val, 'false' ) && ~isequal( val, '0' );
end 
h.IsMaster = val;
end 
end 

methods ( Hidden = true, Access = 'public' )
function ret = getProcessingUnitInfoForSerialize( h )
ret.name = h.Name;
ret.type = h.Type;
ret.deviceid = h.DeviceID;
ret.productionhwdevicetype = h.ProdHWDeviceType;
ret.enableprodhwdevicetype = h.EnableProdHWDeviceType;
ret.processorcore = h.getProcessorCoreInfoForSerialize(  );
ret.toolchain = h.getToolChainInfoForSerialize(  );
ret.parameterinfo = h.getParameterInfoForSerialize;
ret.attributeinfo = h.getAttributeInfoForSerialize;
ret.scheduler = h.getSchedulerFilePaths;
ret.rtosinfo = h.getRTOSFilePaths;
ret.ismaster = h.IsMaster;
ret.masterslavesyncinfo = h.MasterSlaveSyncInfoFile;
end 

function out = isValidField( ~, s, field )
out = isfield( s, field ) &&  ...
~isempty( s.( field ) );
end 

function addProcessingUnitInfo( h, value )
for jj = 1:numel( value )
if isequal( value( jj ).name, h.Name )
try 
h.Name = value( jj ).name;
if isfield( value( jj ), 'puattachedto' )
h.PUAttachedTo = value( jj ).puattachedto;
end 
h.DeviceID = value( jj ).deviceid;
h.ProdHWDeviceType = value( jj ).productionhwdevicetype;
h.setIsEnableProdHWDeviceType(  ...
value( jj ).enableprodhwdevicetype );
if h.isValidField( value( jj ), 'ismaster' )
h.setIsMaster(  ...
value( jj ).ismaster );
end 
h.NumOfCores = numel( value( jj ).processorcore );
h.Type = value( jj ).type;
if h.isValidField( value( jj ), 'attributeinfo' )
h.AttributeInfoFile = value( jj ).attributeinfo;
end 
if h.isValidField( value( jj ), 'parameterinfo' )
h.ParameterInfoFile = value( jj ).parameterinfo;
end 
if h.isValidField( value( jj ), 'scheduler' )
h.SchedulerInfoFiles = { value( jj ).scheduler };
end 
if h.isValidField( value( jj ), 'rtosinfo' )
h.RTOSInfoFiles = { value( jj ).rtosinfo };
end 
if h.isValidField( value( jj ), 'masterslavesyncinfo' )
h.MasterSlaveSyncInfoFile = value( jj ).masterslavesyncinfo;
end 
if h.isValidField( value( jj ), 'toolchain' )
h.addToolChainInfo( value( jj ).toolchain )
end 
if h.isValidField( value( jj ), 'processorcore' )
h.addProcessorCoreInfo( value( jj ).processorcore )
end 
catch ex
DAStudio.error( 'codertarget:targetapi:StructureInputInvalid', 'proggrammingunit', '''name'', ''deviceid'', ''productionhwdevicetype'' and ''enableprodhwdevicetype''' );
end 
end 
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
DAStudio.error( 'codertarget:targetapi:StructureInputInvalid', 'toolchain', '''name'', ''loadcommand'', ''loadcommandargs'' and ''IsLoadCommandMATLABFcn''' );
end 
end 
end 

function addProcessorCoreInfo( h, value )
for jj = 1:numel( value )
h.ProcessorCoreInfo( end  + 1 ) = struct( 'Name', '', 'DeviceID', '', 'Vendor', '' );
try 
h.ProcessorCoreInfo( end  ).Name = value( jj ).name;
h.ProcessorCoreInfo( end  ).DeviceID = value( jj ).deviceid;
h.ProcessorCoreInfo( end  ).Vendor = value( jj ).vendor;
catch ex
DAStudio.error( 'codertarget:targetapi:StructureInputInvalid', 'processorcore', '''name'', ''deviceid'' and ''vendor''' );
end 
end 
end 
end 

methods ( Access = 'private' )
function ret = getProcessorCoreInfoForSerialize( h )
n = numel( h.ProcessorCoreInfo );
ret = repmat( struct( 'name', '', 'deviceid', '', 'vendor', '' ), [ 1, n ] );
for jj = 1:n
ret( jj ).name = h.ProcessorCoreInfo( jj ).Name;
ret( jj ).deviceid = h.ProcessorCoreInfo( jj ).DeviceID;
ret( jj ).productionhwdevicetype = h.ProcessorCoreInfo( jj ).Vendor;
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
function ret = getParameterInfoForSerialize( h )
ret = '';
paramInfoFile = h.getParameterInfoFile(  );
if ~isempty( paramInfoFile )
ret = h.getRegistryPathName( 'parameters', paramInfoFile );
end 
end 
function ret = getMasterSlaveSyncInfoFileForSerialize( h )
ret = '';
masterSlaveInfoFile = h.getMasterSlaveSyncInfoFile(  );
if ~isempty( masterSlaveInfoFile )
ret = h.getRegistryPathName( 'attributes', masterSlaveInfoFile );
end 
end 
function ret = getAttributeInfoForSerialize( h )
ret = '';
attribInfoFile = h.getAttributeInfoFile(  );
if ~isempty( attribInfoFile )
ret = h.getRegistryPathName( 'attributes', attribInfoFile );
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

function serialize( ~ )

end 

function deserialize( h )
docObj = h.read( h.DefinitionFileName );

prodInfoList = docObj.getElementsByTagName( 'productinfo' );
rootItem = prodInfoList.item( 0 );
h.TgtHardwareName = h.getElement( rootItem, 'name', 'char' );

h.ParameterInfoFile = h.getElement( rootItem,  ...
'parameterinfo', 'char' );
h.MasterSlaveSyncInfoFile = h.getElement( rootItem,  ...
'masterslavesyncinfo', 'char' );
h.AttributeInfoFile = h.getElement( rootItem,  ...
'attributeinfo', 'char' );
h.SchedulerInfoFiles = h.getElement( rootItem,  ...
'scheduler', 'cell' );
h.RTOSInfoFiles = h.getElement( rootItem,  ...
'rtosinfo', 'cell' );
h.DeviceID = h.getElement( rootItem, 'deviceid', 'char' );
h.ProdHWDeviceType = h.getElement( rootItem,  ...
'productionhwdevicetype', 'char' );
h.EnableProdHWDeviceType = h.getElement( rootItem,  ...
'enableprodhwdevicetype', 'logical' );
h.IsMaster = h.getElement( rootItem, 'ismaster', 'logical' );

h.addProcessingUnitInfo( h.getElement( rootItem,  ...
'processingunit', 'struct' ) );
if isempty( h.ToolChainInfo )
h.addToolChainInfo( h.getElement( rootItem,  ...
'toolchain', 'struct' ) );
end 
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpCj3s8n.p.
% Please follow local copyright laws when handling this file.

