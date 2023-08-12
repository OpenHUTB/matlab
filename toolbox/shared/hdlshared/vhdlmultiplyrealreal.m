function [ hdlbody, hdlsignals ] = vhdlmultiplyrealreal( in1, in2, out, rounding, saturation )








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
error( message( 'HDLShared:directemit:realnonrealmult' ) );
end 
hdlbody = [ '  ', outname, ' <= ', name1, ' * ', name2, ';\n\n' ];
elseif size2 == 0
if size1 ~= 0
error( message( 'HDLShared:directemit:realnonrealmult' ) );
end 
hdlbody = [ '  ', outname, ' <= ', name1, ' * ', name2, ';\n\n' ];
else 

zeroresult = '(OTHERS => ''0'')';
if ( size1 == 1 )
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
prodsize = size2;
if ( size2 == 1 )
zeroresult = '''0''';
end 
elseif ( size2 == 1 )
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
prodsize = size1;
else 
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );
prodsize = size1 + size2;
end 
prodbp = bp1 + bp2;

if ( prodsize ~= outsize || prodbp ~= outbp || resultsigned ~= outsigned )

[ tempvtype, tempsltype ] = hdlgettypesfromsizes( prodsize, prodbp, resultsigned );
[ tempname, tempprod_ptr ] = hdlnewsignal( 'mul_temp', 'block',  - 1, 0, 0, tempvtype, tempsltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( tempprod_ptr ) ];
else 
tempprod_ptr = out;
tempname = outname;
end 


if size1 == 1
if size2 == 1
zeroresult = '''0''';
else 
zeroresult = '(OTHERS => ''0'')';
end 
hdlbody = [ '  ', tempname, ' <= ', name2, ' WHEN ', name1, ' = ''1''',  ...
' ELSE ', zeroresult, ';\n\n' ];
elseif size2 == 1
hdlbody = [ '  ', tempname, ' <= ', name1, ' WHEN ', name2, ' = ''1''',  ...
' ELSE ', zeroresult, ';\n\n' ];

else 
hdlbody = [ hdlbody, '  ', tempname, ' <= ', name1, ' * ', name2, ';\n' ];
end 

if ( prodsize ~= outsize || prodbp ~= outbp || resultsigned ~= outsigned )

if outsize == 1
[ name1, size1 ] = hdlsignaltypeconvert( name1, size1, signed1, vtype1, resultsigned );
[ name2, size2 ] = hdlsignaltypeconvert( name2, size2, signed2, vtype2, resultsigned );

hdlbody = [ hdlbody, hdldatatypeassignment( tempprod_ptr, out, rounding, saturation ) ];


else 
hdlbody = [ hdlbody, hdldatatypeassignment( tempprod_ptr, out, rounding, saturation ) ];
end 
if strcmp( hdlbody( end  - 3:end  ), '\n\n' )
hdlbody = hdlbody( 1:end  - 2 );
end 
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







% Decoded using De-pcode utility v1.2 from file /tmp/tmpF_4D83.p.
% Please follow local copyright laws when handling this file.

