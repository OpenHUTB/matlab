function vtype = verilogportdatatype( dt )






bdt = hdlgetparameter( 'base_data_type' );

switch dt
case 'single'
if ~isTargetFloatingPointMode(  )
warning( message( 'HDLShared:directemit:singletodouble' ) );
end 
vtype = 'real';
case 'double'
vtype = [ bdt, ' [63:0]' ];
case 'boolean'
vtype = bdt;
otherwise 
vtype = [ bdt, veriloggetvtype( dt ) ];
end 
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpv73llq.p.
% Please follow local copyright laws when handling this file.

