function [ hdlbody, hdlsignals ] = vhdlringcounter( counter_out, count, processName, leftright, phase, initValue, loadenb, loadvalue )









hdlsequentialcontext( true );
bdt = hdlgetparameter( 'base_data_type' );
hdlbody = [  ];
hdlsignals = [  ];
singlequote = char( 39 );

if nargin < 3
msg = 'hdlringcounter should be called with at least three arguments, counter_out, count and processName.';
elseif nargin == 3
leftright = 1;
phase =  - 1;
initValue = 1;
elseif nargin == 4
phase =  - 1;
initValue = 1;
elseif nargin == 5
initValue = 1;
elseif nargin == 7
loadvalue = initValue;
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

outname = hdlsignalname( counter_out );
outsltype = hdlsignalsltype( counter_out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( outname, hdlconstantvalue( initValue, outsize, outbp, outsigned ) ) ];
if outsize > 2
if leftright == 1
if nargin >= 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( 2 ), 'IF ', enablename, ' = ''1'' THEN\n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', hdlconstantvalue( loadvalue, outsize, outbp, outsigned ), ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'ELSE \n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', outname, '(', num2str( outsize - 2 ), ' DOWNTO 0) & ', outname, '(', num2str( outsize - 1 ), ');\n' ];
syncbody = [ syncbody, blanks( 2 ), 'END IF;\n' ];
else 
syncbody = [ syncbody, blanks( 2 ), outname, ' <= ', outname, '(', num2str( outsize - 2 ), ' DOWNTO 0) & ', outname, '(', num2str( outsize - 1 ), ');\n' ];
end 
else 
if nargin >= 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( 2 ), 'IF ', enablename, ' = ''1'' THEN\n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', hdlconstantvalue( loadvalue, outsize, outbp, outsigned ), ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'ELSE \n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', outname, '(0) & ', outname, '(', num2str( outsize - 1 ), ' DOWNTO 1);\n' ];
syncbody = [ syncbody, blanks( 2 ), 'END IF;\n' ];
else 
syncbody = [ syncbody, blanks( 2 ), outname, ' <= ', outname, '(0) & ', outname, '(', num2str( outsize - 1 ), ' DOWNTO 1);\n' ];
end 
end 
else 
syncbody = [ syncbody, blanks( 2 ), outname, ' <= ', outname, '(0) & ', outname, '(1);\n' ];
end 


if hdlgetparameter( 'async_reset' ) == 1
if isempty( clockenablename )
sync_statement = [ blanks( 4 ), formatbody( syncbody ), '\n' ];
else 
sync_statement = [ blanks( 6 ), 'IF ', clockenablename, ' = ''1'' THEN\n',  ...
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
sync_statement = [ blanks( 6 ), 'ELSIF ', clockenablename, ' = ''1'' THEN\n',  ...
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

if isscalar( phase )
if phase >= 0

[ phase_name, idx ] = hdlnewsignal( hdllegalname( [ 'phase_', num2str( phase ) ] ), 'filter',  - 1, 0, 0, 'std_logic', 'boolean' );
hdlsignals = [ hdlsignals, idx ];

if isempty( clockenablename )
decodebody = [ blanks( 2 ), phase_name, ' <= ', outname, '(', num2str( phase ), ');\n\n' ];
else 
decodebody = [ blanks( 2 ), phase_name, ' <= ', outname, '(', num2str( phase ),  ...
')  AND ', clockenablename, ';\n\n' ];
end 
hdlbody = [ hdlbody, decodebody ];

end 
elseif iscell( phase )
for i = 1:length( phase )
tmp_phase = cell2mat( phase( i ) );
[ phase_name, tmpIdx ] = hdlnewsignal( hdllegalname( [ 'phase_', num2str( length( tmp_phase ) ) ] ), 'filter',  - 1, 0, 0, 'std_logic', 'boolean' );
hdlsignals = [ hdlsignals, tmpIdx ];
decodebody = [  ];
decodeheader = [ blanks( 2 ), phase_name, ' <= ''1'' WHEN  (((' ];
if isempty( clockenablename )
clkenableStr = '';
else 
clkenableStr = [ 'AND ', clockenablename, ' = ''1''' ];
end 
if length( tmp_phase ) > 1
for ii = 1:( length( tmp_phase ) )
if ii == 1
decodebody = [ decodeheader, outname, '(', num2str( tmp_phase( ii ) ), ') = ''1''', ')  OR\n' ];
elseif ii <= length( tmp_phase ) - 1
decodebody = [ decodebody, blanks( length( decodeheader ) - 1 ), '(', outname, '(', num2str( tmp_phase( ii ) ), ') = ''1''', ')  OR\n' ];
else 
decodebody = [ decodebody, blanks( length( decodeheader ) - 1 ), '(', outname, '(', num2str( tmp_phase( ii ) ), ') = ''1''', ')) ' ...
, clkenableStr, ') ELSE ''0'';\n\n' ];
end 
end 

hdlbody = [ hdlbody, decodebody ];
else 
if isempty( clockenablename )
decodebody = [ blanks( 2 ), phase_name, ' <= ', outname, '(', num2str( tmp_phase ), ');\n\n' ];
else 
decodebody = [ blanks( 2 ), phase_name, ' <= ', outname, '(', num2str( tmp_phase ),  ...
')  AND ', clockenablename, ';\n\n' ];
end 

hdlbody = [ hdlbody, decodebody ];
end 

end 
elseif isvector( phase )
for i = 1:length( phase )
if phase( i ) >= 0

[ phase_name, idx ] = hdlnewsignal( hdllegalname( [ 'phase_', num2str( phase( i ) ) ] ), 'filter',  - 1, 0, 0, 'std_logic', 'boolean' );
hdlsignals = [ hdlsignals, idx ];

if isempty( clockenablename )
decodebody = [ blanks( 2 ), phase_name, ' <= ', outname, '(', num2str( phase( i ) ), ');\n\n' ];
else 
decodebody = [ blanks( 2 ), phase_name, ' <= ', outname, '(', num2str( phase( i ) ),  ...
')  AND ', clockenablename, ';\n\n' ];
end 
hdlbody = [ hdlbody, decodebody ];
end 
end 
else 
msg = 'This block function mode for hdlminmaxblock is not supported';
end 




function formatbody = formatbody( body )

formatbody = strrep( body, '\n\n', '\n' );
formatbody = strrep( formatbody, '\n', '\n      ' );

function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];





% Decoded using De-pcode utility v1.2 from file /tmp/tmpdjv7dO.p.
% Please follow local copyright laws when handling this file.

