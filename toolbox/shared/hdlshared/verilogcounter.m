function [ hdlbody, hdlsignals ] = verilogcounter( counter_out, count, processName,  ...
updown, initValue, phase, phaseRegOut, loadenb, loadvalue )












hdlsequentialcontext( true );
hdlsignals = [  ];

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

hdlregsignal( counter_out );

clkedge = hdlgetparameter( 'clockedge' );
ral = hdlgetparameter( 'reset_asserted_level' );
if ral == 1
resetedge = 'posedge ';
else 
resetedge = 'negedge ';
end 


if clkedge == 0
clk_edge = 'posedge ';
else 
clk_edge = 'negedge ';
end 
sensList = [ 'always @ (', clk_edge, clockname ];
if hdlgetparameter( 'async_reset' ) == 1
sensList = [ sensList, ' or ', resetedge, resetname, ')\n' ];
else 
sensList = [ sensList, ')\n' ];
end 
asyncIf = [ 'if (', resetname, ' == 1''b', int2str( ral ), ') begin\n' ];
asyncElsif = 'else begin\n';
indent = 8;

outname = hdlsignalname( counter_out );
outsltype = hdlsignalsltype( counter_out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );
iv = hdlconstantvalue( initValue, outsize, outbp, outsigned, 'noaggregate' );
asyncbody = [ blanks( indent ), scalarAsyncBody( outname, iv ) ];

if iscell( count )

tmlcnt_assn = [ hdlsignalname( count{ : } ), ' - 1' ];
else 
tmlcnt_assn = hdlconstantvalue( count - 1, outsize, outbp, outsigned, 'noaggregate' );
end 
syncbody = [  ];

compOp = ' >= ';
if strcmpi( hdlgetparameter( 'TCCounterLimitCompOp' ), '==' )
compOp = ' == ';
end 

if outsize > 1 || outsigned == 1
literalzero = hdlconstantvalue( 0, outsize, outbp, outsigned, 'noaggregate' );
literalone = hdlconstantvalue( 1, outsize, outbp, outsigned, 'noaggregate' );
loadval = hdlconstantvalue( loadvalue, outsize, outbp, outsigned, 'noaggregate' );
if updown == 1
if nargin > 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( indent + 2 ), 'if (', enablename, ' ==  1''b1', ') begin\n' ];
syncbody = [ syncbody, blanks( indent + 4 ), scalarAsyncBody( outname, loadval ) ];
syncbody = [ syncbody, blanks( indent + 2 ), 'end\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'else if (', outname, compOp, tmlcnt_assn, ') begin\n' ];
else 
syncbody = [ syncbody, blanks( indent + 2 ), 'if (', outname, compOp, tmlcnt_assn, ') begin\n' ];
end 
syncbody = [ syncbody, blanks( indent + 4 ), scalarAsyncBody( outname, literalzero ) ];
syncbody = [ syncbody, blanks( indent + 2 ), 'end\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'else begin\n' ];
syncbody = [ syncbody, blanks( indent + 4 ), outname, ' <= ', outname, ' + ', literalone, ';\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'end\n' ];
else 
if nargin > 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( indent + 2 ), 'if (', enablename, ' ==  1''b1', ') begin\n' ];
syncbody = [ syncbody, blanks( indent + 4 ), scalarAsyncBody( outname, loadval ) ];
syncbody = [ syncbody, blanks( indent + 2 ), 'end\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'else if (', outname, ' == ', literalzero, ') begin\n' ];
else 
syncbody = [ syncbody, blanks( indent + 2 ), 'if (', outname, ' == ', literalzero, ') begin\n' ];
end 
syncbody = [ syncbody, blanks( indent + 4 ), outname, ' <= ', tmlcnt_assn, ';\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'end\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'else begin\n' ];
syncbody = [ syncbody, blanks( indent + 4 ), outname, ' <= ', outname, ' - ', literalone, ';\n' ];
syncbody = [ syncbody, blanks( indent + 2 ), 'end\n' ];
end 
else 
syncbody = [ syncbody, blanks( indent + 4 ), outname, ' <= ~ ', outname, ';\n' ];
end 



if isempty( clockenablename )
sync_statement = syncbody;
else 
sync_statement = [ blanks( 8 ), [ 'if (', clockenablename, ' == 1''b1) begin\n' ],  ...
syncbody,  ...
blanks( 8 ), 'end\n' ];
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




internalsignals = [  ];

if iscell( phase )
for ii = 1:length( phase )
tmp_phase = cell2mat( phase( ii ) );
if all( tmp_phase >= 0 )
[ tmphdlbody, tmphdlsignals, tmpsignals ] = counterPhaseDecoder( tmp_phase, count, phaseRegOut, counter_out, clockenablename, 0 );
hdlbody = [ hdlbody, tmphdlbody ];%#ok<AGROW>
hdlsignals = [ hdlsignals, tmphdlsignals ];%#ok<AGROW>
internalsignals = [ internalsignals, tmpsignals ];%#ok<AGROW>
end 
end 
hdlsignals = [ hdlsignals, internalsignals ];
else 
for i = 1:length( phase )
if all( phase >= 0 )
[ tmphdlbody, tmphdlsignals, tmpsignals ] = counterPhaseDecoder( phase( i ), count, phaseRegOut, counter_out, clockenablename, 1 );
hdlbody = [ hdlbody, tmphdlbody ];%#ok<AGROW>
hdlsignals = [ hdlsignals, tmphdlsignals ];%#ok<AGROW>
internalsignals = [ internalsignals, tmpsignals ];%#ok<AGROW>
end 
end 
hdlsignals = [ hdlsignals, internalsignals ];
end 
end 




function [ hdlbody, hdlsignals, tmphdlsignals ] = counterPhaseDecoder( phaseIn, count, phaseRegOut, counter_out, clockenablename, splitVector )
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
[ tmpname, tmpidx ] = hdlnewsignal( hdllegalname( [ 'phase_', phase_suffix ] ), 'filter',  - 1, 0, 0, 'wire', 'boolean' );
hdlsignals = [ hdlsignals, tmpidx ];
else 
[ ~, idx ] = hdlnewsignal( hdllegalname( [ 'phase_', phase_suffix ] ), 'filter',  - 1, 0, 0, 'wire', 'boolean' );
hdlsignals = [ hdlsignals, idx ];
[ tmpname, tmpidx ] = hdlnewsignal( hdllegalname( [ 'phase_', phase_suffix, '_tmp' ] ), 'filter',  - 1, 0, 0, 'wire', 'boolean' );
tmphdlsignals = [ tmphdlsignals, tmpidx ];
if phase( 1 ) == 1
IC = 1;
else 
IC = 0;
end 
[ tmpbody, tmpsignal ] = verilogunitdelay( tmpidx, idx, hdluniqueprocessname, IC );
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
[ assign_prefix, assign_op ] = hdlassignforoutput( tmpidx );
decodeheader = [ blanks( 2 ), assign_prefix, tmpname, ' ', assign_op ];
if isempty( clockenablename )
clkenableStr = '';
else 
clkenableStr = [ ' && ', clockenablename, ' == 1''b1' ];
end 
ternarystr = ' ? 1''b1 : 1''b0;\n\n';
if length( phase ) > 1
if phase_inc == 1 && ( length( phase ) == count || ( length( phase ) == 3 && phase( 3 ) == count ) )
if isempty( clockenablename )
decodebody = [ decodeheader, ' 1''b1 ));\n' ];
else 
decodebody = [ decodeheader, ' ', clockenablename, ternarystr ];
end 
else 
for ii = 1:length( phase )
phaseliteral = hdlconstantvalue( phase( ii ), outsize, outbp, outsigned, 'noaggregate' );
deccore = [ '(', outname, ' == ', phaseliteral, ')' ];
if ii == 1
decodebody = [ decodeheader, ' ((', deccore, ' ||\n' ];
elseif ii <= length( phase ) - 1
decodebody = [ decodebody, blanks( length( decodeheader ) + 2 ), ' ', deccore, '  ||\n' ];%#ok<AGROW>
else 
decodebody = [ decodebody, blanks( length( decodeheader ) + 2 ), ' ', deccore, ')', clkenableStr, ')', ternarystr ];%#ok<AGROW>
end 
end 
end 
hdlbody = [ hdlbody, decodebody ];
else 
phaseliteral = hdlconstantvalue( phase, outsize, outbp, outsigned, 'noaggregate' );
decodebody = [ blanks( 2 ), assign_prefix, ' ', tmpname, ' ', assign_op, ' (' ...
, outname, ' == ', phaseliteral, clkenableStr, ')', ternarystr ];
hdlbody = [ hdlbody, decodebody ];
end 
end 


function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWxMCTY.p.
% Please follow local copyright laws when handling this file.

