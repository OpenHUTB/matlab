function [ hdlbody, hdlsignals ] =  ...
vhdlsubsubrealrealbittrue( in1, in2, out, rounding, saturation )












[ in1, in2, hdlsignals, hdlbody ] =  ...
hdlsignedtounsigned_dtc( in1, in2, out, rounding, saturation );

name1 = hdlsignalname( in1 );
vtype1 = hdlsignalvtype( in1 );
sltype1 = hdlsignalsltype( in1 );
[ size1, bp1, signed1 ] = hdlwordsize( sltype1 );

name2 = hdlsignalname( in2 );
vtype2 = hdlsignalvtype( in2 );
sltype2 = hdlsignalsltype( in2 );
[ size2, bp2, signed2 ] = hdlwordsize( sltype2 );

outname = hdlsignalname( out );
outvtype = hdlsignalvtype( out );
outsltype = hdlsignalsltype( out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
























resultsigned = 1;

if size1 == 0
if size2 ~= 0
error( message( 'HDLShared:directemit:realmath' ) );
end 
hdlbody = [ '  ', outname, ' <= -', name1, ' - ', name2, ';\n\n' ];
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:realmath' ) );
end 
hdlbody = [ '  ', outname, ' <= -', name1, ' - ', name2, ';\n\n' ];
elseif ( size1 == 1 ) || ( size2 == 1 ) || ( outsize == 1 ), 

[ hdlbody, hdlsignals ] = hdlonebitaddsub( in1, in2, out, rounding, saturation, { '-', '-' }, true );

else 


if bp1 > bp2
name2 = [ name2, ' & ', vhdlnzeros( bp1 - bp2 ) ];
size2 = size2 + ( bp1 - bp2 );
bp2 = bp1;
elseif bp1 < bp2
name1 = [ name1, ' & ', vhdlnzeros( bp2 - bp1 ) ];
size1 = size1 + ( bp2 - bp1 );
bp1 = bp2;
end 

sumbp = outbp;
sumsize = outsize + 1;



if signed1 == 0 && signed2 == 0
sumsize = sumsize + 1;
size1 = size1 + 1;
size2 = size2 + 1;
end 

name1 = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
name2 = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );

name1 = [ 'resize(', name1, ', ', num2str( sumsize ), ')' ];
size1 = sumsize;
name2 = [ 'resize(', name2, ', ', num2str( sumsize ), ')' ];
size2 = sumsize;

[ tempvtype, tempsltype ] = hdlgettypesfromsizes( sumsize, sumbp, resultsigned );


[ tempsum1, tempsum1_ptr ] = hdlnewsignal( 'add_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );
[ tempsum2, tempsum2_ptr ] = hdlnewsignal( 'add_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );
[ tempsum3, tempsum3_ptr ] = hdlnewsignal( 'add_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );

hdlsignals = [ hdlsignals, makehdlsignaldecl( tempsum1_ptr ) ];
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempsum2_ptr ) ];
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempsum3_ptr ) ];























hdlbody = [ hdlbody, hdldatatypeassignment( in1, tempsum1_ptr, rounding, saturation, [  ], 'real' ) ];
hdlbody = [ hdlbody, hdldatatypeassignment( in2, tempsum2_ptr, rounding, saturation, [  ], 'real' ) ];
hdlbody = [ hdlbody, '  ', tempsum3, ' <= -', tempsum1, ' - ', tempsum2, ';\n' ];
hdlbody = [ hdlbody, hdldatatypeassignment( tempsum3_ptr, out, rounding, saturation, [  ], 'real' ) ];











end 




if ( ( hdlwordsize( sltype1 ) == 0 ) || ( hdlwordsize( sltype2 ) == 0 ) ), 
if hdlconnectivity.genConnectivity, 
hConnDir = hdlconnectivity.getConnectivityDirector;
hConnDir.addDriverReceiverPair( in1, out, 'realonly', true );
hConnDir.addDriverReceiverPair( in2, out, 'realonly', true );
end 
elseif ~( ( hdlwordsize( sltype1 ) == 1 ) || ( hdlwordsize( sltype2 ) == 1 ) || ( hdlwordsize( outsltype ) == 1 ) ), 
if hdlconnectivity.genConnectivity, 
hConnDir = hdlconnectivity.getConnectivityDirector;
hConnDir.addDriverReceiverPair( tempsum1_ptr, tempsum3_ptr, 'realonly', true );
hConnDir.addDriverReceiverPair( tempsum2_ptr, tempsum3_ptr, 'realonly', true );
end 

end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpoQr4Jy.p.
% Please follow local copyright laws when handling this file.

