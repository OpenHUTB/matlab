function valid = validateModelParam( mdl, allowSubSystem )




valid = true;

isModelName = false;
isSubSystemName = false;
if ischar( mdl )
mdlExistsValue = exist( mdl, 'file' );
if mdlExistsValue == 4


isModelName = true;
elseif mdlExistsValue == 0

if allowSubSystem

blockHandle = getSimulinkBlockHandle( mdl );
if blockHandle ~=  - 1 || Simulink.ID.isValid( mdl )
isSubSystemName = strcmp ...
( get_param( mdl, 'BlockType' ), 'SubSystem' );
end 
end 
else 

DAStudio.error( 'Simulink:Engine:ModelDoesNotExist', mdl )
end 
end 

if ~( isModelName || isSubSystemName ) && ~locIsModelOrLibraryHandle( mdl, allowSubSystem )
valid = false;
end 


function isMdlH = locIsModelOrLibraryHandle( hdl, allowSubSystem )


isMdlH = false;
if is_simulink_handle( hdl )
type = get_param( hdl, 'Type' );
switch type
case 'block_diagram'
bdType = get_param( hdl, 'BlockDiagramType' );
if strcmpi( bdType, 'model' ) ||  ...
strcmpi( bdType, 'library' ) || strcmpi( bdType, 'subsystem' )
isMdlH = true;
end 
case 'block'
if allowSubSystem
bdType = get_param( hdl, 'BlockType' );
if strcmpi( bdType, 'SubSystem' )
isMdlH = true;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpevJazF.p.
% Please follow local copyright laws when handling this file.

