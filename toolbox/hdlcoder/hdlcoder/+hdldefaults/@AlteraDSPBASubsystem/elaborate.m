function dspbaComp = elaborate( ~, hN, hC )



[ codegenResults, entityName, clkNames, ceNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames,  ...
rates, baseRate, blackBoxAttributes, vhdlComponentLibrary ] = getBlockInfo( hN, hC );

[ inportNames, outportNames ] = handleComplexVectorInterface( hC, codegenResults );

dspbaComp = pirelab.getDspbaComp( hN, hC.Name, hC.PirInputSignals, hC.PirOutputSignals,  ...
entityName, inportNames, outportNames, clkNames, ceNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames,  ...
rates, baseRate, blackBoxAttributes, vhdlComponentLibrary );


targetcodegen.alteradspbadriver.addDSPBACodeGenPath( vhdlComponentLibrary, codegenResults.SimulinkPath );
end 


function [ inportNames, outportNames ] = handleComplexVectorInterface( hC, codegenResults )
dspbaDataPortIndex = find( strcmpi( { codegenResults.Ports.Role }, 'data' ) );
dspbaValidPortIndex = find( strcmpi( { codegenResults.Ports.Role }, 'valid' ) );
dspbaChannelPortIndex = find( strcmpi( { codegenResults.Ports.Role }, 'channel' ) );
dspbaDataPortIndex = union( dspbaDataPortIndex, union( dspbaValidPortIndex, dspbaChannelPortIndex ) );

dspbaInputPortIndex = find( strcmpi( { codegenResults.Ports.Direction }, 'in' ) );
dspbaOutputPortIndex = find( strcmpi( { codegenResults.Ports.Direction }, 'out' ) );
dspbaInputDataPortIndex = intersect( dspbaDataPortIndex, dspbaInputPortIndex );
dspbaOutputDataPortIndex = intersect( dspbaDataPortIndex, dspbaOutputPortIndex );

tSignalsIn = hC.PirInputSignals';
tSignalsOut = hC.PirOutputSignals';

inportNames = {  };
outportNames = {  };
for i = 1:length( tSignalsIn )
if ( tSignalsIn( i ).Type.isArrayType )
for j = 1:tSignalsIn( i ).Type.Dimensions
demuxOutSignal( j ) = tSignalsIn( i );
end 
else 
demuxOutSignal = tSignalsIn( i );
end 

for j = 1:length( demuxOutSignal )
if ( demuxOutSignal( j ).Type.isComplexType || demuxOutSignal( j ).Type.BaseType.isComplexType )
idx = findDSPBAPortIdx( codegenResults.Ports, dspbaInputDataPortIndex, hC.SLInputPorts( i ).PortIndex + 1, j, true, true );
assert( idx > 0, 'PIR port cannot match DSPBA port' );
inportNames{ end  + 1 } = codegenResults.Ports( idx ).Name;
idx = findDSPBAPortIdx( codegenResults.Ports, dspbaInputDataPortIndex, hC.SLInputPorts( i ).PortIndex + 1, j, true, false );
assert( idx > 0, 'PIR port cannot match DSPBA port' );
inportNames{ end  + 1 } = codegenResults.Ports( idx ).Name;
else 
idx = findDSPBAPortIdx( codegenResults.Ports, dspbaInputDataPortIndex, hC.SLInputPorts( i ).PortIndex + 1, j, false, true );
assert( idx > 0, 'PIR port cannot match DSPBA port' );
inportNames{ end  + 1 } = codegenResults.Ports( idx ).Name;
end 
end 
end 

for i = 1:length( tSignalsOut )
if ( tSignalsOut( i ).Type.isArrayType )
for j = 1:tSignalsOut( i ).Type.Dimensions
muxInSignal( j ) = tSignalsOut( i );
end 
else 
muxInSignal = tSignalsOut( i );
end 

for j = 1:length( muxInSignal )
if ( muxInSignal( j ).Type.isComplexType || muxInSignal( j ).Type.BaseType.isComplexType )
idx = findDSPBAPortIdx( codegenResults.Ports, dspbaOutputDataPortIndex, hC.SLOutputPorts( i ).PortIndex + 1, j, true, true );
assert( idx > 0, 'PIR port cannot match DSPBA port' );
outportNames{ end  + 1 } = codegenResults.Ports( idx ).Name;
idx = findDSPBAPortIdx( codegenResults.Ports, dspbaOutputDataPortIndex, hC.SLOutputPorts( i ).PortIndex + 1, j, true, false );
assert( idx > 0, 'PIR port cannot match DSPBA port' );
outportNames{ end  + 1 } = codegenResults.Ports( idx ).Name;
else 
idx = findDSPBAPortIdx( codegenResults.Ports, dspbaOutputDataPortIndex, hC.SLOutputPorts( i ).PortIndex + 1, j, false, true );
assert( idx > 0, 'PIR port cannot match DSPBA port' );
outportNames{ end  + 1 } = codegenResults.Ports( idx ).Name;
end 
end 
end 

end 

function idx = findDSPBAPortIdx( ports, dspbaPortIdx, slPortIdx, vectIdx, isComplex, isReal )

for i = 1:length( dspbaPortIdx )
idx = dspbaPortIdx( i );
port = ports( idx );
portIdxFromDSPBA = str2double( get_param( port.SimulinkPath, 'Port' ) );
if ( slPortIdx == portIdxFromDSPBA )
if ( vectIdx == port.Vector + 1 )
if ( isComplex )
if ( isReal )
if ( port.Complex == 0 )
return ;
end 
else 
if ( port.Complex == 1 )
return ;
end 
end 
else 
assert( port.Complex == 0 );
return ;
end 
end 
end 
end 
idx = 0;
end 


function [ codegenResults, entityName, clkNames, ceNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames,  ...
rates, baseRate, blackBoxAttributes, vhdlComponentLibrary ] ...
 = getBlockInfo( hN, hC )


codegenResults = targetcodegen.alteradspbadriver.getDSPBACodeGenResults(  );
for i = 1:length( codegenResults.Islands )
portRoles = { codegenResults.Islands( i ).Ports.Role };
numClocks = length( find( strcmpi( portRoles, 'clock' ) ) );
if ( numClocks > 1 )
error( message( 'hdlcoder:validate:dspbabusclockrequrested', codegenResults.Islands( i ).SimulinkPath ) );
end 
end 

dspbaBlk = targetcodegen.alteradspbadriver.findDSPBABlks( hC.simulinkHandle );
dspbaSubsysPath = [ get_param( hC.simulinkHandle, 'Parent' ), '/', get_param( hC.simulinkHandle, 'Name' ) ];
idx = find( strcmp( dspbaBlk, dspbaSubsysPath ) );
assert( length( idx ) == 1,  ...
sprintf( 'Exactly one System Generator block is expected, while %s has %d.',  ...
dspbaSubsysPath,  ...
length( dspbaBlk ) ) );
dspbaBlk = dspbaBlk( idx );

vhdlComponentLibrary = [ hN.RefNum, '_', hC.RefNum ];

[ codegenResults, entityName, clkNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames ] = processDSPBA( dspbaBlk{ : } );
if ( ~isempty( busInputPortNames ) || ~isempty( busReadEnablePortNames ) )
warning( message( 'hdlcoder:validate:dspbaunusedslavebus', dspbaSubsysPath ) );
end 
ceNames = { '' };
rates = {  };

if ( ~isempty( hC.PirInputSignals ) )
baseRate = hC.PirInputSignals( 1 ).SimulinkRate;
elseif ( ~isempty( hC.PirOutputSignals ) )
baseRate = PirOutputSignals( 1 ).SimulinkRate;
else 
assert( 0, 'No input and output port on this DSPBAComp.' );
end 

blackBoxAttributes = true;
end 


function [ islandResults, entityName, clkNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames ] = processDSPBA( dspbaBlk )



targetDir = setupHDLCTargeDir(  );

[ dspbaFullDir, islandResults ] = dspbaCodeGen( dspbaBlk );



copyDSPBAFiles( dspbaFullDir, dspbaFullDir, targetDir, islandResults );

entityName = islandResults.TopLevelEntity;

[ clkNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames ] = renderFromDesignInfo( islandResults );
end 

function copyDSPBAFiles( dspbaFullDir, libName, targetDir, codegenResults )

dspbaTargetDir = setupDSPBATargetDir( targetDir, libName );
hdlFileList = targetcodegen.alteradspbadriver.getDSPBAHDLFiles( codegenResults, false, true );
copyFiles( dspbaFullDir, dspbaTargetDir, hdlFileList );
end 

function copyFiles( srcDir, destDir, fileList )
for i = 1:length( fileList )
filePath = fileList{ i };
dstFilePath = fullfile( destDir, filePath );
[ dstDirPath, ~ ] = fileparts( dstFilePath );
if ~exist( dstDirPath, 'dir' )
mkdir( dstDirPath );
end 
status = copyfile( fullfile( srcDir, fileList{ i } ), dstFilePath );
if ( status == 0 )
error( message( 'hdlcoder:validate:dspbacopyfailure', fullfile( dstFilePath, fileList{ i } ) ) );
end 
end 
end 

function targetDir = setupHDLCTargeDir(  )
hDrv = hdlcurrentdriver;
targetDir = hDrv.hdlGetCodegendir;
if ~exist( targetDir, 'dir' )
mkdir( targetDir );
end 
end 

function dspbaTargetDir = setupDSPBATargetDir( targetDir, libName )
dspbaTargetDir = fullfile( targetDir, libName );
if ~exist( dspbaTargetDir, 'dir' )
mkdir( dspbaTargetDir );
end 
end 

function [ dspbaFullDir, results ] = dspbaCodeGen( dspbaBlk )
codegenResults = targetcodegen.alteradspbadriver.getDSPBACodeGenResults(  );
results = codegenResults.Islands( strcmp( { codegenResults.Islands.SimulinkPath }, dspbaBlk ) );
dspbaFullDir = codegenResults.RTLPath;
end 

function [ clkNames, rstNames, busInputPortNames, busInputPortWidths, busReadEnablePortNames ] = renderFromDesignInfo( island )
clkNames = {  };
rstNames = {  };
busInputPortNames = {  };
busInputPortWidths = {  };
busReadEnablePortNames = {  };

for i = 1:length( island.Ports )
port = island.Ports( i );
if ( isClk( port ) )
clkNames{ end  + 1 } = port.Name;%#ok<AGROW>
elseif ( isRst( port ) )
rstNames{ end  + 1 } = port.Name;%#ok<AGROW>
elseif ( isDataIn( port ) )
elseif ( isDataOut( port ) )
elseif ( isBusDataIn( port ) )
busInputPortNames{ end  + 1 } = port.Name;
busInputPortWidths{ end  + 1 } = port.Width;
elseif ( isBusReadEnable( port ) )
busReadEnablePortNames{ end  + 1 } = port.Name;
elseif ( isBusDataOut( port ) )
else 
assert( false, [ 'Unknown/Unsupported Altera DSPBA Port: ', port.Name ] );
end 
end 
end 

function bool = isClk( port )
bool = strcmpi( port.Role, 'clock' );
end 

function bool = isRst( port )
bool = strcmpi( port.Role, 'resetHigh' ) || strcmpi( port.Role, 'resetLow' );
end 

function bool = isDataIn( port )
bool = strcmpi( port.Direction, 'in' ) && ( strcmpi( port.Role, 'data' ) || strcmpi( port.Role, 'valid' ) || strcmpi( port.Role, 'channel' ) );
end 

function bool = isDataOut( port )
bool = strcmpi( port.Direction, 'out' ) && ( strcmpi( port.Role, 'data' ) || strcmpi( port.Role, 'valid' ) || strcmpi( port.Role, 'channel' ) );
end 

function bool = isBusDataIn( port )
bool = strcmpi( port.Direction, 'in' ) && ( strcmpi( port.Role, 'busData' ) || strcmpi( port.Role, 'busAddress' ) || strcmpi( port.Role, 'busDataValid' ) || strcmpi( port.Role, 'busWriteEnable' ) );
end 

function bool = isBusReadEnable( port )
bool = strcmpi( port.Direction, 'in' ) && strcmpi( port.Role, 'busReadEnable' );
end 

function bool = isBusDataOut( port )
bool = strcmpi( port.Direction, 'out' ) && ( strcmpi( port.Role, 'busData' ) || strcmpi( port.Role, 'busDataValid' ) );
end 

function bool = isBusClk( port )
bool = strcmpi( port.Direction, 'in' ) && strcmpi( port.Role, 'busClock' );
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpXj7Kpi.p.
% Please follow local copyright laws when handling this file.

