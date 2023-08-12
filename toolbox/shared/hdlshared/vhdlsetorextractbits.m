function hdlbody = vhdlsetorextractbits( in, out, bitindex, bitvalstr )








singlequote = char( 39 );

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

hdlbody = [ set_clear_bit( name, sltype, size, outname,  ...
outsltype, isinport, bitindex, bitvalstr, 2 ), '\n' ];
else 

vecsize = max( outvector( : ) );

genname = [ outname( 1:strfind( outname, '_out' ) - 1 ), hdlgetparameter( 'block_generate_label' ) ];
hdlbody = [ blanks( 2 ), genname, ' : ', 'FOR k IN 0 TO ', num2str( vecsize - 1 ), ' GENERATE\n' ];
hdlbody = [ hdlbody, set_clear_bit( [ name, '(k)' ], sltype, size,  ...
[ outname, '(k)' ], outsltype, isinport, bitindex, bitvalstr, 4 ) ];
hdlbody = [ hdlbody, blanks( 2 ), 'END GENERATE;\n\n' ];

end 

end 




function hdlbody = set_clear_bit( name, sltype, size, outname,  ...
outsltype, isinport, bitindex, bitvalstr, nspaces )

singlequote = char( 39 );

index = str2num( bitindex );
if index == 0

idxstr = [ '(', int2str( size - 1 ), ' DOWNTO 1)' ];
hdlbody = [ blanks( nspaces ), outname, idxstr, ' <= ',  ...
safename( [ name, idxstr ], sltype, outsltype, isinport ), ';\n' ];
hdlbody = [ hdlbody, blanks( nspaces ), outname, '(0)', ' <= ', singlequote,  ...
bitvalstr, singlequote, ';\n' ];

elseif ( index == ( size - 1 ) )

idxstr = [ '(', int2str( size - 2 ), ' DOWNTO 0)' ];
hdlbody = [ blanks( nspaces ), outname, '(', int2str( size - 1 ), ')', ' <= ',  ...
singlequote, bitvalstr, singlequote, ';\n' ];
hdlbody = [ hdlbody, blanks( nspaces ), outname, idxstr, ' <= ',  ...
safename( [ name, idxstr ], sltype, outsltype, isinport ), ';\n' ];

else 



if index == ( size - 2 )
idxstr1 = [ '(', int2str( size - 1 ), ')' ];

hdlbody = [ blanks( nspaces ), outname, idxstr1, ' <= ', [ name, idxstr1 ], ';\n' ];
else 
idxstr1 = [ '(', int2str( size - 1 ), ' DOWNTO ', int2str( index + 1 ), ')' ];
hdlbody = [ blanks( nspaces ), outname, idxstr1, ' <= ',  ...
safename( [ name, idxstr1 ], sltype, outsltype, isinport ), ';\n' ];
end 


idxstr = [ '(', int2str( index ), ')' ];
hdlbody = [ hdlbody, blanks( nspaces ), outname, idxstr, ' <= ',  ...
singlequote, bitvalstr, singlequote, ';\n' ];


if index == 1
idxstr2 = [ '(', int2str( 0 ), ')' ];

hdlbody = [ hdlbody, blanks( nspaces ), outname, idxstr2, ' <= ', [ name, idxstr2 ], ';\n' ];
else 
idxstr2 = [ '(', int2str( index - 1 ), ' DOWNTO 0', ')' ];
hdlbody = [ hdlbody, blanks( nspaces ), outname, idxstr2, ' <= ',  ...
safename( [ name, idxstr2 ], sltype, outsltype, isinport ), ';\n' ];
end 

end 


function name = safename( name, sltype, outsltype, isinport )

[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
[ size, bp, signed ] = hdlwordsize( sltype );

if size > 1
if isinport
[ name, size ] = hdlsignaltypeconvert( name, size, signed,  ...
vhdlportdatatype( sltype ), outsigned );
else 
[ name, size ] = hdlsignaltypeconvert( name, size, signed,  ...
vhdlblockdatatype( sltype ), outsigned );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpP1zIxN.p.
% Please follow local copyright laws when handling this file.

