function rootLevelBlock = findRootLevelParentSubsystemBlock( block )

arguments
block( 1, 1 )coder.descriptor.GraphicalBlock
end 
rootLevelBlock = block;
while ~strcmp( rootLevelBlock.Container.SubsystemType, 'root' )
rootLevelBlock = rootLevelBlock.Container.SubsystemBlock;
end 
end 


