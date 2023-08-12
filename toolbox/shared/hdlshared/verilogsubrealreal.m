function [ hdlbody, hdlsignals ] = verilogsubrealreal( in1, in2, out, rounding, saturation )







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
error( message( 'HDLShared:directemit:realwithnonreal' ) );
end 
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
hdlbody = [ '  ', assign_prefix, outname, ' ', assign_op, ' ', name1, ' - ', name2, ';\n\n' ];

resourceLog( 0, 0, 'sub' );
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:nonrealwithreal' ) );
end 
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
hdlbody = [ '  ', assign_prefix, outname, ' ', assign_op, ' ', name1, ' - ', name2, ';\n\n' ];

resourceLog( 0, 0, 'sub' );
elseif ( size1 == 1 ) || ( size2 == 1 ) || ( outsize == 1 ), 
[ hdlbody, hdlsignals ] = hdlonebitaddsub( in1, in2, out, rounding, saturation, { '', '-' }, false );

else 




in1need_signext = false;
in2need_signext = false;
if bp1 > bp2
size2 = size2 + ( bp1 - bp2 );
bp2 = bp1;
in2need_signext = true;
elseif bp1 < bp2
size1 = size1 + ( bp2 - bp1 );
bp1 = bp2;
in1need_signext = true;
end 

sumbp = bp1;

[ sevtype, sesltype ] = hdlgettypesfromsizes( max( size1, size2 ), sumbp, resultsigned );
if true
[ tempse1, tempse1_ptr ] = hdlnewsignal( 'sub_signext', 'block',  - 1, 0, 0, sevtype, sesltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempse1_ptr ) ];
hdlbody = [ hdlbody, hdldatatypeassignment( in1, tempse1_ptr, 'floor', 0, [  ], 'real' ) ];
if strcmp( hdlbody( end  - 3:end  ), '\n\n' )
hdlbody = hdlbody( 1:end  - 2 );
end 
else 
tempse1 = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
end 

if true
[ tempse2, tempse2_ptr ] = hdlnewsignal( 'sub_signext', 'block',  - 1, 0, 0, sevtype, sesltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempse2_ptr ) ];
hdlbody = [ hdlbody, hdldatatypeassignment( in2, tempse2_ptr, 'floor', 0, [  ], 'real' ) ];
if strcmp( hdlbody( end  - 3:end  ), '\n\n' )
hdlbody = hdlbody( 1:end  - 2 );
end 
else 
tempse2 = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
end 

sumsize = 1 + max( size1, size2 );
[ tempvtype, tempsltype ] = hdlgettypesfromsizes( sumsize, sumbp, resultsigned );

if outsize == sumsize && outbp == sumbp && outsigned == resultsigned
hdlbody = [ hdlbody, '  ', assign_prefix, outname, ' ', assign_op, ' ',  ...
tempse1, ' - ', tempse2, ';\n\n' ];
else 


[ tempsum, tempsum_ptr ] = hdlnewsignal( 'sub_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempsum_ptr ) ];

hdlbody = [ hdlbody, '  ', assign_prefix, tempsum, ' ', assign_op, ' ',  ...
tempse1, ' - ', tempse2, ';\n' ];






hdlbody = [ hdlbody, hdldatatypeassignment( tempsum_ptr, out, rounding, saturation, [  ], 'real' ) ];

resourceLog( sumsize, sumsize, 'sub' );
end 

end 


if ~( ( hdlwordsize( sltype1 ) == 1 ) || ( hdlwordsize( sltype2 ) == 1 ) || ( hdlwordsize( outsltype ) == 1 ) ), 
if hdlconnectivity.genConnectivity, 
hConnDir = hdlconnectivity.getConnectivityDirector;

if exist( 'tempsum_ptr' ) == 1, 
rcvr = tempsum_ptr;
else 
rcvr = out;
end 

if exist( 'tempse1_ptr' ) == 1, 
drvr1 = tempse1_ptr;
else 
drvr1 = in1;
end 

if exist( 'tempse2_ptr' ) == 1, 
drvr2 = tempse2_ptr;
else 
drvr2 = in2;
end 


hConnDir.addDriverReceiverPair( drvr1, rcvr, 'realonly', true );
hConnDir.addDriverReceiverPair( drvr2, rcvr, 'realonly', true );
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpI9wTr5.p.
% Please follow local copyright laws when handling this file.

