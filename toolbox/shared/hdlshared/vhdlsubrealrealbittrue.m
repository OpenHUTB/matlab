function [ hdlbody, hdlsignals ] = vhdlsubrealrealbittrue( in1, in2, out, rounding, saturation )












[ in1, in2, hdlsignals, hdlbody ] =  ...
hdlsignedtounsigned_dtc( in1, in2, out, rounding, saturation );

[ assign_prefix, assign_op ] = hdlassignforoutput( out );

name1 = hdlsignalname( in1 );
vtype1 = hdlsignalvtype( in1 );
sltype1 = hdlsignalsltype( in1 );
[ size1, bp1, signed1 ] = hdlwordsize( sltype1 );

name2 = hdlsignalname( in2 );
vtype2 = hdlsignalvtype( in2 );
sltype2 = hdlsignalsltype( in2 );
[ size2, bp2, signed2 ] = hdlwordsize( sltype2 );

outname = hdlsignalname( out );
outsltype = hdlsignalsltype( out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );

















if signed1 == 0 && signed2 == 0 && saturation == 0
resultsigned = 0;
else 

resultsigned = 1;
end 

if size1 == 0
if size2 ~= 0
error( message( 'HDLShared:directemit:invalidinputs' ) );
end 
hdlbody = [ '  ', outname, ' <= ', name1, ' - ', name2, ';\n\n' ];

resourceLog( 0, 0, 'sub' );
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:invalidinputs' ) );
end 
hdlbody = [ '  ', outname, ' <= ', name1, ' - ', name2, ';\n\n' ];

resourceLog( 0, 0, 'sub' );
elseif ( size1 == 1 ) || ( size2 == 1 ) || ( outsize == 1 ), 

[ hdlbody, hdlsignals ] = hdlonebitaddsub( in1, in2, out, rounding, saturation, { '', '-' }, true );

else 
if signed1 == 0 && signed2 == 0 && saturation == 1
castsize = outsize + 1;
else 
castsize = outsize;
end 

[ castvtype, castsltype ] = hdlgettypesfromsizes( castsize, outbp, resultsigned );

[ tempse1, tempse1_ptr ] = hdlnewsignal( 'sub_cast', 'block',  - 1, 0, 0, castvtype, castsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempse1_ptr ) ];
hdlbody = [ hdlbody, hdldatatypeassignment( in1, tempse1_ptr, rounding, saturation, [  ], 'real' ) ];
if strcmp( hdlbody( end  - 3:end  ), '\n\n' )
hdlbody = hdlbody( 1:end  - 2 );
end 

[ tempse2, tempse2_ptr ] = hdlnewsignal( 'sub_cast', 'block',  - 1, 0, 0, castvtype, castsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempse2_ptr ) ];
hdlbody = [ hdlbody, hdldatatypeassignment( in2, tempse2_ptr, rounding, saturation, [  ], 'real' ) ];
if strcmp( hdlbody( end  - 3:end  ), '\n\n' )
hdlbody = hdlbody( 1:end  - 2 );
end 


sumsize = 1 + outsize;
if signed1 == 0 && signed2 == 0 && saturation == 1
sumsize = sumsize + 1;
end 
sumbp = outbp;
[ sumvtype, sumsltype ] = hdlgettypesfromsizes( sumsize, sumbp, resultsigned );


[ tempsum, tempsum_ptr ] = hdlnewsignal( 'sub_temp', 'block',  - 1, 0, 0, sumvtype, sumsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempsum_ptr ) ];

hdlbody = [ hdlbody, '  ', assign_prefix, tempsum, ' ', assign_op, ' ',  ...
'resize(', tempse1, ', ', num2str( sumsize ), ')',  ...
' - ',  ...
'resize(', tempse2, ', ', num2str( sumsize ), ')', ';\n' ];

hdlbody = [ hdlbody, hdldatatypeassignment( tempsum_ptr, out, rounding, saturation, [  ], 'real' ) ];


resourceLog( sumsize, sumsize, 'sub' );

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






% Decoded using De-pcode utility v1.2 from file /tmp/tmpnG8csd.p.
% Please follow local copyright laws when handling this file.

