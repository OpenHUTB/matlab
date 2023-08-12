function rootLevelBlock = findRootLevelParentSubsystemBlock( block )



R36
block( 1, 1 )coder.descriptor.GraphicalBlock
end 
rootLevelBlock = block;
while ~strcmp( rootLevelBlock.Container.SubsystemType, 'root' )
rootLevelBlock = rootLevelBlock.Container.SubsystemBlock;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpbYtUSS.p.
% Please follow local copyright laws when handling this file.

