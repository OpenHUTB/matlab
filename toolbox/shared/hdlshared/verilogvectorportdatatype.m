function newvtype = verilogvectorportdatatype( complexity, isvector, vtype, sltype )





if length( isvector ) == 1 || isvector( 2 ) == 0 || isvector( 1 ) == 1 || isvector( 2 ) == 1
veclen = max( isvector );
if veclen == 0
error( message( 'HDLShared:directemit:zerolenvector' ) );
end 

newvtype = vtype;
else 
error( message( 'HDLShared:directemit:matrixunsupported' ) );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpmYesdi.p.
% Please follow local copyright laws when handling this file.

