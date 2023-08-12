function isSFBasedBlock = is_stateflow_based_block( block )



block = get_param( block, 'Object' );
if ~iscell( block )
block = { block };
end 

numBlks = numel( block );
isSFBasedBlock = false( numBlks, 1 );

for i = 1:numBlks
if isa( block{ i }, 'Simulink.SubSystem' )
isSFBasedBlock( i ) = ~strcmpi( block{ i }.SFBlockType, 'NONE' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4GvFt7.p.
% Please follow local copyright laws when handling this file.

