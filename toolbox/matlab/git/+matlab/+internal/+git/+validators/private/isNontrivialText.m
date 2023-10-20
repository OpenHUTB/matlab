function tf = isNontrivialText( value )



%#codegen



if ~( ischar( value ) && ( isrow( value ) || isequal( value, '' ) ) ) && ~isstring( value ) && ~iscellstr( value )
tf = false;
return ;
end 


if iscell( value )

for i = 1:numel( value )
if strlength( value{ i } ) <= 0
tf = false;
return ;
end 
end 
else 

tf = ( strlength( value ) > 0 );
return ;
end 

tf = true;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp37RmCQ.p.
% Please follow local copyright laws when handling this file.

