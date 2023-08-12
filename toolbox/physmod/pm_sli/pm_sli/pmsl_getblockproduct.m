function [ product, errorStruct ] = pmsl_getblockproduct( obj )


















narginchk( 1, 1 );

product = '';
[ entry, errorStruct ] = pmsl_getblocklibraryentry( obj );

if ~isempty( entry )
product = entry.Product;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp1tYTat.p.
% Please follow local copyright laws when handling this file.

