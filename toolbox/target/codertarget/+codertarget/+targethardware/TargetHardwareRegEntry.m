classdef ( Sealed = true )TargetHardwareRegEntry < codertarget.Info






properties ( Access = 'public' )
DefinitionFileName;
TargetName = '';
TargetFolder = '';
TargetType = 0;
Name = '';
DisplayName = '';
Aliases = {  };
HasMATLABPILInfo = false;
IsSoCCompatible = false;
BaseProductID
end 

properties ( Access = 'private' )
regRoot = fullfile( '$(TARGET_ROOT)', 'registry' );
end 

methods 
function h = TargetHardwareRegEntry( filePathName, targetName )
if ( nargin == 2 )
h.DefinitionFileName = filePathName;
h.TargetName = targetName;
end 
h.deserialize(  );

end 
function set.Aliases( h, val )
if isempty( val )
h.Aliases = {  };
elseif ischar( val ) || iscell( val ) || isstring( val )
h.Aliases = cellstr( val );
end 
end 
end 

methods ( Access = 'private' )
function deserialize( h )
docObj = h.read( h.DefinitionFileName );
isESBCompatible = 0;%#ok<NASGU>
prodInfoList = docObj.getElementsByTagName( 'productinfo' );
rootItem = prodInfoList.item( 0 );
h.Name = h.getElement( rootItem, 'name', 'char' );
displayName = h.getElement( rootItem, 'displayname', 'char' );
aliases = h.getElement( rootItem, 'alias', 'cell' );
if ~isempty( displayName )
h.DisplayName = displayName;
else 
h.DisplayName = h.Name;
end 
mpilNode = rootItem.getElementsByTagName( 'matlabpilinfo' );
h.HasMATLABPILInfo = mpilNode.getLength > 0;
isESBCompatible = h.getElement( rootItem, 'esbcompatible', 'numeric' );
h.IsSoCCompatible = isESBCompatible >= 1;
h.Aliases = aliases;
id = h.getElement( rootItem, 'baseproductid', 'numeric' );
if ~isempty( id ) && ~isequal( id, codertarget.targethardware.BaseProductID.UNSPECIFIED )
h.BaseProductID = codertarget.targethardware.BaseProductID( h.getElement( rootItem, 'baseproductid', 'numeric' ) );
else 
h.BaseProductID = codertarget.targethardware.BaseProductID.UNSPECIFIED;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpV7XPw2.p.
% Please follow local copyright laws when handling this file.

