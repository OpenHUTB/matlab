classdef ( Sealed = true )OperatingSystemDistributionInfo < codertarget.Info







properties ( Access = public )
DefinitionFileName = '';
Name = '';
OperatingSystemName = '';
GetMissingPackagesFcn = '';
RemovePackagesFcn = '';
BuildHostDeviceAddress = '';
BuildHostUsername = '';
BuildHostPassword = '';
SourceFolder = '';
OutputFolder = '';
BuildCmdFormat = '';
BuildArgs = [  ];
BuildCmd = '';
PrebuildFcn = '';
PostbuildFcn = '';
ImageFiles = '';
InstallCmd = '';
InstallCmdArgs = '';
InstallCmdType = '';
FeaturePackageInfo = [  ];




end 

methods ( Access = { ?embedded.OperatingSystemDistribution } )
function h = OperatingSystemDistributionInfo( filePathName )
if ( nargin == 1 )
h.DefinitionFileName = filePathName;
h.deserialize;
end 
end 
function register( h )
h.serialize;
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
function ret = getOperatingSystemName( h )
ret = h.OperatingSystemName;
end 
function setOperatingSystemName( h, name )
h.OperatingSystemName = name;
end 
function ret = getBuildHostDeviceAddress( h )
ret = h.BuildHostDeviceAddress;
end 
function setBuildHostDeviceAddress( h, addr )
h.BuildHostDeviceAddress = addr;
end 
function ret = getBuildHostUsername( h )
ret = h.BuildHostUsername;
end 
function setBuildHostUsername( h, username )
h.BuildHostUsername = username;
end 
function ret = getBuildHostPassword( h )
ret = h.BuildHostPassword;
end 
function setBuildHostPassword( h, password )
h.BuildHostPassword = password;
end 
function ret = getSourceFolder( h )
ret = h.SourceFolder;
end 
function setSourceFolder( h, srcFolder )
h.SourceFolder = srcFolder;
end 
function ret = getOutputFolder( h )
ret = h.OutputFolder;
end 
function setOutputFolder( h, outputFolder )
h.OutputFolder = outputFolder;
end 
function ret = getBuildCmdFormat( h )
ret = h.BuildCmdFormat;
end 
function setBuildCmdFormat( h, buildCmdFormat )
h.BuildCmdFormat = buildCmdFormat;
end 
function ret = getPrebuildFcn( h )
ret = h.PrebuildFcn;
end 
function setPrebuildFcn( h, fcn )
h.PrebuildFcn = fcn;
end 
function ret = getBuildArgs( h )
ret = h.BuildArgs;
end 
function setBuildArgs( h, args )
if iscell( args )
h.BuildArgs = [ h.BuildArgs, args ];
else 
h.BuildArgs{ end  + 1 } = args;
end 
end 

function ret = getBuildCmd( h )
ret = h.BuildCmd;
end 
function setBuildCmd( h, cmd )
h.BuildCmd = cmd;
end 
function ret = getPostbuildFcn( h )
ret = h.PostbuildFcn;
end 
function setPostbuildFcn( h, fcn )
h.PostbuildFcn = fcn;
end 
function ret = getInstallCmd( h )
ret = h.InstallCmd;
end 
function setInstallCmd( h, cmd )
h.InstallCmd = cmd;
end 
function ret = getInstallCmdArgs( h )
ret = h.InstallCmdArgs;
end 
function setInstallCmdArgs( h, args )
h.InstallCmdArgs{ end  + 1 } = args;
end 
function ret = getInstallCmdType( h )
ret = h.InstallCmdType;
end 
function setInstallCmdType( h, val )
h.InstallCmdType = val;
end 
function ret = getImageFiles( h )
ret = h.ImageFiles;
end 
function setImageFiles( h, files )
if iscell( files )
h.ImageFiles = [ h.ImageFiles, files ];
else 
h.ImageFiles{ end  + 1 } = files;
end 
end 

function addFeaturePackageInfo( h, FeatureName, Packages, LinkFlags, CompileFlags )
validateattributes( FeatureName, { 'char' }, { 'nonempty' }, 'addFeaturePackageInfo', 'FeatureName', 1 )
validateattributes( Packages, { 'cell' }, { 'nonempty' }, 'addFeaturePackageInfo', 'Packages', 2 )
validateattributes( LinkFlags, { 'cell' }, { 'nonempty' }, 'addFeaturePackageInfo', 'LinkFlags', 3 )
validateattributes( CompileFlags, { 'cell' }, { 'nonempty' }, 'addFeaturePackageInfo', 'CompileFlags', 4 )
if isempty( h.FeaturePackageInfo )
h.FeaturePackageInfo = struct( 'Feature', '', 'Packages', {  }, 'LinkFlags', {  }, 'CompileFlags', {  } );
h.FeaturePackageInfo( 1 ).Feature = FeatureName;
else 
h.FeaturePackageInfo( end  + 1 ).Feature = FeatureName;
end 
h.FeaturePackageInfo( end  ).Packages = Packages;
h.FeaturePackageInfo( end  ).LinkFlags = LinkFlags;
h.FeaturePackageInfo( end  ).CompileFlags = CompileFlags;
end 
end 

methods ( Access = 'private' )
function ret = getCombinedStringPropertyForObjects( ~, objs, propName )
ret = '';
for i = 1:numel( objs )
addValues = objs( i ).( propName );
if ~isempty( addValues )
if isempty( ret )
ret = strcat( ret, ' ' );
end 
ret = strcat( ret, addValues );%#ok<*AGROW>
end 
end 
end 
function setFeaturePackageInfo( h, inValue )
for ii = 1:numel( inValue )
value = inValue( ii );
if isfield( value, 'feature' )
feature = value.feature;
else 
feature = '';
end 
if isfield( value, 'packages' )
pkgs = value.packages;
else 
pkgs = {  };
end 
if isfield( value, 'linkflags' )
linkflags = value.linkflags;
else 
linkflags = {  };
end 

if isfield( value, 'compileflags' )
compileflags = value.compileflags;
else 
compileflags = {  };
end 
if ii == 1
h.FeaturePackageInfo( 1 ).Feature = feature;
else 
h.FeaturePackageInfo( end  + 1 ).Feature = feature;
end 
h.FeaturePackageInfo( end  ).Packages = pkgs;
h.FeaturePackageInfo( end  ).LinkFlags = linkflags;
h.FeaturePackageInfo( end  ).CompileFlags = compileflags;
end 
end 

function ret = getFeaturePackageInfo( h )
ret = [  ];
for ii = 1:numel( h.FeaturePackageInfo )
ret( end  + 1 ).feature = h.FeaturePackageInfo( ii ).Feature;
ret( end  ).packages = h.FeaturePackageInfo( ii ).Packages;
ret( end  ).linkflags = h.FeaturePackageInfo( ii ).LinkFlags;
ret( end  ).compileflags = h.FeaturePackageInfo( ii ).CompileFlags;
end 
end 

function ret = getShortDefinitionFileName( h )
[ ~, name, ext ] = fileparts( h.DefinitionFileName );
ret = [ name, ext ];
end 
function serialize( h )
docNode = matlab.io.xml.dom.Document( 'productinfo' );
docNode.item( 0 ).setAttribute( 'version', '1.0' );
h.setElement( docNode, 'name', h.getName );
h.setElement( docNode, 'operatingsystemname', h.getOperatingSystemName );
h.setElement( docNode, 'getmissingpackagesfcn', h.GetMissingPackagesFcn );
h.setElement( docNode, 'removepackagesfcn', h.RemovePackagesFcn );
h.setElement( docNode, 'buildhostdeviceaddress', h.getBuildHostDeviceAddress );
h.setElement( docNode, 'buildhostusername', h.getBuildHostUsername );
h.setElement( docNode, 'buildhostpassword', h.getBuildHostPassword );
h.setElement( docNode, 'sourcefolder', h.getSourceFolder );
h.setElement( docNode, 'outputfolder', h.getOutputFolder );
h.setElement( docNode, 'buildcmdformat', h.getBuildCmdFormat );
h.setElement( docNode, 'buildargs', h.getBuildArgs );
h.setElement( docNode, 'buildcmd', h.getBuildCmd );
h.setElement( docNode, 'prebuildfcn', h.getPrebuildFcn );
h.setElement( docNode, 'postbuildfcn', h.getPostbuildFcn );
h.setElement( docNode, 'imagefiles', h.getImageFiles );
h.setElement( docNode, 'installcmd', h.getInstallCmd );
h.setElement( docNode, 'installcmdargs', h.getInstallCmdArgs );
h.setElement( docNode, 'installcmdtype', h.getInstallCmdType );
h.setElement( docNode, 'featurepackageinfo', h.getFeaturePackageInfo );
attributesFolder = fullfile( pwd, 'registry' );
if ~exist( attributesFolder, 'dir' )
mkdir( fullfile( attributesFolder ) );
end 
attributesName = fullfile( attributesFolder, h.getShortDefinitionFileName );
attributesName = codertarget.utils.replacePathSep( attributesName );
writer = matlab.io.xml.dom.DOMWriter;
writer.Configuration.FormatPrettyPrint = true;
writer.writeToFile( docNode, attributesName );
end 

function deserializefeaturepackageinfo( h, rootItem )
h.setFeaturePackageInfo( h.getElement( rootItem, 'featurepackageinfo', 'struct' ) );
end 

function deserializeCurrent( h, rootItem )
h.Name = h.getElement( rootItem, 'name', 'char' );
h.OperatingSystemName = h.getElement( rootItem, 'operatingsystemname', 'char' );
h.GetMissingPackagesFcn = h.getElement( rootItem, 'getmissingpackagesfcn', 'char' );
h.RemovePackagesFcn = h.getElement( rootItem, 'removepackagesfcn', 'char' );
h.BuildHostDeviceAddress = h.getElement( rootItem, 'buildhostdeviceaddress', 'char' );
h.BuildHostUsername = h.getElement( rootItem, 'buildhostusername', 'char' );
h.BuildHostPassword = h.getElement( rootItem, 'buildhostpassword', 'char' );
h.SourceFolder = h.getElement( rootItem, 'sourcefolder', 'char' );
h.OutputFolder = h.getElement( rootItem, 'outputfolder', 'char' );
h.BuildArgs = h.getElement( rootItem, 'buildargs', 'cell' );
h.BuildCmdFormat = h.getElement( rootItem, 'buildcmdformat', 'char' );
h.BuildCmd = h.getElement( rootItem, 'buildcmd', 'char' );
h.PrebuildFcn = h.getElement( rootItem, 'prebuildfcn', 'char' );
h.PostbuildFcn = h.getElement( rootItem, 'postbuildfcn', 'char' );
h.ImageFiles = h.getElement( rootItem, 'imagefiles', 'cell' );
h.InstallCmd = h.getElement( rootItem, 'installcmd', 'char' );
h.InstallCmdArgs = h.getElement( rootItem, 'installcmdargs', 'cell' );
h.InstallCmdType = h.getElement( rootItem, 'installcmdtype', 'char' );
h.deserializefeaturepackageinfo( rootItem );
end 
function deserialize( h )
parser = matlab.io.xml.dom.Parser;
xDoc = parser.parseFile( h.DefinitionFileName );
prodInfoList = xDoc.getElementsByTagName( 'productinfo' );
rootItem = prodInfoList.item( 0 );
prodInfo = struct;
if rootItem.hasAttributes
prodInfo.( char( rootItem.getAttributes.item( 0 ).getName ) ) = char( rootItem.getAttributes.item( 0 ).getValue );
end 
if ~isfield( prodInfo, 'version' )
prodInfo = struct( 'version', '1.0' );%#ok<NASGU>
end 
h.deserializeCurrent( rootItem );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmptPoowe.p.
% Please follow local copyright laws when handling this file.

