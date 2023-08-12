function isSystemBlock = is_matlab_system_block( block )



block = get_param( block, 'Object' );
if ~iscell( block )
block = { block };
end 

numBlks = numel( block );
isSystemBlock = false( numBlks, 1 );

for i = 1:numBlks
if isa( block{ i }, 'Simulink.MATLABSystem' )
isSystemBlock( i ) = strcmpi( block{ i }.BlockType, 'MATLABSystem' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwvewly.p.
% Please follow local copyright laws when handling this file.

