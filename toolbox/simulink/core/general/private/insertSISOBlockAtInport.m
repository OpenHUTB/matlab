function action_performed = insertSISOBlockAtInport( blockType, blockName, inputPortNum, destBlockHandle )
destBlockPosition = get_param( destBlockHandle, 'Position' );
destBlockOrientation = get_param( destBlockHandle, 'Orientation' );

switch destBlockOrientation
case 'right'
newBlockPosition = destBlockPosition + [  - 15, 0,  - 15, 0 ];
newBlockPosition( 1 ) = newBlockPosition( 3 ) - 20;
ymid = ( destBlockPosition( 2 ) + destBlockPosition( 4 ) ) / 2;
newBlockPosition( 2 ) = ymid - 10;
newBlockPosition( 4 ) = ymid + 10;
destBlockPosition = destBlockPosition + [ 35, 0, 35, 0 ];
case 'down'
newBlockPosition = destBlockPosition + [ 0,  - 15, 0,  - 15 ];
newBlockPosition( 2 ) = newBlockPosition( 4 ) - 20;
xmid = ( destBlockPosition( 1 ) + destBlockPosition( 3 ) ) / 2;
newBlockPosition( 1 ) = xmid - 10;
newBlockPosition( 3 ) = xmid + 10;
destBlockPosition = destBlockPosition + [ 0, 35, 0, 35 ];
case 'left'
newBlockPosition = destBlockPosition + [ 15, 0, 15, 0 ];
newBlockPosition( 3 ) = newBlockPosition( 1 ) + 20;
ymid = ( destBlockPosition( 2 ) + destBlockPosition( 4 ) ) / 2;
newBlockPosition( 2 ) = ymid - 10;
newBlockPosition( 4 ) = ymid + 10;
destBlockPosition = destBlockPosition + [  - 35, 0,  - 35, 0 ];
case 'up'
newBlockPosition = destBlockPosition + [ 0, 15, 0, 15 ];
newBlockPosition( 4 ) = newBlockPosition( 2 ) + 20;
xmid = ( destBlockPosition( 1 ) + destBlockPosition( 3 ) ) / 2;
newBlockPosition( 1 ) = xmid - 10;
newBlockPosition( 3 ) = xmid + 10;
destBlockPosition = destBlockPosition + [ 0,  - 35, 0,  - 35 ];
end 

parentSystem = get_param( destBlockHandle, 'Parent' );

destBlockPortHandles = get_param( destBlockHandle, 'PortHandles' );
destBlockInputPortHandle = destBlockPortHandles.Inport( inputPortNum );
destBlockLineHandles = get_param( destBlockHandle, 'LineHandles' );
destBlockInputPortLineHandle = destBlockLineHandles.Inport( inputPortNum );

if destBlockInputPortLineHandle ~=  - 1
srcBlockOutputPortHandle = get_param( destBlockInputPortLineHandle, 'SrcPortHandle' );
srcBlockPath = get_param( srcBlockOutputPortHandle, 'Parent' );
srcBlockName = get_param( srcBlockPath, 'Name' );
srcBlockType = get_param( srcBlockPath, 'BlockType' );
splitBlockType = strsplit( blockType, '/' );
if strcmpi( srcBlockType, splitBlockType{ length( splitBlockType ) } ) && strfind( srcBlockName, blockName ) == 1
action_performed = DAStudio.message(  ...
'Simulink:SampleTime:NotInsertedSISOBlockAtInport',  ...
get_param( blockType, 'BlockType' ), getfullname( destBlockHandle ) );
return ;
end 

srcBlockOutputPortSignalInfo = struct(  );
srcBlockOutputPortSignalInfo.Label = get_param( srcBlockOutputPortHandle,  ...
'SignalNameFromLabel' );
srcBlockOutputPortSignalInfo.SigObj = get_param( srcBlockOutputPortHandle,  ...
'SignalObject' );
srcBlockOutputPortSignalInfo.ResolveStatus = get_param( srcBlockOutputPortHandle,  ...
'MustResolveToSignalObject' );
delete_line( destBlockInputPortLineHandle );
end 

set_param( destBlockHandle, 'Position', destBlockPosition );
newBlockHandle = add_block( blockType, [ parentSystem, '/', blockName ],  ...
'MakeNameUnique', 'on',  ...
'Position', newBlockPosition,  ...
'Orientation', destBlockOrientation );
newBlockPortHandles = get_param( newBlockHandle, 'PortHandles' );
newBlockInputPortHandle = newBlockPortHandles.Inport( 1 );
newBlockOutputPortHandle = newBlockPortHandles.Outport( 1 );

if destBlockInputPortLineHandle ~=  - 1
set_param( newBlockOutputPortHandle,  ...
'SignalNameFromLabel', srcBlockOutputPortSignalInfo.Label );
set_param( newBlockOutputPortHandle,  ...
'SignalObject', srcBlockOutputPortSignalInfo.SigObj );
set_param( newBlockOutputPortHandle,  ...
'MustResolveToSignalObject', srcBlockOutputPortSignalInfo.ResolveStatus );

add_line( parentSystem, srcBlockOutputPortHandle, newBlockInputPortHandle,  ...
'autorouting', 'smart' );
end 

add_line( parentSystem, newBlockOutputPortHandle, destBlockInputPortHandle );
action_performed =  ...
DAStudio.message( 'Simulink:SampleTime:InsertedSISOBlockAtInport',  ...
get_param( blockType, 'BlockType' ),  ...
getfullname( newBlockHandle ), getfullname( destBlockHandle ) );
return ;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdJYTQH.p.
% Please follow local copyright laws when handling this file.

