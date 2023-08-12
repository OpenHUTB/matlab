

function s = loc_int2str( x )
s = cell( length( x ), 1 );
for i = 1:length( x )
str = int2str( x( i ) );
n = length( str );
new_str = '';
while n > 3
new_str = [ ',', str( end  - 2:end  ), new_str ];%#ok
str = str( 1:end  - 3 );
n = length( str );
end 
if n > 0
new_str = [ str, new_str ];%#ok
end 
s{ i } = new_str;
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphZg3sd.p.
% Please follow local copyright laws when handling this file.

