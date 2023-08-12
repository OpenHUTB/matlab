function copySSContentsToBlockDiagramImpl( subsys, bd )















if nargin ~= 2
DAStudio.error( 'Simulink:modelReference:slSSCopyContentsToBDInvalidNumInputs' );
end 

subsys = convertStringsToChars( subsys );
bd = convertStringsToChars( bd );


try 
ssType = Simulink.SubsystemType( subsys );
isSubsys = ssType.isSubsystem && ~ssType.isStateflowSubsystem;
catch 
isSubsys = false;
end 

if ~isSubsys
DAStudio.error( 'Simulink:modelReference:slSSCopyContentsToBDIn1Invalid' );
end 



try 
isBd = strcmpi( get_param( bd, 'type' ), 'block_diagram' );
catch 
isBd = false;
end 

if ~isBd
DAStudio.error( 'Simulink:modelReference:slSSCopyContentsToBDIn2Invalid' );
end 


bdSimStatus = get_param( bd, 'SimulationStatus' );
if ~strcmpi( bdSimStatus, 'stopped' )
bdName = get_param( bd, 'name' );
DAStudio.error( 'Simulink:modelReference:slBadSimStatus', bdName, bdSimStatus );
end 




child_blocks = find_system( subsys, 'LookUnderMasks', 'on', 'SearchDepth', 1 );
for ii = 1:length( child_blocks )
blk = child_blocks( ii );
block_type = get_param( blk, 'BlockType' );
if strcmp( block_type, 'Outport' )
if ( strcmpi( get_param( blk, 'IsStateOwnerBlock' ), 'on' ) )
stateAccessorMap = get_param( bdroot( blk ), 'StateAccessorInfoMap' );
for i = 1:length( stateAccessorMap )
ownerBlkH = get_param( blk, 'Handle' );
if ( stateAccessorMap( i ).StateOwnerBlock == ownerBlkH )
DAStudio.error( 'Simulink:SubsystemReference:UnsupportedOutportBlockAsStateOwnerAtTopLevel',  ...
subsys,  ...
getfullname( blk ) );
end 
end 
end 
end 
end 


bdH = get_param( bd, 'handle' );
ssObj = get_param( subsys, 'object' );
ssObj.copyContentsToBD( bdH );

end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpjHnCQq.p.
% Please follow local copyright laws when handling this file.

