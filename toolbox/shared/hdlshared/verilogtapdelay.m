function [ hdlbody, hdlsignals ] = verilogtapdelay( in, out, processName, numdelays, delayorder, scalarIC )








hdlsignals = '';

name = hdlsignalname( in );
vtype = hdlsignalvtype( in );
sltype = hdlsignalsltype( in );
cplx = hdlsignalcomplex( in );
[ size, ~, signed ] = hdlwordsize( sltype );

outname = hdlsignalname( out );
outsltype = hdlsignalsltype( out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );


gConnOld = hdlconnectivity.genConnectivity( 0 );

if numdelays == 1
[ hdlbody, hdlsignals ] = hdlunitdelay( in, out, processName, scalarIC );
else 
hdlsequentialcontext( true );
hdlregsignal( out );

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

if ( cplx )
name_im = hdlsignalname( hdlsignalimag( in ) );
outname_im = hdlsignalname( hdlsignalimag( out ) );
end 


if ~strcmp( sltype, 'double' ) && ( scalarIC == 0 ) && ( outsize > 1 )
ICstr = '0';
else 
ICstr = hdlconstantvalue( scalarIC, outsize, outbp, outsigned );
end 


if hdlgetparameter( 'async_reset' ) == 1
if hdlgetparameter( 'reset_asserted_level' ) == 1
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
int2str( hdlgetparameter( 'reset_asserted_level' ) ), ') begin\n' ];

asyncElsif = 'else begin\n';

else 
if hdlgetparameter( 'clockedge' ) == 0
sensList = [ 'always @( posedge ', clockname, ')\n' ];
else 
sensList = [ 'always @( negedge ', clockname, ')\n' ];
end 

asyncIf = [ 'if (', resetname, ' == 1''b',  ...
int2str( hdlgetparameter( 'reset_asserted_level' ) ), ') begin\n' ];


asyncElsif = 'else begin\n';
end 


asyncbody = scalarAsyncBody( outname, numdelays, ICstr, 8 );
[ name, size ] = hdlsignaltypeconvert( name, size, signed, vtype, outsigned );
syncbody = scalarSyncBody( name, outname, numdelays, delayorder, 10 );
if ( cplx )
asyncbody = [ asyncbody, blanks( 6 ), scalarAsyncBody( outname_im, numdelays, ICstr, 8 ) ];
[ name_im, ~ ] = hdlsignaltypeconvert( name_im, size, signed, vtype, outsigned );
syncbody = [ syncbody, blanks( 8 ), scalarSyncBody( name_im, outname_im, numdelays, delayorder, 10 ) ];
end 


hdlbody = [ blanks( 2 ), sensList,  ...
blanks( 4 ), 'begin: ', processName, '\n',  ...
blanks( 6 ), asyncIf,  ...
asyncbody,  ...
blanks( 6 ), 'end\n',  ...
blanks( 6 ), asyncElsif,  ...
blanks( 8 ), [ 'if (', clockenablename, ' == 1''b1) begin\n' ],  ...
syncbody,  ...
blanks( 8 ), 'end\n',  ...
blanks( 6 ), 'end\n',  ...
blanks( 4 ), 'end ', hdlgetparameter( 'comment_char' ), ' ', processName, '\n\n\n' ];%#ok<I18N_Concatenated_Msg>

hdlsequentialcontext( false );
end 

if gConnOld
hCD = hdlconnectivity.getConnectivityDirector;
regout = out;


if numdelays > 1, 
if strcmpi( delayorder, 'Newest' ), 

outInd = ( 1:numdelays - 1 );
inInd = ( 0:numdelays - 2 );
out1Ind = 0;
else 

outInd = ( 0:numdelays - 2 );
inInd = ( 1:numdelays - 1 );
out1Ind = numdelays - 1;
end 
else 
out1Ind = [  ];
end 



hCD.addRegister( in, regout, hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'unroll', false, 'realonly', false,  ...
'inIndices', [  ], 'outIndices', out1Ind );

if numdelays > 1, 

hCD.addRegister( regout, regout, hdlgetcurrentclock, hdlgetcurrentclockenable,  ...
'unroll', false, 'realonly', false,  ...
'inIndices', inInd, 'outIndices', outInd );
end 
end 


hdlconnectivity.genConnectivity( gConnOld );



function asyncbody = scalarAsyncBody( outname, numdelays, ICstr, indent )
asyncbody = '';
for n = 0:numdelays - 1
idxstr = [ '[', int2str( n ), ']' ];
asyncbody = [ asyncbody, blanks( indent ), outname, idxstr, ' <= ', ICstr, ';\n' ];%#ok<AGROW>
end 

function syncbody = scalarSyncBody( name, outname, numdelays, delayorder, indent )
syncbody = '';
if strcmp( delayorder, 'Newest' )
syncbody = [ blanks( indent ), outname, '[0]', ' <= ', name, ';\n' ];
for n = 1:numdelays - 1
syncbody = [ syncbody, blanks( indent ), outname, '[', int2str( n ), ']',  ...
' <= ', outname, '[', int2str( n - 1 ), ']', ';\n' ];%#ok<AGROW>
end 
else 
for n = 0:numdelays - 2
syncbody = [ syncbody, blanks( indent ), outname, '[', int2str( n ), ']',  ...
' <= ', outname, '[', int2str( n + 1 ), ']', ';\n' ];%#ok<AGROW>
end 

syncbody = [ syncbody, blanks( indent ), outname, '[', int2str( numdelays - 1 ), ']', ' <= ', name, ';\n' ];
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpn0ybFt.p.
% Please follow local copyright laws when handling this file.

