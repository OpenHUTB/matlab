function setHDLUserData( ~, hC, hdldata )












if nargin < 3 || isempty( hC )
error( message( 'hdlcoder:validate:invalidhdlargs' ) );
end 

if strcmp( hC.ClassName, 'block_comp' )
return ;
end 

if ~strcmp( hC.ClassName, 'black_box_comp' )
error( message( 'hdlcoder:validate:invalidcomp' ) );
end 

hC.HDLUserData = hdldata;



% Decoded using De-pcode utility v1.2 from file /tmp/tmpIYxK5t.p.
% Please follow local copyright laws when handling this file.

