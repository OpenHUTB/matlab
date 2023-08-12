function [ hdlbody, hdlsignals ] = verilogshiftregister( input, output, loaden, extOut, outvld, startSignal, functionMode, shiftmode, initValue, processName )



















gConnOld = hdlconnectivity.genConnectivity( 0 );

hdlbody = [  ];
hdlsignals = [  ];

hdlsequentialcontext( true );
bdt = hdlgetparameter( 'base_data_type' );
singlequote = char( 39 );

if isempty( input ) || isempty( output ) || isempty( loaden )
error( message( 'HDLShared:directemit:invalidinput' ) );
end 

if nargin < 3
error( message( 'HDLShared:directemit:shiftregtoofewargs' ) );
elseif nargin == 3
extOut = [  ];
outvld = [  ];
startSignal = [  ];
functionMode = 'PARALLEL';
shiftmode = 'SHIFTRIGHT';
initValue = 0;
processName = 'SERIALIZER';
elseif nargin == 4
outvld = [  ];
startSignal = [  ];
functionMode = 'PARALLEL';
shiftmode = 'SHIFTRIGHT';
initValue = 0;
processName = 'SERIALIZER';
elseif nargin == 5
startSignal = [  ];
functionMode = 'PARALLEL';
shiftmode = 'SHIFTRIGHT';
initValue = 0;
processName = 'SERIALIZER';
elseif nargin == 6
functionMode = 'PARALLEL';
shiftmode = 'SHIFTRIGHT';
initValue = 0;
if strcmpi( functionMode, 'DESERIALIZER' )
processName = 'DESERIALIZER';
else 
processName = 'SERIALIZER';
end 
elseif nargin == 7
shiftmode = 'SHIFTRIGHT';
initValue = 0;
if strcmpi( functionMode, 'DESERIALIZER' )
processName = 'DESERIALIZER';
elseif strcmpi( functionMode, 'SHIFTER' )
processName = 'SHIFTER';
else 
processName = 'SERIALIZER';
end 
elseif nargin == 8
initValue = 0;
if strcmpi( functionMode, 'DESERIALIZER' )
processName = 'DESERIALIZER';
elseif strcmpi( functionMode, 'SHIFTER' )
processName = 'SHIFTER';
else 
processName = 'SERIALIZER';
end 

elseif nargin == 9
if strcmpi( functionMode, 'DESERIALIZER' )
processName = 'DESERIALIZER';
elseif strcmpi( functionMode, 'SHIFTER' )
processName = 'SHIFTER';
else 
processName = 'SERIALIZER';
end 
elseif nargin > 10
error( message( 'HDLShared:directemit:toomanyargs' ) );
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


if strcmpi( functionMode, 'DESERIALIZER' ) | strcmpi( functionMode, 'SHIFTER' )
vtype = hdlsignalvtype( output );
sltype = hdlsignalsltype( output );
[ name, shiftreg ] = hdlnewsignal( hdllegalname( 'shiftreg' ), 'filter',  - 1, 0, 0, vtype, sltype );
hdlregsignal( shiftreg );
hdlsignals = [ hdlsignals, makehdlsignaldecl( shiftreg ) ];
if ~isempty( outvld )
[ name, dvldreg ] = hdlnewsignal( hdllegalname( 'dvldreg' ), 'filter',  - 1, 0, 0, vtype, sltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( dvldreg ) ];
end 
regsltype = hdlsignalsltype( shiftreg );
[ regsize, outbp, outsigned ] = hdlwordsize( regsltype );
else 
vtype = hdlsignalvtype( input );
sltype = hdlsignalsltype( input );
[ name, shiftreg ] = hdlnewsignal( hdllegalname( 'shiftreg' ), 'filter',  - 1, 0, 0, vtype, sltype );
hdlregsignal( shiftreg );
hdlsignals = [ hdlsignals, makehdlsignaldecl( shiftreg ) ];
if ~isempty( outvld )
[ name, dvldreg ] = hdlnewsignal( hdllegalname( 'dvldreg' ), 'filter',  - 1, 0, 0, vtype, sltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( dvldreg ) ];
end 
regsltype = hdlsignalsltype( shiftreg );
[ regsize, outbp, outsigned ] = hdlwordsize( regsltype );
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
regname = hdlsignalname( shiftreg );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( regname, hdlconstantvalue( initValue, regsize, outbp, outsigned ) ) ];
if ~isempty( outvld )
regname = hdlsignalname( dvldreg );
asyncbody = [ asyncbody, blanks( reset_body_spaces ), scalarAsyncBody( regname, hdlconstantvalue( 0, regsize, outbp, outsigned ) ) ];
end 


syncbody = [  ];
space = blanks( reset_body_spaces );
if strcmpi( functionMode, 'DESERIALIZER' ) | strcmpi( functionMode, 'SHIFTER' )
syncbody = [ syncbody,  ...
blanks( 10 ), 'if (', hdlsignalname( loaden ), ' == 1''b1 ) begin\n' ];
if strcmpi( shiftmode, 'SHIFTLEFT' )
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( shiftreg ), ' <= {', hdlsignalname( shiftreg ), '[', num2str( regsize - 2 ), ' : 0], ', hdlsignalname( input ), '};\n' ];
if ~isempty( outvld )
if isempty( startSignal )
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( dvldreg ), ' <= {', hdlsignalname( dvldreg ), '[', num2str( regsize - 2 ), ' : 0],',  ...
hdlsignalname( dvldreg ), '[', num2str( regsize - 1 ), ']} ;\n' ];
else 
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( dvldreg ), ' <= {', hdlsignalname( dvldreg ), '[', num2str( regsize - 2 ), ' : 0], ',  ...
hdlsignalname( startSignal ), '};\n' ];
end 
end 
else 
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( shiftreg ), ' <= {', hdlsignalname( input ), ', ', hdlsignalname( shiftreg ), '[', num2str( regsize - 1 ), ' : 1]};\n' ];
if ~isempty( outvld )
if isempty( startSignal )
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( dvldreg ), ' <= {', hdlsignalname( dvldreg ), '[', num2str( 0 ), '], ',  ...
hdlsignalname( dvldreg ), '[', num2str( regsize - 1 ), ' : 1]} ;\n' ];
else 
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( dvldreg ), ' <= {', hdlsignalname( startSignal ), ', ',  ...
hdlsignalname( dvldreg ), '[', num2str( regsize - 1 ), ' : 1]} ;\n' ];
end 
end 
end 
syncbody = [ syncbody,  ...
blanks( 10 ), 'end\n' ];
else 
syncbody = [ syncbody,  ...
blanks( 10 ), 'if (', hdlsignalname( loaden ), ' == 1''b1) begin\n',  ...
blanks( 10 ), '  ', hdlsignalname( shiftreg ), ' <= ', hdlsignalname( input ), ';\n' ];
if ~isempty( outvld )
regname = hdlsignalname( dvldreg );
regvalue = ( 2 ^ regsize ) - 1;
syncbody = [ syncbody,  ...
blanks( reset_body_spaces ), scalarAsyncBody( regname, hdlconstantvalue( regvalue, regsize, outbp, outsigned ) ) ];
end 
syncbody = [ syncbody,  ...
blanks( 10 ), 'end\n',  ...
blanks( 10 ), 'else begin\n' ];
if strcmpi( shiftmode, 'SHIFTLEFT' )
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( shiftreg ), ' <= {', hdlsignalname( shiftreg ), '[', num2str( regsize - 2 ), ' : 0], 1''b0};\n' ];
if ~isempty( outvld )
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( dvldreg ), ' <= {', hdlsignalname( dvldreg ), '[', num2str( regsize - 2 ), ' : 0], 1''b0};\n' ];
end 
else 
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( shiftreg ), ' <= {1''b0, ', hdlsignalname( shiftreg ), '[', num2str( regsize - 1 ), ' : 1]};\n' ];
if ~isempty( outvld )
syncbody = [ syncbody,  ...
blanks( 10 ), '  ', hdlsignalname( dvldreg ), ' <= {1''b0, ', hdlsignalname( dvldreg ), '[', num2str( regsize - 1 ), ' : 1]};\n' ];
end 
end 
syncbody = [ syncbody,  ...
blanks( 10 ), 'end\n' ];
end 



if isempty( clockenablename )
sync_statement = syncbody;
else 
sync_statement = [ blanks( 8 ), 'if (', clockenablename, ' == 1''b1) begin\n',  ...
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
blanks( 6 ), 'end \n',  ...
blanks( 4 ), 'end ', hdlgetparameter( 'comment_char' ), ' ', processName, ';\n\n' ];

hdlsequentialcontext( false );



if strcmpi( functionMode, 'DESERIALIZER' )
[ assign_prefix, assign_op ] = hdlassignforoutput( output );
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( output ), assign_op, hdlsignalname( shiftreg ), ';\n' ];

[ assign_prefix, assign_op ] = hdlassignforoutput( outvld );
if ~isempty( outvld )
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( outvld ), assign_op, hdlsignalname( dvldreg ), '[', num2str( regsize - 1 ), '];\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( outvld ), assign_op, hdlsignalname( dvldreg ), '[', num2str( 0 ), '];\n' ];
end 
end 

elseif strcmpi( functionMode, 'SHIFTER' )
[ assign_prefix, assign_op ] = hdlassignforoutput( extOut );
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( extOut ), assign_op, hdlsignalname( shiftreg ), '[', num2str( regsize - 1 ), '];\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( extOut ), assign_op, hdlsignalname( shiftreg ), '[', num2str( 0 ), '];\n' ];
end 
else 
[ assign_prefix, assign_op ] = hdlassignforoutput( output );
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( output ), assign_op, hdlsignalname( shiftreg ), '[', num2str( regsize - 1 ), '];\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( output ), assign_op, hdlsignalname( shiftreg ), '[', num2str( 0 ), '];\n' ];
end 
if ~isempty( outvld )
[ assign_prefix, assign_op ] = hdlassignforoutput( outvld );
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( outvld ), assign_op, hdlsignalname( dvldreg ), '[', num2str( regsize - 1 ), '];\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', assign_prefix, '  ', hdlsignalname( outvld ), assign_op, hdlsignalname( dvldreg ), '[', num2str( 0 ), '];\n' ];
end 
end 
end 

hdlbody = [ hdlbody,  ...
' \n' ];











if gConnOld, 
ins = { input };
if ~isempty( loaden ), 
ins{ end  + 1 } = loaden;
end 

hCD = hdlconnectivity.getConnectivityDirector;
hCD.addDriverReceiverRegistered(  ...
ins, shiftreg,  ...
hdlgetcurrentclock, hdlgetcurrentclockenable );
hCD.addDriverReceiverPair( shiftreg, output, 'unroll', false, 'realonly', true );
end 

hdlconnectivity.genConnectivity( gConnOld );



function formatbody = formatbody( body )

formatbody = strrep( body, '\n\n', '\n' );
formatbody = strrep( formatbody, '\n', '\n      ' );

function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];




% Decoded using De-pcode utility v1.2 from file /tmp/tmpuniz8X.p.
% Please follow local copyright laws when handling this file.

