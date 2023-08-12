classdef MasterSlaveSyncInfo < codertarget.Info





properties ( SetAccess = private, GetAccess = public )
BuildConfigurationFile = ''
end 
properties ( Dependent )
TargetFolder
end 
properties 
Name = '';
TargetName = '';
DefinitionFileName = '';
ReadyToBootFcn = '';
BootFcn = '';
ModelInitFcn = '';
AckModelInitFcn = '';
EndModelInitFcn = '';
ReadyToRunAppFcn = '';
RunAppFcn = '';
BuildConfigurationInfo
CPUId = 1
end 

methods 
function h = MasterSlaveSyncInfo( varargin )
p = inputParser;
p.addOptional( 'filePathName', '', @isfile );
p.addOptional( 'cpuName', '', @ischar );
p.parse( varargin{ : } )

h.DefinitionFileName = fullfile( p.Results.filePathName );
h.Name = p.Results.cpuName;
if ~isempty( h.DefinitionFileName )
h.deserialize(  );
end 
end 
function set.DefinitionFileName( h, name )
validateattributes( name, { 'char', 'string' }, {  } );
h.DefinitionFileName = name;
end 
function name = get.DefinitionFileName( h )
name = h.DefinitionFileName;
end 
function out = get.TargetFolder( h )
out = fileparts( fileparts( fileparts( h.DefinitionFileName ) ) );
end 
function set.Name( h, name )
validateattributes( name, { 'char', 'string' }, {  } );
h.Name = name;
end 
function name = get.Name( h )
name = h.Name;
end 
function set.CPUId( h, id )
validateattributes( id, { 'numeric' }, { 'nonempty', 'scalar' } );
h.CPUId = id;
end 
function id = get.CPUId( h )
id = h.CPUId;
end 
function set.ReadyToBootFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.ReadyToBootFcn = fcnName;
end 
function fcnName = get.ReadyToBootFcn( h )
fcnName = h.ReadyToBootFcn;
end 
function set.BootFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.BootFcn = fcnName;
end 
function fcnName = get.BootFcn( h )
fcnName = h.BootFcn;
end 
function set.ModelInitFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.ModelInitFcn = fcnName;
end 
function fcnName = get.ModelInitFcn( h )
fcnName = h.ModelInitFcn;
end 
function set.AckModelInitFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.AckModelInitFcn = fcnName;
end 
function fcnName = get.AckModelInitFcn( h )
fcnName = h.AckModelInitFcn;
end 
function set.EndModelInitFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.EndModelInitFcn = fcnName;
end 
function fcnName = get.EndModelInitFcn( h )
fcnName = h.EndModelInitFcn;
end 
function set.ReadyToRunAppFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.ReadyToRunAppFcn = fcnName;
end 
function fcnName = get.ReadyToRunAppFcn( h )
fcnName = h.ReadyToRunAppFcn;
end 
function set.RunAppFcn( h, fcnName )
validateattributes( fcnName, { 'char', 'string' }, {  } );
h.RunAppFcn = fcnName;
end 
function fcnName = get.RunAppFcn( h )
fcnName = h.RunAppFcn;
end 
function register( h )
h.serialize(  );
end 

function deserialize( h )
docObj = h.read( h.DefinitionFileName );

prodInfoList = docObj.getElementsByTagName( 'productinfo' );
rootItem = prodInfoList.item( 0 );

h.Name = h.getElement( rootItem, 'name', 'char' );
h.CPUId = h.getElement( rootItem, 'cpuid', 'numeric' );
h.ReadyToBootFcn = h.getElement( rootItem, 'readytobootfcn', 'char' );
h.BootFcn = h.getElement( rootItem, 'bootfcn', 'char' );
h.ModelInitFcn = h.getElement( rootItem, 'modelinitfcn', 'char' );
h.AckModelInitFcn = h.getElement( rootItem, 'ackmodelinitfcn', 'char' );
h.EndModelInitFcn = h.getElement( rootItem, 'endmodelinitfcn', 'char' );
h.ReadyToRunAppFcn = h.getElement( rootItem, 'readytorunappfcn', 'char' );
h.RunAppFcn = h.getElement( rootItem, 'runappfcn', 'char' );
h.BuildConfigurationFile =  ...
h.getElement( rootItem, 'buildconfigurationinfofile', 'char' );
[ attributesFolder, ~, ~ ] = fileparts( h.DefinitionFileName );
[ ~, name, ext ] = fileparts( h.BuildConfigurationFile );
bcFile = fullfile( attributesFolder, [ name, ext ] );
bcObj = codertarget.attributes.BuildConfigurationInfo( bcFile );
h.addNewBuildConfigurationInfo( bcObj.get );
end 
end 

methods ( Access = 'public', Hidden )
function addNewBuildConfigurationInfo( h, name )
bcObj = codertarget.attributes.BuildConfigurationInfo;
bcObj.Name = name;
h.addNewElementToArrayProperty( h, 'BuildConfigurationInfo', bcObj );
end 
function allBCs = getBuildConfigurationInfo( h, varargin )
p = inputParser;
p.addParameter( 'os', 'any' );
p.addParameter( 'toolchain', 'any' );
p.parse( varargin{ : } );
res = p.Results;
allBCs = [  ];
for j = 1:numel( h )
for i = 1:numel( h( j ).BuildConfigurationInfo )
infoFile = strrep( h.BuildConfigurationFile,  ...
'$(TARGET_ROOT)', h.TargetFolder );
bcObj = codertarget.attributes.BuildConfigurationInfo(  ...
infoFile );
isSupportedOS = isequal( res.os, 'any' ) ||  ...
isequal( bcObj.SupportedOperatingSystems, { 'all' } ) ||  ...
ismember( res.os, bcObj.SupportedOperatingSystems );
isSupportedToolchain = isequal( res.toolchain, 'any' ) ||  ...
isequal( bcObj.SupportedToolchains, { 'all' } ) ||  ...
ismember( res.toolchain, bcObj.SupportedToolchains );
if isSupportedOS && isSupportedToolchain
allBCs = [ allBCs, bcObj ];%#ok<AGROW>
end 
end 
end 
end 
end 
methods ( Access = 'private' )
function serialize( h )
docObj = h.createDocument( 'productinfo' );
docObj.item( 0 ).setAttribute( 'version', '3.0' );
h.setElement( docObj, 'name', h.Name(  ) );
h.setElement( docObj, 'cpuid', h.CPUId(  ) );
h.setElement( docObj, 'targetname', h.TargetName );
h.setElement( docObj, 'readytobootfcn', h.ReadyToBootFcn(  ) );
h.setElement( docObj, 'bootfcn', h.BootFcn(  ) );
h.setElement( docObj, 'modelinitfcn', h.ModelInitFcn(  ) );
h.setElement( docObj, 'ackmodelinitfcn', h.AckModelInitFcn(  ) );
h.setElement( docObj, 'endmodelinitfcn', h.EndModelInitFcn(  ) );
h.setElement( docObj, 'readytorunappfcn', h.ReadyToRunAppFcn(  ) );
h.setElement( docObj, 'runappfcn', h.RunAppFcn(  ) );

name = fullfile( h.DefinitionFileName );

for jj = 1:numel( h.BuildConfigurationInfo )
bcObj = h.BuildConfigurationInfo( jj );
if isempty( bcObj.DefinitionFileName )
fileName = codertarget.internal.makeValidFileName(  ...
[ bcObj.Name, '_', h.Name ] );
else 
[ ~, fileName ] = fileparts( bcObj.DefinitionFileName );
end 
absoluteFilename = [ h.TargetFolder, '/registry/attributes/', fileName, '.xml' ];
bcObj.DefinitionFileName = absoluteFilename;
bcObj.serialize;
relativeFileName = [ '$(TARGET_ROOT)', '/registry/attributes/', fileName, '.xml' ];
relativeFileName = codertarget.utils.replacePathSep( relativeFileName );
h.setElement( docObj, 'buildconfigurationinfofile', relativeFileName );
end 
h.write( name, docObj );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQZuoc0.p.
% Please follow local copyright laws when handling this file.

