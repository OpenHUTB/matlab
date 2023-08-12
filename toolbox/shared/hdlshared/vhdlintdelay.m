function [ hdlbody, hdlsignals ] = vhdlintdelay( in, out, processName, numdelays, scalarIC )








if ( length( in ) ~= length( out ) ) || ( length( in ) ~= length( numdelays ) )
error( message( 'HDLShared:directemit:samedim' ) );
end 



gConnOld = hdlconnectivity.genConnectivity( 0 );


hdlsequentialcontext( true );


if nargin < 5 || isempty( scalarIC )
scalarIC = 0;
end 

hdlsignals = '';
singlequote = char( 39 );


cclk = hdlgetcurrentclock;
if isempty( cclk ) || cclk == 0
clockname = hdlgetparameter( 'clockname' );
else 
clockname = hdlsignalname( cclk );
end 

cclken = hdlgetcurrentclockenable;
if isempty( cclken )
clockenablename = '';
elseif cclken == 0
clockenablename = hdlgetparameter( 'clockenablename' );
else 
clockenablename = hdlsignalname( cclken );
end 

creset = hdlgetcurrentreset;
if isempty( creset )
resetname = '';
elseif creset == 0
resetname = hdlgetparameter( 'resetname' );
else 
resetname = hdlsignalname( creset );
end 


async_reset = hdlgetparameter( 'async_reset' );
clock_edge = hdlgetparameter( 'clockedge' ) == 0;
clockedgestyle = hdlgetparameter( 'clockedgestyle' );
reset_asserted_level = num2str( hdlgetparameter( 'reset_asserted_level' ) );


if async_reset == 1 && ~isempty( creset )
sensList = [ 'PROCESS (', clockname, ', ', resetname, ')\n' ];


asyncIfCond = [ resetname, ' = ''',  ...
reset_asserted_level, '''' ];

if ( clock_edge )
if ( clockedgestyle == 0 )
asyncElsifCond = [ clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1''' ];
else 
asyncElsifCond = [ 'rising_edge(', clockname, ')' ];
end 
else 
if ( clockedgestyle == 0 )
asyncElsifCond = [ clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0''' ];
else 
asyncElsifCond = [ 'falling_edge(', clockname, ')' ];
end 
end 
else 
sensList = [ 'PROCESS (', clockname, ')\n' ];

if ( clock_edge )
if ( clockedgestyle == 0 )
asyncIfCond = [ clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1''' ];
else 
asyncIfCond = [ 'rising_edge(', clockname, ')' ];
end 
else 
if ( clockedgestyle == 0 )
asyncIfCond = [ clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0''' ];
else 
asyncIfCond = [ 'falling_edge(', clockname, ')' ];
end 
end 


if ~isempty( creset )
asyncElsifCond = [ resetname, ' = ''',  ...
reset_asserted_level, '''' ];
end 
end 


asynccode = '';
synccode = '';
opcode = '';


for i = 1:length( in )

inp = in( i );
op = out( i );
dly = numdelays( i );

vector = hdlsignalvector( inp );
sltype = hdlsignalsltype( inp );
cplx = hdlsignalcomplex( inp );
[ size, bp, signed ] = hdlwordsize( sltype );%#ok

outname = hdlsignalname( op );
outsltype = hdlsignalsltype( op );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );

if ( cplx )
outname_im = hdlsignalname( hdlsignalimag( op ) );
end 



newvhdltype = vhdlvectorblockdatatype( cplx, [ dly, 0 ],  ...
hdlblockdatatype( outsltype ), outsltype );



if ( vector == 0 )

[ tempnames, ptr ] = hdlnewsignal( 'int_delay_pipe',  ...
'block',  - 1, cplx,  ...
[ dly, 0 ], newvhdltype, sltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( ptr ) ];
if ( cplx )
tempstore = tempnames{ 1 };
tempstore_im = tempnames{ 2 };
else 
tempstore = tempnames;
end 


if gConnOld, 
hConnDir = hdlconnectivity.getConnectivityDirector;
cExpPipe = hdlexpandvectorsignal( ptr );
for ii = 2:numel( cExpPipe ), 
hConnDir.addRegister( cExpPipe( ii - 1 ), cExpPipe( ii ),  ...
hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'realonly', false );
end 

hConnDir.addDriverReceiverPair( cExpPipe( end  ), op,  ...
'realonly', false );
hConnDir.addRegister( inp, cExpPipe( 1 ),  ...
hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'realonly', false );
end 


else 

vectsize = max( vector( : ) );
for k = 1:vectsize, 
[ tempnames, ptr ] = hdlnewsignal( 'int_delay_pipe',  ...
'block',  - 1, cplx,  ...
[ dly, 0 ], newvhdltype, sltype );
if ( cplx )
tempstore{ k } = tempnames{ 1 };
tempstore_im{ k } = tempnames{ 2 };
else 
tempstore{ k } = tempnames;
end 
hdlsignals = [ hdlsignals, makehdlsignaldecl( ptr ) ];


if gConnOld, 
hConnDir = hdlconnectivity.getConnectivityDirector;
cnExpIn = hdlexpandvectorsignal( inp );
cExpPipe = hdlexpandvectorsignal( ptr );
cnExpOut = hdlexpandvectorsignal( op );
for jj = 2:numel( cExpPipe ), 
hConnDir.addRegister( cExpPipe( jj - 1 ), cExpPipe( jj ),  ...
hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'realonly', false );
end 

hConnDir.addDriverReceiverPair( cExpPipe( end  ), cnExpOut( k ),  ...
'realonly', false );
hConnDir.addRegister( cnExpIn( k ), cExpPipe( 1 ),  ...
hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'realonly', false );
end 

end 

end 


if ~strcmp( sltype, 'double' ) && all( scalarIC == 0 ) && ( outsize > 1 )
ICstr = '(OTHERS => ''0'')';
elseif strcmp( sltype, 'double' ) && all( scalarIC == 0 )
ICstr = '0.0';
else 
vsize = max( vector );
if vsize > 1

if length( scalarIC ) > 1 && ~all( scalarIC == 0 )
warning( message( 'HDLShared:directemit:icignored' ) )
end 
ICstr = hdlconstantvalue( scalarIC( 1 ), outsize, outbp, outsigned );
else 
ICstr = hdlconstantvalue( scalarIC( 1 ), outsize, outbp, outsigned );
end 
end 

if vector == 0

asyncbody = [ blanks( 6 ), scalarAsyncBody( size, sltype,  ...
tempstore, dly, ICstr ) ];
name = hdlsafeinput( inp, outsltype );
syncbody = [ blanks( 8 ), scalarSyncBody( name, tempstore, dly ) ];
if ( cplx )
asyncbody = [ asyncbody, blanks( 6 ),  ...
scalarAsyncBody( size, sltype, tempstore_im, dly, ICstr ) ];
name_im = hdlsafeinput( hdlsignalimag( inp ), outsltype );
syncbody = [ syncbody, blanks( 8 ),  ...
scalarSyncBody( name_im, tempstore_im, dly ) ];
end 
else 

asyncbody = [ blanks( 6 ), scalarAsyncBody( size, sltype,  ...
tempstore{ 1 }, dly, ICstr ) ];
name = hdlsafeinput( inp, outsltype, '0' );
syncbody = [ blanks( 8 ), scalarSyncBody( name, tempstore{ 1 }, dly ) ];
if ( cplx )
asyncbody = [ asyncbody, blanks( 6 ),  ...
scalarAsyncBody( size, sltype, tempstore_im{ 1 }, dly, ICstr ) ];
name_im = hdlsafeinput( hdlsignalimag( inp ), outsltype, '0' );
syncbody = [ syncbody, blanks( 8 ),  ...
scalarSyncBody( name_im, tempstore_im{ 1 }, dly ) ];
end 
for k = 2:vectsize, 
asyncbody = [ asyncbody, blanks( 6 ),  ...
scalarAsyncBody( size, sltype, tempstore{ k }, dly, ICstr ) ];
name = hdlsafeinput( inp, outsltype, num2str( k - 1 ) );
syncbody = [ syncbody, blanks( 8 ),  ...
scalarSyncBody( name, tempstore{ k }, dly ) ];
if ( cplx )
asyncbody = [ asyncbody, blanks( 6 ),  ...
scalarAsyncBody( size, sltype, tempstore_im{ k }, dly, ICstr ) ];
name_im = hdlsafeinput( hdlsignalimag( inp ),  ...
outsltype, num2str( k - 1 ) );
syncbody = [ syncbody, blanks( 8 ),  ...
scalarSyncBody( name_im, tempstore_im{ k }, dly ) ];
end 
end 
end 


asynccode = [ asynccode, asyncbody ];
synccode = [ synccode, syncbody ];


outdelayidx = [ '(', num2str( dly - 1 ), ')' ];
if ( vector == 0 )

if ( dly > 1 )
opcode = [ opcode, blanks( 2 ), [ outname, ' <= ', tempstore,  ...
outdelayidx, ';\n' ] ];
else 
tmpstr = hdlsignalassignment( ptr( 1 ), op );
tmpstr = strrep( tmpstr, '\n\n', '\n' );
opcode = [ opcode, tmpstr ];
end 
if ( cplx )
if ( dly > 1 )
opcode = [ opcode, blanks( 2 ), [ outname_im, ' <= ',  ...
tempstore_im, outdelayidx, ';\n' ] ];
else 
tmpstr = hdlsignalassignment( ptr( 2 ), hdlsignalimag( op ) );
tmpstr = strrep( tmpstr, '\n\n', '\n' );
opcode = [ opcode, tmpstr ];
end 
end 
else 

opcode = [ opcode, vectorprocessoutput( outname,  ...
tempstore, vectsize, dly ), ');\n' ];
if ( cplx )
opcode = [ opcode, vectorprocessoutput( outname_im,  ...
tempstore_im, vectsize, dly ), ');\n' ];
end 
end 
end 


if async_reset == 1 && ~isempty( creset )
hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), 'IF ', asyncIfCond, ' THEN\n',  ...
asynccode,  ...
blanks( 4 ), 'ELSIF ', asyncElsifCond, ' THEN \n',  ...
blanks( 6 ), [ 'IF ', clockenablename, ' = ''1'' THEN\n' ],  ...
synccode,  ...
blanks( 6 ), 'END IF;\n',  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];
elseif isempty( creset )
hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), 'IF ', asyncIfCond, ' THEN\n',  ...
blanks( 6 ), [ 'IF ', clockenablename, ' = ''1'' THEN\n' ],  ...
synccode,  ...
blanks( 6 ), 'END IF;\n',  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];
else 

asynccode = strrep( asynccode, [ ';\n', blanks( 6 ) ], [ ';\n', blanks( 8 ) ] );
hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), 'IF ', asyncIfCond, ' THEN\n',  ...
blanks( 6 ), 'IF ', asyncElsifCond, ' THEN\n',  ...
blanks( 2 ), asynccode,  ...
blanks( 6 ), [ 'ELSIF ', clockenablename, ' = ''1'' THEN\n' ],  ...
blanks( 8 ), synccode,  ...
blanks( 6 ), 'END IF;\n',  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];
end 


hdlbody = [ hdlbody, opcode, '\n' ];

hdlsequentialcontext( false );


hdlconnectivity.genConnectivity( gConnOld );





function asyncbody = scalarAsyncBody( size, sltype, tempstore, numdelays, ICstr )
asyncbody = '';
if ( numdelays > 1 )
idxstr = [ '(0 TO ', num2str( numdelays - 1 ), ')' ];
asyncbody = [ tempstore, idxstr, ' <= (OTHERS => ', ICstr, ');\n' ];
elseif ( numdelays == 1 )
asyncbody = [ tempstore, ' <= ', ICstr, ';\n' ];
end 

function syncbody = scalarSyncBody( name, tempstore, numdelays )
syncbody = '';
if ( numdelays > 1 )
syncbody = [ tempstore, '(0)', ' <= ', name, ';\n' ];
if ( numdelays > 2 )
idxstr1 = [ '(1 TO ', num2str( numdelays - 1 ), ')' ];
idxstr2 = [ '(0 TO ', num2str( numdelays - 2 ), ')' ];
else 
idxstr1 = '(1)';
idxstr2 = '(0)';
end 
syncbody = [ syncbody, blanks( 8 ), tempstore, idxstr1, ' <= ',  ...
tempstore, idxstr2, ';\n' ];
elseif ( numdelays == 1 )
syncbody = [ tempstore, ' <= ', name, ';\n' ];
end 

function assignstr = vectorprocessoutput( outname, tempstore, vectsize, numdelays )
if ( numdelays > 1 )
outdelayidx = [ '(', num2str( numdelays - 1 ), ')' ];
else 
outdelayidx = '';
end 

assignstr = [ blanks( 2 ), outname, '(0 TO ', num2str( vectsize - 1 ), ')', ' <= ', '(' ];
for k = 1:vectsize - 1, 
assignstr = [ assignstr, tempstore{ k }, outdelayidx, ', ' ];
end 
assignstr = [ assignstr, tempstore{ vectsize }, outdelayidx ];



% Decoded using De-pcode utility v1.2 from file /tmp/tmpntmK2x.p.
% Please follow local copyright laws when handling this file.

