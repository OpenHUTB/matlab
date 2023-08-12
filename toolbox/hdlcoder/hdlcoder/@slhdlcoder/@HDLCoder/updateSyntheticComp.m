function updateSyntheticComp( ~, hC )









slbh = hC.SimulinkHandle;
if slbh ~=  - 1
if ~ishandle( slbh )
parent = hC.Owner;
name = [ parent.FullPath, '/', hC.Name ];
if parent.isBusExpansionSubsystem
hC.SimulinkHandle = getHandleFromBusExpansionSubsystem( parent, hC );
else 
try 
newslbh = get_param( name, 'handle' );
catch me



if strcmp( me.identifier, 'Simulink:Commands:InvSimulinkObjectName' ) ...
 && ( isprop( hC, 'BlockTag' ) && strcmp( hC.BlockTag, 'built-in/Ground' ) )
newslbh =  - 1;



elseif strcmp( me.identifier, 'Simulink:Commands:InvSimulinkObjectName' ) ...
 && hC.isNetworkInstance && hC.ReferenceNetwork.isBusExpansionSubsystem
error( message( 'hdlcoder:validate:VirtualBusError', parent.Name ) );
else 
me.rethrow;
end 
end 
hC.SimulinkHandle = newslbh;
end 
end 
end 
end 

function retslbh = getHandleFromBusExpansionSubsystem( parent, hC )
retslbh =  - 1;
parentHan = get_param( parent.FullPath, 'handle' );
pslbh = slInternal( 'busDiagnostics', 'handleToExpandedSubsystem', parentHan );

if isempty( pslbh )

pslbh = getHandleForBusElementPorts( parent );
end 
blockList = getCompiledBlockList( get_param( pslbh, 'ObjectAPI_FP' ) );
for ii = 1:numel( blockList )
if strcmp( get_param( blockList( ii ), 'Name' ), hC.Name )
retslbh = blockList( ii );
break ;
end 
end 
end 






function pslbh = getHandleForBusElementPorts( parent )
pslbh = [  ];
parentHan = get_param( parent.FullPath, 'handle' );
obj = get_param( parentHan, 'Object' );
if obj.isSynthesized
origBlock = obj.getOriginalBlock;
origBlkType = get_param( origBlock, 'BlockType' );
if strcmpi( origBlkType, 'SubrefProxy' )
pslbh = parentHan;
parent.SimulinkHandle = parentHan;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxX6xaA.p.
% Please follow local copyright laws when handling this file.

