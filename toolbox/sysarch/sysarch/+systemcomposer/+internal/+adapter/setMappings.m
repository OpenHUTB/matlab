function setMappings( blkHdl, inputElems, outputElems )






assert( iscellstr( inputElems ) && iscellstr( outputElems ) )%#ok<ISCLSTR>
assert( length( inputElems ) == length( outputElems ) );


cache = cacheConnectionsAndDeleteBEP( blkHdl );
inBlks = cache.inBlks;
outBlks = cache.outBlks;


txn2 = systemcomposer.internal.arch.internal.AsyncPluginTransaction( bdroot( blkHdl ) );




allInputPortNames = get_param( inBlks, 'PortName' );
allInputPortNames = cellstr( allInputPortNames );
availableInports = table( allInputPortNames, inBlks );

for cnt = 1:length( inputElems )
[ inputPortName, inputElemName ] = strtok( inputElems{ cnt }, '.' );
if ~isempty( inputElemName )
inputElemName = inputElemName( 2:end  );
end 



if ( any( strcmp( allInputPortNames, inputPortName ) ) )
createNewPort = 'off';
else 
createNewPort = 'on';
end 



foundIdx = strcmp( availableInports{ :, 'allInputPortNames' }, inputPortName );
inBlk = availableInports{ foundIdx, 'inBlks' };
if isempty( inBlk )

currInBlk = addBEP( blkHdl, inBlks( 1 ), inputPortName, inputElemName, createNewPort );
else 

currInBlk = inBlk( 1 );
set_param( currInBlk, 'Element', inputElemName );

availableInports = availableInports( ~foundIdx, : );
end 



outElemName = outputElems{ cnt };
[ ~, outElemName ] = strtok( outElemName, '.' );%#ok<STTOK>
outElemName = outElemName( 2:end  );

portName = get_param( outBlks( 1 ), 'PortName' );
hasOwnedOutputInterface = isBEPThatDefinesAnOwnedInterface( outBlks( 1 ) );
existingPort = [  ];
if hasOwnedOutputInterface


existingPort = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport', 'PortName', portName, 'Element', outElemName );
end 

if ( cnt <= length( outBlks ) ) && ~hasOwnedOutputInterface

set_param( outBlks( cnt ), 'Element', outElemName );
currOutBlk = outBlks( cnt );
elseif hasOwnedOutputInterface && ~isempty( existingPort )


currOutBlk = existingPort;
else 

currOutBlk = addBEP( blkHdl, outBlks( 1 ), portName, outElemName, 'off' );
end 



lH = get_param( currOutBlk, 'LineHandles' );
if ~isempty( lH.Inport ) && lH.Inport ~=  - 1
delete_line( lH.Inport );
end 
add_line( blkHdl,  ...
[ get_param( currInBlk, 'Name' ), '/1' ],  ...
[ get_param( currOutBlk, 'Name' ), '/1' ] );
end 



unusedInputPorts = availableInports{ :, 'inBlks' };
modeEnum = systemcomposer.internal.adapter.ModeEnums;
isMerge = strcmpi( systemcomposer.internal.adapter.getAdapterMode( blkHdl ), modeEnum.Merge );
if ~isempty( unusedInputPorts )
for j = 1:length( unusedInputPorts )
unusedPort = unusedInputPorts( j );
set_param( unusedPort, 'Element', '' );
if ~isMerge


unusedPortName = get_param( unusedPort, 'PortName' );
adapterBlockPath = get_param( unusedPort, 'Parent' );
msle = MSLException( 'SystemArchitecture:Adapter:UnusedInputPort', unusedPortName, adapterBlockPath );
reportAsWarning( bdroot( adapterBlockPath ), msle );
end 
end 
end 



reconnectLines( blkHdl, cache );



portsAfter = get_param( blkHdl, 'Ports' );
if isequal( portsAfter, cache.portsBefore )
set_param( blkHdl, 'PortSchema', cache.portSchema );
end 


txn2.commit(  );

end 


function cache = cacheConnectionsAndDeleteBEP( blkHdl )




txn = systemcomposer.internal.arch.internal.AsyncPluginTransaction( bdroot( blkHdl ) );


cache.portSchema = get_param( blkHdl, 'PortSchema' );
cache.portsBefore = get_param( blkHdl, 'Ports' );



inBlks = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
outBlks = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport' );

cache.conns = getInputConnections( blkHdl, inBlks );







cache.outBlks = outBlks;
if ( length( outBlks ) > 1 ) && ~isBEPThatDefinesAnOwnedInterface( outBlks( 1 ) )
delete_block( outBlks( 2:end  ) );


cache.outBlks = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Outport' );
end 




cache.inBlks = inBlks;
inPortNames = string.empty( 0, 0 );
if ( length( inBlks ) > 1 )
for idx = 1:length( inBlks )
inBlk = inBlks( idx );
inPortName = get_param( inBlk, 'PortName' );
if isempty( inPortNames ) || ~any( inPortNames == inPortName )
inPortNames( end  + 1 ) = string( inPortName );%#ok<AGROW> 
else 
delete_block( inBlk );
end 
end 


cache.inBlks = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
end 


unconnLines = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FindAll', 'on', 'Type', 'Line', 'Connected', 'off' );
delete_line( unconnLines );



lH = get_param( outBlks( 1 ), 'LineHandles' );
if ~isBEPThatDefinesAnOwnedInterface( outBlks( 1 ) ) && ~isempty( lH.Inport ) && lH.Inport ~=  - 1
delete_line( lH.Inport );
end 



txn.commit(  );

end 


function connCache = getInputConnections( blkHdl, inBlks )



connCache = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );

inportCache = containers.Map( 'KeyType', 'char', 'ValueType', 'char' );
for idx = 1:length( inBlks )
name = get_param( inBlks( idx ), 'PortName' );
number = get_param( inBlks( idx ), 'Port' );
inportCache( number ) = name;
end 


lineHdl = get_param( blkHdl, 'LineHandles' );

for idx = 1:length( lineHdl.Inport )
inp = lineHdl.Inport( idx );
if ~ishandle( inp )
continue ;
end 
try 
srcP = get_param( inp, 'SrcPortHandle' );

srcParentName = get_param( get_param( srcP, 'Parent' ), 'Name' );
srcName = [ srcParentName, '/', num2str( get_param( srcP, 'PortNumber' ) ) ];
inpName = inportCache( num2str( idx ) );

connInfo.line = inp;
connInfo.src = srcName;
connCache( inpName ) = connInfo;
catch me %#ok<NASGU>


end 
end 
end 


function newBlk = addBEP( blkHdl, src, portName, elementName, createNewPort )










existingPorts = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'PortName', portName );
if ~isempty( existingPorts )
src = existingPorts( 1 );
end 

newBlk = add_block( src,  ...
[ get_param( blkHdl, 'Parent' ), '/',  ...
get_param( blkHdl, 'Name' ), '/',  ...
'BEP' ], 'MakeNameUnique', 'on',  ...
'CreateNewPort', createNewPort,  ...
'PortName', portName, 'Element', elementName );
end 


function reconnectLines( blkHdl, cache )






inps = find_system( blkHdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'BlockType', 'Inport' );
parent = get_param( blkHdl, 'Parent' );

for idx = 1:length( inps )
inp = inps( idx );
portName = get_param( inp, 'PortName' );
if isKey( cache.conns, portName )
connInfo = cache.conns( portName );
delete_line( connInfo.line );
add_line( parent,  ...
connInfo.src,  ...
[ get_param( blkHdl, 'Name' ), '/', get_param( inp, 'Port' ) ],  ...
'autorouting', 'on' );
cache.conns.remove( portName );
end 
end 
end 


function tf = isBEPThatDefinesAnOwnedInterface( outBlk )


tf = false;
archPortImpl = systemcomposer.utils.getArchitecturePeer( outBlk );
if ~isempty( archPortImpl )
archPort = systemcomposer.internal.getWrapperForImpl( archPortImpl );
pi = archPort.Interface;
if ~isempty( pi ) && pi.isAnonymous && isequal( pi.Owner, archPort )



tf = true;
end 
end 
end 


function reportAsWarning( modelName, MSLE )


warnState = warning( 'query', 'backtrace' );
oc = onCleanup( @(  )warning( warnState ) );
warning off backtrace;
msld = MSLDiagnostic( MSLE );
msld.reportAsWarning( modelName, false );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxRJI3b.p.
% Please follow local copyright laws when handling this file.

