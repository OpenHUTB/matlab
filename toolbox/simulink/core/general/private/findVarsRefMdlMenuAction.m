function [ ret1, ret2 ] = findVarsRefMdlMenuAction( blkObj, action )











assert( ischar( action ) );

if strcmp( action, 'checkVisible' )

ret1 = false;
ret2 = false;

if isa( blkObj, 'Simulink.Block' ) &&  ...
strcmp( blkObj.BlockType, 'ModelReference' )
ret1 = true;
isProtected = strcmp( blkObj.ProtectedModel, 'on' );
if ~isProtected
mdlName = blkObj.ModelName;
mdlFile = blkObj.ModelFile;
defaultMdlName = slInternal( 'getModelRefDefaultModelName' );
if ~strcmpi( mdlName, defaultMdlName ) && ~isempty( mdlFile )
ret2 = true;
end 
end 
end 
elseif strcmp( action, 'search' )

assert( isa( blkObj, 'Simulink.Block' ) &&  ...
strcmp( blkObj.BlockType, 'ModelReference' ) );
mdlName = blkObj.ModelName;
try 
open_system( mdlName )
catch 

ret1 = false;
ret2 = [  ];
return ;
end 

ret1 = true;
ret2 = get_param( mdlName, 'Object' );
else 

assert( false );
ret1 = false;
ret2 = [  ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpoZhIUI.p.
% Please follow local copyright laws when handling this file.

