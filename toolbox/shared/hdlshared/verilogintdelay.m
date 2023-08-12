function [ hdlbody, hdlsignals ] = verilogintdelay( in, out, processName, numdelays, scalarIC )








if ( length( in ) ~= length( out ) ) || ( length( in ) ~= length( numdelays ) )
error( message( 'HDLShared:directemit:samedim' ) );
end 

hdlsignals = '';


if nargin < 5 || isempty( scalarIC )
scalarIC = 0;
end 


gConnOld = hdlconnectivity.genConnectivity( 0 );



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
reset_asserted_level = hdlgetparameter( 'reset_asserted_level' );
comment_char = hdlgetparameter( 'comment_char' );


if async_reset == 1 && ~isempty( creset )
if reset_asserted_level == 1
resetedge = 'posedge ';
else 
resetedge = 'negedge ';
end 

if hdlgetparameter( 'clockedge' ) == 0
sensList = [ 'always @( posedge ', clockname,  ...
' or ', resetedge, resetname, ')\n' ];
else 
sensList = [ 'always @( negedge ', clockname,  ...
' or ', resetedge, resetname, ')\n' ];
end 



asyncIf = [ 'if (', resetname, ' == 1''b',  ...
num2str( reset_asserted_level ), ') begin\n' ];

asyncElsif = 'else begin\n';

else 
if hdlgetparameter( 'clockedge' ) == 0
sensList = [ 'always @( posedge ', clockname, ')\n' ];
else 
sensList = [ 'always @( negedge ', clockname, ')\n' ];
end 

asyncIf = [ 'if (', resetname, ' == 1''b',  ...
num2str( reset_asserted_level ), ') begin\n' ];


asyncElsif = 'else begin\n';
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
iscplx = hdlsignaliscomplex( inp );

outsltype = hdlsignalsltype( op );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );




newverilogtype = hdlsignalvtype( op );

if ( vector == 0 )

[ tempnames, ptr ] = hdlnewsignal( 'int_delay_pipe',  ...
'block',  - 1, cplx, [ 1, dly ], newverilogtype, sltype );
hdlregsignal( ptr );
hdlsignals = [ hdlsignals, makehdlsignaldecl( ptr ) ];
if ( iscplx )
tempstore = tempnames{ 1 };
tempstore_im = tempnames{ 2 };

out_ptr = ptr( 1 );
out_ptr_im = ptr( 2 );
else 
tempstore = tempnames;
out_ptr = ptr;
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
'block',  - 1, cplx, [ 1, dly ], newverilogtype, sltype );
hdlregsignal( ptr );
if ( iscplx )
tempstore{ k } = tempnames{ 1 };
tempstore_im{ k } = tempnames{ 2 };

out_ptr{ k } = ptr( 1 );
out_ptr_im{ k } = ptr( 2 );

else 
tempstore{ k } = tempnames;
out_ptr{ k } = ptr;
end 


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

hdlsignals = [ hdlsignals, makehdlsignaldecl( ptr ) ];
end 
end 

if ~strcmp( sltype, 'double' ) && ( outsize > 1 ) && all( scalarIC == 0 )
ICstr = '0';
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

asyncbody = scalarAsyncBody( tempstore, dly, ICstr );
name = hdlsafeinput( inp, outsltype );
syncbody = scalarSyncBody( name, tempstore, dly );
if ( iscplx )
asyncbody = [ asyncbody, scalarAsyncBody( tempstore_im, dly, ICstr ) ];
name_im = hdlsafeinput( hdlsignalimag( inp ), outsltype );
syncbody = [ syncbody, scalarSyncBody( name_im, tempstore_im, dly ) ];
end 
else 

asyncbody = scalarAsyncBody( tempstore{ 1 }, dly, ICstr );
name = hdlsafeinput( inp, outsltype, '0' );
syncbody = scalarSyncBody( name, tempstore{ 1 }, dly );
if ( iscplx )
asyncbody = [ asyncbody, scalarAsyncBody( tempstore_im{ 1 },  ...
dly, ICstr ) ];
name_im = hdlsafeinput( hdlsignalimag( inp ), outsltype, '0' );
syncbody = [ syncbody, scalarSyncBody( name_im,  ...
tempstore_im{ 1 }, dly ) ];
end 
for k = 2:vectsize, 
asyncbody = [ asyncbody, scalarAsyncBody( tempstore{ k },  ...
dly, ICstr ) ];
name = hdlsafeinput( inp, outsltype, num2str( k - 1 ) );
syncbody = [ syncbody, scalarSyncBody( name, tempstore{ k },  ...
dly ) ];
if ( iscplx )
asyncbody = [ asyncbody,  ...
scalarAsyncBody( tempstore_im{ k }, dly, ICstr ) ];
name_im = hdlsafeinput( hdlsignalimag( inp ),  ...
outsltype, num2str( k - 1 ) );
syncbody = [ syncbody, scalarSyncBody( name_im,  ...
tempstore_im{ k }, dly ) ];
end 
end 
end 


asynccode = [ asynccode, asyncbody ];
synccode = [ synccode, syncbody ];


if ( vector == 0 )

if ( dly > 1 )
tmpstr = hdlsignalassignment( out_ptr, op, dly - 1, [  ], [  ] );
else 
tmpstr = hdlsignalassignment( out_ptr, op );
end 
tmpstr = strrep( tmpstr, '\n\n', '\n' );
opcode = [ opcode, tmpstr ];
if ( iscplx )
if ( dly > 1 )
tmpstr = hdlsignalassignment( out_ptr_im, hdlsignalimag( op ),  ...
dly - 1, [  ], [  ] );
else 
tmpstr = hdlsignalassignment( out_ptr_im, hdlsignalimag( op ) );
end 
tmpstr = strrep( tmpstr, '\n\n', '\n' );
opcode = [ opcode, tmpstr ];
end 
else 

for k = 1:vectsize
tmpstr = hdlsignalassignment( out_ptr{ k }, op, dly - 1, k - 1, [  ] );
tmpstr = strrep( tmpstr, '\n\n', '\n' );
opcode = [ opcode, tmpstr ];
if ( iscplx )
tmpstr = hdlsignalassignment( out_ptr_im{ k },  ...
hdlsignalimag( op ), dly - 1, k - 1, [  ] );
tmpstr = strrep( tmpstr, '\n\n', '\n' );
opcode = [ opcode, tmpstr ];
end 
end 
end 
end 


if isempty( creset )
hdlbody = [ blanks( 2 ), sensList,  ...
blanks( 4 ), 'begin: ', processName, '\n',  ...
blanks( 6 ), [ 'if (', clockenablename, ' == 1''b1) begin\n' ],  ...
synccode,  ...
blanks( 6 ), 'end\n',  ...
blanks( 4 ), 'end ', comment_char, ' ', processName, '\n\n' ];
else 
hdlbody = [ blanks( 2 ), sensList,  ...
blanks( 4 ), 'begin: ', processName, '\n',  ...
blanks( 6 ), asyncIf,  ...
asynccode,  ...
blanks( 6 ), 'end\n',  ...
blanks( 6 ), asyncElsif,  ...
blanks( 8 ), [ 'if (', clockenablename, ' == 1''b1) begin\n' ],  ...
synccode,  ...
blanks( 8 ), 'end\n',  ...
blanks( 6 ), 'end\n',  ...
blanks( 4 ), 'end ', comment_char, ' ', processName, '\n\n' ];
end 


hdlbody = [ hdlbody, opcode, '\n' ];


hdlsequentialcontext( false );



hdlconnectivity.genConnectivity( gConnOld );




function asyncbody = scalarAsyncBody( outname, numdelays, ICstr )

asyncbody = '';
if ( numdelays > 1 )
for n = 0:numdelays - 1
idxstr = [ '[', num2str( n ), ']' ];
asyncbody = [ asyncbody, blanks( 8 ), outname, idxstr, ' <= ', ICstr, ';\n' ];
end 
elseif ( numdelays == 1 )
asyncbody = [ asyncbody, blanks( 8 ), outname, ' <= ', ICstr, ';\n' ];
end 

function syncbody = scalarSyncBody( name, outname, numdelays )
syncbody = '';
if ( numdelays > 1 )
syncbody = [ blanks( 8 ), outname, '[0]', ' <= ', name, ';\n' ];
for n = 1:numdelays - 1
syncbody = [ syncbody, blanks( 8 ), outname, '[', num2str( n ), ']',  ...
' <= ', outname, '[', num2str( n - 1 ), ']', ';\n' ];
end 
elseif ( numdelays == 1 )
syncbody = [ blanks( 8 ), outname, ' <= ', name, ';\n' ];
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpQvN1w8.p.
% Please follow local copyright laws when handling this file.

