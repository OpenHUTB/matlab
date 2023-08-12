function hdlbody = verilogsetorextractbits( in, out, bitindex, bitvalstr )








name = hdlsignalname( in );
sltype = hdlsignalsltype( in );
vtype = hdlsignalvtype( in );
outname = hdlsignalname( out );
outsltype = hdlsignalsltype( out );
outvector = hdlsignalvector( out );
[ size, bp, signed ] = hdlwordsize( sltype );

[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );

isinport = hdlisinportsignal( in );



if nargin == 4

if outvector == 0

hdlbody = [ set_clear_bit( out, name, sltype, size, outname,  ...
outsltype, isinport, bitindex, bitvalstr, 2 ), '\n' ];
else 

hdlbody = '';

vecsize = max( outvector( : ) );

for k = 0:vecsize - 1
hdlbody = [ hdlbody, set_clear_bit( out, [ name, '[', num2str( k ), ']' ], sltype, size,  ...
[ outname, '[', num2str( k ), ']' ], outsltype, isinport, bitindex, bitvalstr, 2 ) ];
end 

hdlbody = [ hdlbody, '\n' ];

end 

end 




function hdlbody = set_clear_bit( out, name, sltype, size, outname,  ...
outsltype, isinport, bitindex, bitvalstr, nspaces )

[ assign_prefix, assign_op ] = hdlassignforoutput( out );

index = str2num( bitindex );

if index == 0

idxstr = [ '[', int2str( size - 1 ), ' : 1]' ];
hdlbody = [ blanks( nspaces ), assign_prefix, outname, idxstr, assign_op,  ...
safename( [ name, idxstr ], sltype, outsltype, isinport ), ';\n' ];
hdlbody = [ hdlbody, blanks( nspaces ), assign_prefix, outname, '[0]', assign_op,  ...
bitvalstr, ';\n' ];

elseif ( index == ( size - 1 ) )

idxstr = [ '[', int2str( size - 2 ), ' : 0]' ];
hdlbody = [ blanks( nspaces ), assign_prefix, outname, '[', int2str( size - 1 ), ']', assign_op,  ...
bitvalstr, ';\n' ];
hdlbody = [ hdlbody, blanks( nspaces ), assign_prefix, outname, idxstr, assign_op,  ...
safename( [ name, idxstr ], sltype, outsltype, isinport ), ';\n' ];

else 



if index == ( size - 2 )
idxstr1 = [ '[', int2str( size - 1 ), ']' ];

hdlbody = [ blanks( nspaces ), assign_prefix, outname, idxstr1, assign_op, [ name, idxstr1 ], ';\n' ];
else 
idxstr1 = [ '[', int2str( size - 1 ), ' : ', int2str( index + 1 ), ']' ];
hdlbody = [ blanks( nspaces ), assign_prefix, outname, idxstr1, assign_op,  ...
safename( [ name, idxstr1 ], sltype, outsltype, isinport ), ';\n' ];
end 


idxstr = [ '[', int2str( index ), ']' ];
hdlbody = [ hdlbody, blanks( nspaces ), assign_prefix, outname, idxstr, assign_op,  ...
bitvalstr, ';\n' ];


if index == 1
idxstr2 = [ '[', int2str( 0 ), ']' ];

hdlbody = [ hdlbody, blanks( nspaces ), assign_prefix, outname, idxstr2, assign_op, [ name, idxstr2 ], ';\n' ];
else 
idxstr2 = [ '[', int2str( index - 1 ), ' : 0]' ];
hdlbody = [ hdlbody, blanks( nspaces ), assign_prefix, outname, idxstr2, assign_op,  ...
safename( [ name, idxstr2 ], sltype, outsltype, isinport ), ';\n' ];
end 

end 


function name = safename( name, sltype, outsltype, isinport )

[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
[ size, bp, signed ] = hdlwordsize( sltype );

if size > 1
if isinport
[ name, size ] = hdlsignaltypeconvert( name, size, signed,  ...
verilogportdatatype( sltype ), outsigned );
else 
[ name, size ] = hdlsignaltypeconvert( name, size, signed,  ...
verilogblockdatatype( sltype ), outsigned );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKB3s54.p.
% Please follow local copyright laws when handling this file.

