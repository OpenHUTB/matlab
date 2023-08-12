function [ hdlbody, hdlsignals ] = vhdlsubsubrealreal( in1, in2, out, rounding, saturation )








hdlbody = '';
hdlsignals = '';


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


realonly = true;

















if signed1 == 0 && signed2 == 0
resultsigned = 0;
else 
resultsigned = 1;
end 

if size1 == 0
if size2 ~= 0
error( message( 'HDLShared:directemit:invalidinputs' ) );
end 
hdlbody = [ '  ', outname, ' <= -', name1, ' - ', name2, ';\n\n' ];
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:invalidinputs' ) );
end 
hdlbody = [ '  ', outname, ' <= -', name1, ' - ', name2, ';\n\n' ];
elseif ( size1 == 1 ) || ( size2 == 1 ) || ( outsize == 1 ), 
[ hdlbody, hdlsignals ] = hdlonebitaddsub( in1, in2, out, rounding, saturation, { '-', '-' }, false );

else 

[ tempunary, tempunary_ptr ] = hdlnewsignal( 'subsub_temp', 'block',  - 1, 0, 0, outvtype, outsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempunary_ptr ) ];

[ tempbody, tempsigs ] = hdlunaryminus( in1, tempunary_ptr, rounding, saturation, realonly );
hdlsignals = [ hdlsignals, tempsigs ];
hdlbody = [ hdlbody, tempbody ];

[ tempbody, tempsigs ] = hdlsub( tempunary_ptr, in2, out, rounding, saturation, realonly );
hdlsignals = [ hdlsignals, tempsigs ];
hdlbody = [ hdlbody, tempbody ];

end 



if ( ( hdlwordsize( sltype1 ) == 0 ) || ( hdlwordsize( sltype2 ) == 0 ) ), 
if hdlconnectivity.genConnectivity, 
hConnDir = hdlconnectivity.getConnectivityDirector;


hConnDir.addDriverReceiverPair( in1, out, 'realonly', true );
hConnDir.addDriverReceiverPair( in2, out, 'realonly', true );
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpw07Azw.p.
% Please follow local copyright laws when handling this file.

