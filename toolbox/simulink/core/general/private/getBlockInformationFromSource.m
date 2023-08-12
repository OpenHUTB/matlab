
function [ parent, blockFullName, dlgSrc, searchLoc ] = getBlockInformationFromSource( dlgSrc, propertyName )







parent = '';
blockFullName = '';
searchLoc = 'startUnderMask';
try 
if isa( dlgSrc, 'DAStudio.Dialog' )
tempSrc = dlgSrc.getSource;



if isa( tempSrc, 'Simulink.LinePropertiesDDGSource' )
dlgSrc = dlgSrc.getWidgetSource( propertyName );
else 
dlgSrc = tempSrc;
end 
elseif isa( dlgSrc, 'Simulink.Port' )


blkName = dlgSrc.parent;
blkHandle = getSimulinkBlockHandle( blkName );
portSrc = get( blkHandle, 'Object' );
parent = portSrc.getParent;
blockFullName = portSrc.getFullName;
if ( dlgSrc.Line ~=  - 1 )
tempSrc = get_param( dlgSrc.Line, 'Object' );
dlgSrc = tempSrc.getLine;
end 
return ;
elseif isa( dlgSrc, 'Simulink.Line' )

portObj = dlgSrc.getSourcePort;
blkName = portObj.parent;
blkHandle = getSimulinkBlockHandle( blkName );
portSrc = get( blkHandle, 'Object' );
parent = portSrc.getParent;
blockFullName = portSrc.getFullName;
return ;
end 

if isa( dlgSrc, 'Simulink.SLDialogSource' )

[ parent, blockFullName, dlgSrc, searchLoc ] = l_BlockInfoHelper( dlgSrc );

elseif isa( dlgSrc, 'Simulink.Port' )

blkName = dlgSrc.parent;
blkHandle = getSimulinkBlockHandle( blkName );
portSrc = get( blkHandle, 'Object' );
parent = portSrc.getParent;
blockFullName = parent.getFullName;
else 
if ~isempty( dlgSrc.getDialogSource ) && isa( dlgSrc.getDialogSource, 'Simulink.SLDialogSource' )
dlgSrc = dlgSrc.getDialogSource;
[ parent, blockFullName, dlgSrc, searchLoc ] = l_BlockInfoHelper( dlgSrc );
else 
parent = dlgSrc.getParent;
blockFullName = parent.getFullName;
end 
end 
catch E %#ok
parent = '';
blockFullName = '';
searchLoc = '';
end 
end 

function [ parent, blockFullName, dlgSrc, searchLoc ] = l_BlockInfoHelper( dlgSrc )
searchLoc = 'startUnderMask';
block = dlgSrc.getBlock;
blockFullName = block.getFullName;

blkHandle = get_param( blockFullName, 'Handle' );
if isempty( blkHandle )
parent = '';
blockFullName = '';
searchLoc = '';
else 
parent = get_param( get_param( block.Handle, 'Parent' ), 'Object' );
if strcmp( get_param( dlgSrc, 'Mask' ), 'on' )
if ~isequal( get_param( dlgSrc, 'MaskNames' ), dlgSrc.getDialogParams )
maskSource = block.getDialogSource( 'intrinsic' );
if isequal( maskSource, dlgSrc )

searchLoc = 'startUnderMask';
else 

searchLoc = '';
end 
else 

searchLoc = 'startAboveMask';
end 
end 

dlgSrc = block;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp9NoOxO.p.
% Please follow local copyright laws when handling this file.

