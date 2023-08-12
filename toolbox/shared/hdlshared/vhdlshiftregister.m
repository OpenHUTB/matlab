function [ hdlbody, hdlsignals ] = vhdlshiftregister( input, output, loaden, extOut, outvld, startSignal, functionMode, shiftmode, initValue, processName )



















gConnOld = hdlconnectivity.genConnectivity( 0 );

hdlbody = [  ];
hdlsignals = [  ];

hdlsequentialcontext( true );
bdt = hdlgetparameter( 'base_data_type' );
singlequote = char( 39 );

if isempty( input ) || isempty( output ) || isempty( loaden )
error( message( 'HDLShared:directemit:missinginputssr' ) );
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
hdlsignals = [ hdlsignals, makehdlsignaldecl( shiftreg ) ];
if ~isempty( outvld )
[ name, dvldreg ] = hdlnewsignal( hdllegalname( 'dvldreg' ), 'filter',  - 1, 0, 0, vtype, sltype );
hdlsignals = [ hdlsignals, makehdlsignaldecl( dvldreg ) ];
end 
regsltype = hdlsignalsltype( shiftreg );
[ regsize, outbp, outsigned ] = hdlwordsize( regsltype );
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
regname = hdlsignalname( shiftreg );
asyncbody = [ asyncbody, spaces( reset_body_spaces ), scalarAsyncBody( regname, hdlconstantvalue( initValue, regsize, outbp, outsigned ) ) ];
if ~isempty( outvld )
regname = hdlsignalname( dvldreg );
asyncbody = [ asyncbody, spaces( reset_body_spaces ), scalarAsyncBody( regname, hdlconstantvalue( 0, regsize, outbp, outsigned ) ) ];
end 


syncbody = [  ];
space = spaces( reset_body_spaces );
if strcmpi( functionMode, 'DESERIALIZER' ) | strcmpi( functionMode, 'SHIFTER' )
syncbody = [ syncbody,  ...
'  IF ', hdlsignalname( loaden ), ' = ''1'' THEN\n' ];
if strcmpi( shiftmode, 'SHIFTLEFT' )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( shiftreg ), ' <= ', hdlsignalname( shiftreg ), '(', num2str( regsize - 2 ), ' DOWNTO 0) & ', hdlsignalname( input ), ';\n' ];
if ~isempty( outvld )
if isempty( startSignal )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( regsize - 2 ), ' DOWNTO 0) & ',  ...
hdlsignalname( dvldreg ), '(', num2str( regsize - 1 ), ') ;\n' ];
else 
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( regsize - 2 ), ' DOWNTO 0) & ',  ...
hdlsignalname( startSignal ), ';\n' ];
end 
end 
else 
syncbody = [ syncbody,  ...
'    ', hdlsignalname( shiftreg ), ' <= ', hdlsignalname( input ), ' & ', hdlsignalname( shiftreg ), '(', num2str( regsize - 1 ), ' DOWNTO 1);\n' ];
if ~isempty( outvld )
if isempty( startSignal )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( 0 ), ') & ',  ...
hdlsignalname( dvldreg ), '(', num2str( regsize - 1 ), ' DOWNTO 1) ;\n' ];
else 
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= ', hdlsignalname( startSignal ), ' & ',  ...
hdlsignalname( dvldreg ), '(', num2str( regsize - 1 ), ' DOWNTO 1) ;\n' ];
end 
end 
end 
syncbody = [ syncbody,  ...
'  END IF;\n' ];
else 
syncbody = [ syncbody,  ...
'  IF ', hdlsignalname( loaden ), ' = ''1'' THEN\n',  ...
'    ', hdlsignalname( shiftreg ), ' <= ', hdlsignalname( input ), ';\n' ];
if ~isempty( outvld )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= (OTHERS => ''1'');\n' ];
end 
syncbody = [ syncbody,  ...
'  ELSE\n' ];
if strcmpi( shiftmode, 'SHIFTLEFT' )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( shiftreg ), ' <= ', hdlsignalname( shiftreg ), '(', num2str( regsize - 2 ), ' DOWNTO 0) & ''0'';\n' ];
if ~isempty( outvld )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( regsize - 2 ), ' DOWNTO 0) & ''0'';\n' ];
end 
else 
syncbody = [ syncbody,  ...
'    ', hdlsignalname( shiftreg ), ' <= ''0'' & ', hdlsignalname( shiftreg ), '(', num2str( regsize - 1 ), ' DOWNTO 1);\n' ];
if ~isempty( outvld )
syncbody = [ syncbody,  ...
'    ', hdlsignalname( dvldreg ), ' <= ''0'' & ', hdlsignalname( dvldreg ), '(', num2str( regsize - 1 ), ' DOWNTO 1);\n' ];
end 
end 
syncbody = [ syncbody,  ...
'  END IF;\n' ];
end 


if hdlgetparameter( 'async_reset' ) == 1
if isempty( clockenablename )
sync_statement = [ spaces( 6 ), formatbody( syncbody ), '\n' ];
else 
sync_statement = [ spaces( 6 ), 'IF ', clockenablename, ' = ''1'' THEN\n',  ...
spaces( 6 ), formatbody( syncbody ),  ...
'END IF;\n' ];
end 
hdlbody = [ spaces( 2 ), processName, ' : ', sensList,  ...
spaces( 2 ), 'BEGIN\n',  ...
spaces( 4 ), asyncIf,  ...
asyncbody,  ...
spaces( 4 ), asyncElsif,  ...
sync_statement,  ...
spaces( 4 ), 'END IF; \n',  ...
spaces( 2 ), 'END PROCESS ', processName, ';\n\n' ];
else 
if isempty( clockenablename )
sync_statement = [ spaces( 6 ), 'ELSE\n',  ...
spaces( 4 ), formatbody( syncbody ),  ...
'END IF;\n' ];
else 
sync_statement = [ spaces( 6 ), 'ELSIF ', clockenablename, ' = ''1'' THEN\n',  ...
spaces( 6 ), formatbody( syncbody ),  ...
'END IF;\n' ];
end 
hdlbody = [ spaces( 2 ), processName, ' : ', sensList,  ...
spaces( 2 ), 'BEGIN\n',  ...
spaces( 4 ), asyncIf,  ...
spaces( 6 ), asyncElsif,  ...
asyncbody,  ...
sync_statement,  ...
spaces( 4 ), 'END IF; \n',  ...
spaces( 2 ), 'END PROCESS ', processName, ';\n\n' ];
end 


if strcmpi( functionMode, 'DESERIALIZER' )
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( output ), ' <= ', hdlsignalname( shiftreg ), ';\n' ];

if ~isempty( outvld )
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( outvld ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( regsize - 1 ), ');\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( outvld ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( 0 ), ');\n' ];
end 
end 

elseif strcmpi( functionMode, 'SHIFTER' )
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( extOut ), ' <= ', hdlsignalname( shiftreg ), '(', num2str( regsize - 1 ), ');\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( extOut ), ' <= ', hdlsignalname( shiftreg ), '(', num2str( 0 ), ');\n' ];
end 
else 
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( output ), ' <= ', hdlsignalname( shiftreg ), '(', num2str( regsize - 1 ), ');\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( output ), ' <= ', hdlsignalname( shiftreg ), '(', num2str( 0 ), ');\n' ];
end 
if ~isempty( outvld )
if strcmpi( shiftmode, 'SHIFTLEFT' )
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( outvld ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( regsize - 1 ), ');\n' ];
else 
hdlbody = [ hdlbody,  ...
'  ', hdlsignalname( outvld ), ' <= ', hdlsignalname( dvldreg ), '(', num2str( 0 ), ');\n' ];
end 
end 
end 

hdlbody = [ hdlbody,  ...
' \n' ];

hdlsequentialcontext( false );











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

function space = spaces( indent )
space = fix( ' ' ) * ones( 1, indent );

function asyncbody = scalarAsyncBody( outname, ICstr )
asyncbody = [ outname, ' <= ', ICstr, ';\n' ];




% Decoded using De-pcode utility v1.2 from file /tmp/tmpInQyHf.p.
% Please follow local copyright laws when handling this file.

