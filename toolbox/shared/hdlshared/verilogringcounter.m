function [ hdlbody, hdlsignals ] = verilogringcounter( counter_out, count, processName, leftright, phase, initValue, loadenb, loadvalue )









hdlsequentialcontext( true );
hdlsignals = [  ];

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

if count < 2
error( message( 'HDLShared:directemit:unsupportedarch' ) );
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

outname = hdlsignalname( counter_out );
outsltype = hdlsignalsltype( counter_out );
[ outsize, outbp, outsigned ] = hdlwordsize( outsltype );

asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( outname, int2str( 1 ) ) ];

if outsize > 2
if leftright == 1
if nargin >= 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( 2 ), 'if (', enablename, ' ==  1''b1', ') begin\n' ];
syncbody = [ syncbody, blanks( 6 ), scalarAsyncBody( outname, hdlconstantvalue( loadvalue, outsize, outbp, outsigned ) ) ];
syncbody = [ syncbody, blanks( 4 ), 'end\n' ];
syncbody = [ syncbody, blanks( 4 ), 'else begin\n' ];
syncbody = [ syncbody, blanks( 6 ), outname, ' <= {', outname, '[', num2str( outsize - 2 ), ' : 0], ', outname, '[', num2str( outsize - 1 ), ']};\n' ];
syncbody = [ syncbody, blanks( 4 ), 'end\n' ];
else 
syncbody = [ syncbody, blanks( 2 ), outname, ' <= {', outname, '[', num2str( outsize - 2 ), ' : 0], ', outname, '[', num2str( outsize - 1 ), ']};\n' ];
end 
else 
if nargin >= 7
enablename = hdlsignalname( loadenb );
syncbody = [ syncbody, blanks( 2 ), 'if (', enablename, ' ==  1''b1', ') begin\n' ];
syncbody = [ syncbody, blanks( 6 ), scalarAsyncBody( outname, hdlconstantvalue( loadvalue, outsize, outbp, outsigned ) ) ];
syncbody = [ syncbody, blanks( 4 ), 'end\n' ];
syncbody = [ syncbody, blanks( 4 ), 'else begin\n' ];
syncbody = [ syncbody, blanks( 6 ), outname, ' <= {', outname, '[0], ', outname, '[', num2str( outsize - 1 ), ' : 1]};\n' ];
syncbody = [ syncbody, blanks( 4 ), 'end\n' ];
else 
syncbody = [ syncbody, blanks( 2 ), outname, ' <= {', outname, '[0], ', outname, '[', num2str( outsize - 1 ), ' : 1]};\n' ];
end 
end 
else 
syncbody = [ syncbody, blanks( 2 ), outname, ' <= {', outname, '[0], ', outname, '[1]};\n' ];
end 


if isempty( clockenablename )
sync_statement = syncbody;
else 
sync_statement = [ blanks( 8 ), [ 'if (', clockenablename, ' == 1''b1) begin\n' ],  ...
syncbody,  ...
blanks( 8 ), [ 'end\n' ] ];
end 
hdlbody = [ blanks( 2 ), sensList,  ...
blanks( 4 ), 'begin: ', processName, '\n',  ...
blanks( 6 ), asyncIf,  ...
asyncbody,  ...
blanks( 6 ), 'end\n',  ...
blanks( 6 ), asyncElsif,  ...
blanks( 8 ), formatbody( sync_statement ),  ...
blanks( 6 ), 'end\n',  ...
blanks( 4 ), 'end ', hdlgetparameter( 'comment_char' ), ' ', processName, '\n\n' ];

hdlsequentialcontext( false );

if isscalar( phase )
if phase >= 0

[ phase_name, phasenameIdx ] = hdlnewsignal( hdllegalname( [ 'phase_', num2str( phase ) ] ), processName,  - 1, 0, 0, 'wire', 'boolean' );
hdlsignals = [ hdlsignals, phasenameIdx ];
[ assign_prefix, assign_op ] = hdlassignforoutput( phasenameIdx );
if isempty( clockenablename )
decodebody = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op, ' ', outname, '[', num2str( phase ), '];\n\n' ];
else 
decodebody = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op, ' ', outname, '[', num2str( phase ), ']  && ',  ...
clockenablename, ';\n\n' ];
end 

hdlbody = [ hdlbody, decodebody ];
end 
elseif iscell( phase )
for ii = 1:length( phase )
tmp_phase = cell2mat( phase( ii ) );
[ phase_name, idx ] = hdlnewsignal( hdllegalname( [ 'phase_', num2str( length( tmp_phase ) ) ] ), processName,  - 1, 0, 0, 'wire', 'boolean' );
hdlsignals = [ hdlsignals, idx ];
decodebody = [  ];
[ assign_prefix, assign_op ] = hdlassignforoutput( idx );
decodeheader = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op ];
if isempty( clockenablename )
clkenableStr = '';
else 
clkenableStr = [ ' && ', clockenablename, ' == 1''b1' ];
end 
if length( tmp_phase ) > 1
for ii = 1:( length( tmp_phase ) )
if ii == 1
decodebody = [ decodeheader, ' (((', outname, '[', num2str( tmp_phase( ii ) ), '] == 1''b1)  ||\n' ];
elseif ii <= length( tmp_phase ) - 1
decodebody = [ decodebody, blanks( length( decodeheader ) + 2 ), ' (', outname, '[', num2str( tmp_phase( ii ) ), '] == 1''b1)  ||\n' ];
else 
decodebody = [ decodebody, blanks( length( decodeheader ) + 2 ), ' (', outname, '[', num2str( tmp_phase( ii ) ), '] == 1''b1))', clkenableStr, ')? 1 : 0;\n\n' ];
end 
end 
hdlbody = [ hdlbody, decodebody ];
else 
if isempty( clockenablename )
decodebody = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op, ' ', outname, '[', num2str( tmp_phase ), '];\n\n' ];
else 
decodebody = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op, ' ', outname, '[', num2str( tmp_phase ), ']  && ',  ...
clockenablename, ';\n\n' ];
end 
hdlbody = [ hdlbody, decodebody ];
end 
end 
elseif isvector( phase )
for ii = 1:length( phase )
if phase( ii ) >= 0

[ phase_name, idx ] = hdlnewsignal( hdllegalname( [ 'phase_', num2str( phase( ii ) ) ] ), processName,  - 1, 0, 0, 'wire', 'boolean' );
hdlsignals = [ hdlsignals, idx ];
[ assign_prefix, assign_op ] = hdlassignforoutput( idx );
if isempty( clockenablename )
decodebody = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op, ' ', outname, '[', num2str( phase( ii ) ), '];\n\n' ];
else 
decodebody = [ blanks( 2 ), assign_prefix, ' ', phase_name, ' ', assign_op, ' ', outname, '[', num2str( phase( ii ) ), ']  && ',  ...
clockenablename, ';\n\n' ];
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

function asyncbody = vectorAsyncBody( outname, k, ICstr )

array_deref = hdlgetparameter( 'array_deref' );
asyncbody = [ outname, array_deref( 1 ), num2str( k ), array_deref( 2 ),  ...
' <= ', ICstr, ';\n' ];




% Decoded using De-pcode utility v1.2 from file /tmp/tmpt_jC9c.p.
% Please follow local copyright laws when handling this file.

