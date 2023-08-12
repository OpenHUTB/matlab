function out = simrfV2vector2str( in, outformat )




if nargin < 2
outformat = '%20.16g, ';
else 
outformat = [ outformat, ', ' ];
end 


in( in == 0 ) = 0;
if length( in ) > 1
out = sprintf( outformat, in );
out = [ '[', out( 1:end  - 2 ), ']' ];
else 
out = sprintf( '%20.16g', in );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmptGaB7K.p.
% Please follow local copyright laws when handling this file.

