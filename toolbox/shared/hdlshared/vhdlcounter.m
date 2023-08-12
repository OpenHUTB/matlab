function [ hdlbody, hdlsignals ] = vhdlcounter( counter_out, count, processName,  ...
updown, initValue, phase, phaseRegOut, loadenb, loadvalue )











hdlsequentialcontext( true );
hdlsignals = [  ];
singlequote = char( 39 );

if nargin == 5
phase =  - 1;
loadvalue = initValue;
phaseRegOut =  - 1;
elseif nargin == 6
loadvalue = initValue;
phaseRegOut =  - 1;
elseif nargin == 7 || nargin == 8
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

ral = [ singlequote, int2str( hdlgetparameter( 'reset_asserted_level' ) ), singlequote ];
clkedge = hdlgetparameter( 'clockedge' );
clkedgestyle = hdlgetparameter( 'clockedgestyle' );

sensList = [ 'PROCESS (', clockname ];
if hdlgetparameter( 'async_reset' ) == 1
sensList = [ sensList, ', ', resetname, ')\n' ];


asyncIf = [ 'IF ', resetname, ' = ', ral, ' THEN', '\n' ];

if clkedge == 0
if clkedgestyle == 0
asyncElsif = [ 'ELSIF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1'' THEN\n' ];
else 
asyncElsif = [ 'ELSIF ', 'rising_edge(', clockname, ') THEN\n' ];
end 
else 
if clkedgestyle == 0
asyncElsif = [ 'ELSIF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0'' THEN\n' ];
else 
asyncElsif = [ 'ELSIF ', 'falling_edge(', clockname, ') THEN\n' ];
end 
end 

indent = 6;

else 
sensList = [ sensList, ')\n' ];

if clkedge == 0
if clkedgestyle == 0
asyncIf = [ 'IF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''1'' THEN\n' ];
else 
asyncIf = [ 'IF ', 'rising_edge(', clockname, ') THEN\n' ];
end 
else 
if clkedgestyle == 0
asyncIf = [ 'IF ', clockname, singlequote, 'event AND ',  ...
clockname, ' = ''0'' THEN\n' ];
else 
asyncIf = [ 'IF ', 'falling_edge(', clockname, ') THEN\n' ];
end 
end 


asyncElsif = [ 'IF ', resetname, ' = ', ral, ' THEN', '\n' ];

indent = 8;
end 

asyncbody = [  ];
syncbody = [  ];
outname = hdlsignalname( counter_out );
outsltype = hdlsignalsltype( counter_out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
iv = hdlconstantvalue( initValue, outsize, outbp, outsigned, 'noaggregate' );
asyncbody = [ asyncbody, blanks( indent ), scalarAsyncBody( outname, iv ) ];

if iscell( count )

tmlcnt_assn = [ hdlsignalname( count{ : } ), ' - 1' ];
else 
tmlcnt_assn = hdlconstantvalue( count - 1, outsize, outbp, outsigned, 'noaggregate' );
end 

compOp = ' >= ';
if strcmpi( hdlgetparameter( 'TCCounterLimitCompOp' ), '==' )
compOp = ' = ';
end 

if outsize > 1 || outsigned == 1
loadval = hdlconstantvalue( loadvalue, outsize, outbp, outsigned, 'noaggregate' );
literalzero = hdlconstantvalue( 0, outsize, outbp, outsigned, 'noaggregate' );
literalone = hdlconstantvalue( 1, outsize, outbp, outsigned, 'noaggregate' );
if updown == 1
if nargin > 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( 2 ), 'IF ', enablename, ' = ''1'' THEN\n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', loadval, ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'ELSIF ', outname, compOp, tmlcnt_assn, ' THEN\n' ];
else 
syncbody = [ syncbody, blanks( 2 ), 'IF ', outname, compOp, tmlcnt_assn, ' THEN\n' ];
end 
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', literalzero, ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'ELSE\n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', outname, ' + ', literalone, ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'END IF;\n' ];
else 
if nargin > 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( 2 ), 'IF ', enablename, ' = ''1'' THEN\n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', loadval, ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'ELSIF ', outname, ' = 0 THEN\n' ];
else 
syncbody = [ syncbody, blanks( 2 ), 'IF ', outname, ' = 0 THEN\n' ];
end 
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', tmlcnt_assn, ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'ELSE\n' ];
syncbody = [ syncbody, blanks( 4 ), outname, ' <= ', outname, ' - ', literalone, ';\n' ];
syncbody = [ syncbody, blanks( 2 ), 'END IF;\n' ];
end 
else 
syncbody = [ syncbody, blanks( 4 ), outname, ' <= NOT ', outname, ';\n' ];
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



internalsignals = [  ];
if iscell( phase )
for ii = 1:length( phase )
tmp_phase = cell2mat( phase( ii ) );
if all( tmp_phase >= 0 )
[ tmphdlbody, tmphdlsignals, tmpsignals ] = counterPhaseDecoder( tmp_phase,  ...
count, phaseRegOut, counter_out, clockenablename, 0 );
hdlbody = [ hdlbody, tmphdlbody ];%#ok<AGROW>
hdlsignals = [ hdlsignals, tmphdlsignals ];%#ok<AGROW>
internalsignals = [ internalsignals, tmpsignals ];%#ok<AGROW>
end 
end 
hdlsignals = [ hdlsignals, internalsignals ];
else 
for i = 1:length( phase )
if all( phase >= 0 )
[ tmphdlbody, tmphdlsignals, tmpsignals ] = counterPhaseDecoder( phase( i ),  ...
count, phaseRegOut, counter_out, clockenablename, 1 );
hdlbody = [ hdlbody, tmphdlbody ];%#ok<AGROW>
hdlsignals = [ hdlsignals, tmphdlsignals ];%#ok<AGROW>
internalsignals = [ internalsignals, tmpsignals ];%#ok<AGROW>
end 
end 
hdlsignals = [ hdlsignals, internalsignals ];
end 
end 




function [ hdlbody, hdlsignals, tmphdlsignals ] = counterPhaseDecoder( phaseIn,  ...
count, phaseRegOut, counter_out, clockenablename, splitVector )
outname = hdlsignalname( counter_out );
outsltype = hdlsignalsltype( counter_out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
tmphdlsignals = [  ];
hdlsignals = [  ];
hdlbody = [  ];
if length( phaseIn ) == 2 && abs( phaseIn( 2 ) - phaseIn( 1 ) ) == count
phase = phaseIn( 1 );
else 
phase = phaseIn;
end 

if length( phase ) > 1
if length( phase ) == 3 && phase( 3 ) == count
phase_inc = phase( 2 );
fullLen = true;
else 
phase_inc = abs( phase( 2 ) - phase( 1 ) );
fullLen = length( phase ) == count;
end 
if phase_inc == 1 && fullLen && ~splitVector
phase_suffix = 'all';
else 
phase_suffix = int2str( phase_inc );
end 
else 
phase_inc = phase( 1 );
fullLen = false;
phase_suffix = int2str( phase_inc );
end 


if phaseRegOut ==  - 1 || iscell( count ) || ( phase_inc == 1 && fullLen && ~splitVector )
[ tmpname, tmpidx ] = hdlnewsignal( hdllegalname( [ 'phase_', phase_suffix ] ), 'filter',  - 1, 0, 0, 'std_logic', 'boolean' );
hdlsignals = [ hdlsignals, tmpidx ];
else 
[ ~, idx ] = hdlnewsignal( hdllegalname( [ 'phase_', phase_suffix ] ), 'filter',  - 1, 0, 0, 'std_logic', 'boolean' );
hdlsignals = [ hdlsignals, idx ];
[ tmpname, tmpidx ] = hdlnewsignal( hdllegalname( [ 'phase_', phase_suffix, '_tmp' ] ), 'filter',  - 1, 0, 0, 'std_logic', 'boolean' );
tmphdlsignals = [ tmphdlsignals, tmpidx ];
if phase( 1 ) == 1
IC = 1;
else 
IC = 0;
end 
[ tmpbody, tmpsignal ] = vhdlunitdelay( tmpidx, idx, hdluniqueprocessname, IC );
hdlsignals = [ hdlsignals, tmpsignal ];
hdlbody = [ hdlbody, tmpbody ];
if length( phase ) ~= 3 || phase( 3 ) ~= count
for jj = 1:length( phase )
if phase( jj ) == 0
phase( jj ) = count - 1;
else 
phase( jj ) = phase( jj ) - 1;
end 
end 
end 
end 
decodebody = [  ];
decodeheader = [ blanks( 2 ), tmpname, ' <= ''1'' WHEN  (((' ];
if isempty( clockenablename )
clkenableStr = '';
else 
clkenableStr = [ ' AND ', clockenablename, ' = ''1''' ];
end 
if length( phase ) > 1
if phase_inc == 1 && ( length( phase ) == count || ( length( phase ) == 3 && phase( 3 ) == count ) )
if isempty( clockenablename )
decodebody = [ blanks( 2 ), tmpname, ' <= ''1'';\n\n' ];
else 
decodebody = [ blanks( 2 ), tmpname, ' <= ''1'' WHEN ', clockenablename, ' = ''1'' ELSE ''0'';\n\n' ];
end 
else 
for ii = 1:( length( phase ) )
if ii == 1
decodebody = [ decodeheader, outname, ' = ', hdlconstantvalue( phase( ii ), outsize, outbp, outsigned, 'noaggregate' ), ')  OR\n' ];
elseif ii <= length( phase ) - 1
decodebody = [ decodebody, blanks( length( decodeheader ) - 1 ), '(', outname, ' = ', hdlconstantvalue( phase( ii ), outsize, outbp, outsigned, 'noaggregate' ), ')  OR\n' ];%#ok<AGROW>
else 
decodebody = [ decodebody, blanks( length( decodeheader ) - 1 ), '(', outname, ' = ', hdlconstantvalue( phase( ii ), outsize, outbp, outsigned, 'noaggregate' ), ')) ' ...
, clkenableStr, ') ELSE ''0'';\n\n' ];%#ok<AGROW>
end 
end 
end 
hdlbody = [ hdlbody, decodebody ];
else 
decodebody = [ blanks( 2 ), tmpname, ' <= ''1'' WHEN ', outname, ' = ', hdlconstantvalue( phase, outsize, outbp, outsigned, 'noaggregate' ),  ...
clkenableStr, ' ELSE ''0'';\n\n' ];

hdlbody = [ hdlbody, decodebody ];
end 
end 


function formatbody = formatbody( body )

formatbody = strrep( body, '\n\n', '\n' );
formatbody = strrep( formatbody, '\n', '\n      ' );
end 

function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpn2wRjj.p.
% Please follow local copyright laws when handling this file.

