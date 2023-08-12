function [ hdlbody, hdlsignals ] = vhdladdrealreal( in1, in2, out, rounding, saturation )








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
















if signed1 == 0 && signed2 == 0
resultsigned = 0;
else 
resultsigned = 1;
end 

if size1 == 0
if size2 ~= 0
error( message( 'HDLShared:directemit:invalidinputs' ) );
end 


hdlbody = [ '  ', outname, ' <= ', name1, ' + ', name2, ';\n\n' ];


resourceLog( 0, 0, 'add' );
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:invalidinputs' ) );
end 

hdlbody = [ '  ', outname, ' <= ', name1, ' + ', name2, ';\n\n' ];
elseif ( size1 == 1 ) || ( size2 == 1 ) || ( outsize == 1 ), 
[ hdlbody, hdlsignals ] = hdlonebitaddsub( in1, in2, out, rounding, saturation, { '', '+' }, false );


resourceLog( 0, 0, 'add' );

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

sumbp = bp1;
sumsize = 1 + max( size1, size2 );

[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );

name1 = [ 'resize(', name1, ', ', num2str( sumsize ), ')' ];
size1 = sumsize;
name2 = [ 'resize(', name2, ', ', num2str( sumsize ), ')' ];
size2 = sumsize;

[ tempvtype, tempsltype ] = hdlgettypesfromsizes( sumsize, sumbp, resultsigned );

if outsize == sumsize && outbp == sumbp && outsigned == resultsigned
hdlbody = [ hdlbody, '  ', outname, ' <= ', name1, ' + ', name2, ';\n\n' ];
else 

[ tempsum, tempsum_ptr ] = hdlnewsignal( 'add_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempsum_ptr ) ];

hdlbody = [ hdlbody, '  ', tempsum, ' <= ', name1, ' + ', name2, ';\n' ];

hdlbody = [ hdlbody, hdldatatypeassignment( tempsum_ptr, out, rounding, saturation, [  ], 'real' ) ];







end 


resourceLog( sumsize, sumsize, 'add' );
end 



if ~( ( hdlwordsize( sltype1 ) == 1 ) || ( hdlwordsize( sltype2 ) == 1 ) || ( hdlwordsize( outsltype ) == 1 ) ), 
if hdlconnectivity.genConnectivity, 
hConnDir = hdlconnectivity.getConnectivityDirector;

if exist( 'tempsum_ptr' ) == 1, 
rcvr = tempsum_ptr;
else 
rcvr = out;
end 

hConnDir.addDriverReceiverPair( in1, rcvr, 'realonly', true );
hConnDir.addDriverReceiverPair( in2, rcvr, 'realonly', true );
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpOj5iwA.p.
% Please follow local copyright laws when handling this file.

