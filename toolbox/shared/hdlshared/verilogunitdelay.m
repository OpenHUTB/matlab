function [ hdlbody, hdlsignals ] = verilogunitdelay( in, out, processName, scalarIC, enable )















if nargin == 4
enable = '';
end 

hdlsequentialcontext( true );

hdlsignals = [  ];
numports = length( in );

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

if length( enable ) >= 1
enableCondition = [ '((', clockenablename, ' == 1''b1) &&' ];
for i = 1:length( enable ) - 1
enableName = hdlsignalname( enable( i ) );
enableCondition = [ enableCondition, '(', enableName, ' == 1''b1) &&' ];
end 
enableName = hdlsignalname( enable( length( enable ) ) );
enableCondition = [ enableCondition, '(', enableName, ' == 1''b1))' ];
else 
enableCondition = [ clockenablename, ' == 1''b1' ];
end 

creset = hdlgetcurrentreset;
if isempty( creset )
resetname = '';
elseif creset == 0
resetname = hdlgetparameter( 'resetname' );
else 
resetname = hdlsignalname( creset );
end 

if isempty( scalarIC )
scalarIC = zeros( 1, numports );
end 

if ( length( out ) ~= numports ) || ( numports > 1 && length( scalarIC ) ~= numports )
error( message( 'HDLShared:directemit:invalidlengthinputs' ) );
end 

if hdlgetparameter( 'reset_asserted_level' ) == 1
resetedge = 'posedge ';
else 
resetedge = 'negedge ';
end 


if hdlgetparameter( 'async_reset' ) == 1

if hdlgetparameter( 'clockedge' ) == 0
sensList = [ 'always @ (posedge ', clockname, ' or ',  ...
resetedge, resetname, ')\n' ];
else 
sensList = [ 'always @ (negedge ', clockname, ' or ',  ...
resetedge, resetname, ')\n' ];
end 

asyncIf = [ 'if (', resetname, ' == 1''b',  ...
num2str( hdlgetparameter( 'reset_asserted_level' ) ), ') begin\n' ];
asyncElsif = 'else begin\n';
reset_body_spaces = 8;

else 
if hdlgetparameter( 'clockedge' ) == 0
sensList = [ 'always @ ( posedge ', clockname, ')\n' ];
else 
sensList = [ 'always @ ( negedge ', clockname, ')\n' ];
end 

asyncIf = [ 'if (', resetname, ' == 1''b',  ...
num2str( hdlgetparameter( 'reset_asserted_level' ) ), ') begin\n' ];
asyncElsif = 'else begin\n';
reset_body_spaces = 8;
end 


asyncbody = [  ];
syncbody = [  ];

for k = 1:numports
sltype = hdlsignalsltype( in( k ) );
vector = hdlsignalvector( in( k ) );
cplx = hdlsignalcomplex( in( k ) );
outname = hdlsignalname( out( k ) );
outsltype = hdlsignalsltype( out( k ) );
[ size, bp, signed ] = hdlwordsize( sltype );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
if ~strcmp( sltype, 'double' ) && all( scalarIC( k ) == 0 ) && ( outsize > 1 )
ICstr = '0';
else 
vsize = max( vector );
if vsize > 1

if length( scalarIC ) > 1 && ~all( scalarIC == 0 )
warning( message( 'HDLShared:directemit:icignored' ) )
end 
ICstr = hdlconstantvalue( scalarIC( k ), outsize, outbp, outsigned );
else 
ICstr = hdlconstantvalue( scalarIC( k ), outsize, outbp, outsigned );
end 
end 

hdlregsignal( out( k ) );

if vector == 0
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( outname, ICstr ) ];
if ( cplx )
outname_im = hdlsignalname( hdlsignalimag( out( k ) ) );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( outname_im, ICstr ) ];
end 
tmpstr = [ blanks( reset_body_spaces ), hdlsignalassignment( in( k ), out( k ), [  ], [  ], [  ] ) ];
tmpstr = strrep( tmpstr, '\n\n', '\n' );
syncbody = [ syncbody, tmpstr ];
else 
for v = 0:max( vector ) - 1
asyncbody = [ asyncbody, blanks( reset_body_spaces ), vectorAsyncBody( outname, v, ICstr ) ];
if ( cplx )
outname_im = hdlsignalname( hdlsignalimag( out( k ) ) );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), vectorAsyncBody( outname_im, v, ICstr ) ];
end 
end 
tmpstr = [ blanks( reset_body_spaces ), hdlsignalassignment( in( k ), out( k ), [  ], [  ], [  ] ) ];
tmpstr = strrep( tmpstr, '\n\n', '\n' );
tmpstr = strrep( tmpstr, '\n  ', [ '\n', blanks( reset_body_spaces + 2 ) ] );
syncbody = [ syncbody, tmpstr ];
end 

end 


if isempty( clockenablename )
sync_statement = syncbody;
else 
sync_statement = [ blanks( 8 ), [ 'if (', enableCondition, ') begin\n' ],  ...
syncbody,  ...
blanks( 8 ), [ 'end\n' ] ];
end 

hdlbody = [ blanks( 2 ), sensList,  ...
blanks( 4 ), 'begin: ', processName, '\n',  ...
blanks( 6 ), asyncIf,  ...
asyncbody,  ...
blanks( 6 ), 'end\n',  ...
blanks( 6 ), asyncElsif,  ...
sync_statement,  ...
blanks( 6 ), 'end\n',  ...
blanks( 4 ), 'end ', hdlgetparameter( 'comment_char' ), ' ', processName, '\n\n' ];

hdlsequentialcontext( false );




function formatbody = formatbody( body )

formatbody = strrep( body, '\n\n', '\n' );
formatbody = strrep( formatbody, '\n', '\n      ' );

function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];

function asyncbody = vectorAsyncBody( outname, k, ICstr )
array_deref = hdlgetparameter( 'array_deref' );
asyncbody = [ outname, array_deref( 1 ), num2str( k ), array_deref( 2 ),  ...
' <= ', ICstr, ';\n' ];




% Decoded using De-pcode utility v1.2 from file /tmp/tmp5_t9o5.p.
% Please follow local copyright laws when handling this file.

