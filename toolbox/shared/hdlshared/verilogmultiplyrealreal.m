function [ hdlbody, hdlsignals ] = verilogmultiplyrealreal( in1, in2, out, rounding, saturation )







hdlbody = '';
hdlsignals = '';

[ assign_prefix, assign_op ] = hdlassignforoutput( out );
comment_char = hdlgetparameter( 'comment_char' );

name1 = hdlsignalname( in1 );
handle1 = hdlsignalhandle( in1 );
vector1 = hdlsignalvector( in1 );
vtype1 = hdlsignalvtype( in1 );
sltype1 = hdlsignalsltype( in1 );
[ size1, bp1, signed1 ] = hdlwordsize( sltype1 );

name2 = hdlsignalname( in2 );
handle2 = hdlsignalhandle( in2 );
vector2 = hdlsignalvector( in2 );
vtype2 = hdlsignalvtype( in2 );
sltype2 = hdlsignalsltype( in2 );
[ size2, bp2, signed2 ] = hdlwordsize( sltype2 );

outname = hdlsignalname( out );
outhandle = hdlsignalhandle( out );
outvector = hdlsignalvector( out );
outvtype = hdlsignalvtype( out );
outsltype = hdlsignalsltype( out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
















if signed1 == 0 && signed2 == 0
resultsigned = 0;
else 
resultsigned = 1;
end 

if size1 == 0
if size2 ~= 0
error( message( 'HDLShared:directemit:multrealwithnonreal' ) );
end 
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
hdlbody = [ '  ', assign_prefix, outname, ' ', assign_op, ' ', name1, ' * ', name2, ';\n\n' ];
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:multrealwithnonreal' ) );
end 
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
hdlbody = [ '  ', assign_prefix, outname, ' ', assign_op, ' ', name1, ' * ', name2, ';\n\n' ];



























else 
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );

prodsize = size1 + size2;
prodbp = bp1 + bp2;

if ( size1 == 1 && size2 ~= 1 ) || ( size1 ~= 1 ) && ( size2 == 1 )
prodsize = max( size1, size2 );
end 

if prodsize ~= outsize || prodbp ~= outbp || resultsigned ~= outsigned
[ tempvtype, tempsltype ] = hdlgettypesfromsizes( prodsize, prodbp, resultsigned );

[ tempprod, tempprod_ptr ] = hdlnewsignal( 'mul_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempprod_ptr ) ];

hdlbody = [ hdlbody, '  ', assign_prefix, tempprod, ' ', assign_op, ' ', name1, ' * ', name2, ';\n' ];

hdlbody = [ hdlbody, hdldatatypeassignment( tempprod_ptr, out, rounding, saturation ) ];
if strcmp( hdlbody( end  - 3:end  ), '\n\n' )
hdlbody = hdlbody( 1:end  - 2 );
end 

else 
hdlbody = [ hdlbody, '  ', assign_prefix, outname, ' ', assign_op, ' ', name1, ' * ', name2, ';\n' ];
end 

hdlbody = [ hdlbody, '\n' ];

end 



if hdlconnectivity.genConnectivity, 
hConnDir = hdlconnectivity.getConnectivityDirector;

if exist( 'tempprod_ptr' ) == 1, 
rcvr = tempprod_ptr;
else 
rcvr = out;
end 

hConnDir.addDriverReceiverPair( in1, rcvr, 'realonly', true );
hConnDir.addDriverReceiverPair( in2, rcvr, 'realonly', true );
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpIz0OwN.p.
% Please follow local copyright laws when handling this file.

