function newvtype = verilogvectorblockdatatype( ~, isvector, vtype, ~ )



if length( isvector ) == 1 || isvector( 2 ) == 0 || isvector( 1 ) == 1 || isvector( 2 ) == 1
newvtype = vtype;
else 
newvtype = [ 'Verilog vtype array of ', vtype ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0_kskF.p.
% Please follow local copyright laws when handling this file.

