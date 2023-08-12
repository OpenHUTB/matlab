function [ hdlbody, hdlsignals ] = vhdlunitdelay( in, out, processName, scalarIC, enable )














if nargin == 4
enable = '';
end 

hdlsequentialcontext( true );

hdlsignals = [  ];
singlequote = char( 39 );
numports = length( in );

if isempty( scalarIC )
scalarIC = zeros( 1, numports );
end 

if ( length( out ) ~= numports ) || ( numports > 1 && length( scalarIC ) ~= numports )
error( message( 'HDLShared:directemit:mismatchedlengths' ) );
end 

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
enableCondition = [ '((', clockenablename, ' = ''1'') AND' ];
for i = 1:length( enable ) - 1
enableName = hdlsignalname( enable( i ) );
enableCondition = [ enableCondition, '(', enableName, ' = ''1'') AND' ];
end 
enableName = hdlsignalname( enable( length( enable ) ) );
enableCondition = [ enableCondition, '(', enableName, ' = ''1''))' ];
else 
enableCondition = [ clockenablename, ' = ''1''' ];
end 

creset = hdlgetcurrentreset;
if isempty( creset )
resetname = '';
elseif creset == 0
resetname = hdlgetparameter( 'resetname' );
else 
resetname = hdlsignalname( creset );
end 


if hdlgetparameter( 'async_reset' ) == 1
sensList = [ 'PROCESS (', clockname, ', ', resetname, ')\n' ];


asyncIf = [ 'IF ', resetname, ' = ''',  ...
num2str( hdlgetparameter( 'reset_asserted_level' ) ), ''' THEN', '\n' ];

if ( hdlgetparameter( 'clockedge' ) == 0 )
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncElsif = [ 'ELSIF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1'' THEN\n' ];
else 
asyncElsif = [ 'ELSIF ', 'rising_edge(', clockname, ') THEN\n' ];
end 
else 
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncElsif = [ 'ELSIF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0'' THEN\n' ];
else 
asyncElsif = [ 'ELSIF ', 'falling_edge(', clockname, ') THEN\n' ];
end 
end 
reset_body_spaces = 6;

else 
sensList = [ 'PROCESS (', clockname, ')\n' ];

if ( hdlgetparameter( 'clockedge' ) == 0 )
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncIf = [ 'IF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1'' THEN\n' ];
else 
asyncIf = [ 'IF ', 'rising_edge(', clockname, ') THEN\n' ];
end 
else 
if ( hdlgetparameter( 'clockedgestyle' ) == 0 )
asyncIf = [ 'IF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0'' THEN\n' ];
else 
asyncIf = [ 'IF ', 'falling_edge(', clockname, ') THEN\n' ];
end 
end 


asyncElsif = [ 'IF ', resetname, ' = ''',  ...
num2str( hdlgetparameter( 'reset_asserted_level' ) ), ''' THEN', '\n' ];


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

[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );

if ~strcmp( sltype, 'double' ) && all( scalarIC( k ) == 0 ) && ( outsize > 1 )
if isnan( scalarIC( k ) )
ICstr = '(OTHERS => ''X'')';
else 
ICstr = '(OTHERS => ''0'')';
end 
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


if vector == 0
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( outname, ICstr ) ];
if ( cplx )
outname_im = hdlsignalname( hdlsignalimag( out( k ) ) );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( outname_im, ICstr ) ];
end 
else 
asyncbody = [ asyncbody, blanks( reset_body_spaces ), vectorAsyncBody( outname, ICstr ) ];
if ( cplx )
outname_im = hdlsignalname( hdlsignalimag( out( k ) ) );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), vectorAsyncBody( outname_im, ICstr ) ];
end 
end 


range = 0:max( vector ) - 1;
syncbody = [ syncbody, hdlsignalassignment( in( k ), out( k ), range, range, [  ] ) ];


end 


if hdlgetparameter( 'async_reset' ) == 1
if isempty( clockenablename )
sync_statement = [ blanks( 4 ), formatbody( syncbody ), '\n' ];
else 
sync_statement = [ blanks( 6 ), 'IF ', enableCondition, ' THEN\n',  ...
blanks( 6 ), formatbody( syncbody ),  ...
'END IF;\n' ];
end 

hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), asyncIf,  ...
asyncbody,  ...
blanks( 4 ), asyncElsif,  ...
sync_statement,  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];
else 
if isempty( clockenablename )
sync_statement = [ blanks( 6 ), 'ELSE\n',  ...
blanks( 6 ), formatbody( syncbody ),  ...
'END IF;\n' ];
else 
sync_statement = [ blanks( 6 ), 'ELSIF ', enableCondition, ' THEN\n',  ...
blanks( 6 ), formatbody( syncbody ),  ...
'END IF;\n' ];
end 
hdlbody = [ blanks( 2 ), processName, ' : ', sensList,  ...
blanks( 2 ), 'BEGIN\n',  ...
blanks( 4 ), asyncIf,  ...
blanks( 6 ), asyncElsif,  ...
asyncbody,  ...
sync_statement,  ...
blanks( 4 ), 'END IF; \n',  ...
blanks( 2 ), 'END PROCESS ', processName, ';\n\n' ];
end 

hdlsequentialcontext( false );




function formatbody = formatbody( body )

formatbody = strrep( body, '\n\n', '\n' );
formatbody = strrep( formatbody, '\n', '\n      ' );

function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];

function asyncbody = vectorAsyncBody( outname, ICstr )
ICstr = [ '(OTHERS => ', ICstr, ')' ];
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];





% Decoded using De-pcode utility v1.2 from file /tmp/tmpxdnUdH.p.
% Please follow local copyright laws when handling this file.

