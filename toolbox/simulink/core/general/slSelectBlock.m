function slSelectBlock( blk )






parent = get_param( blk, 'Parent' );
selected = find_system( parent, 'SearchDepth', 1, 'findall', 'on', 'Selected', 'on' );
for i = 1:length( selected )
set_param( selected( i ), 'Selected', 'off' );
end 
set_param( blk, 'Selected', 'on' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZu5Bim.p.
% Please follow local copyright laws when handling this file.

