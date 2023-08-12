classdef XCPMemoryConfigurator < handle




properties ( GetAccess = private, SetAccess = immutable )
TargetConfig
end 

properties ( Access = public )


MaxODTEntryNumber = 255;




NumBytesPerMultiWordChunk = 8;
PaddingFactor = 2;

















SizeOfAdditionalFields = 80;

SizeOfDAQStruct = 32;
SizeOfODTStruct = 48;
SizeOfODTEntryStruct = 8;
SizeOfNativeEnum = 8;
SizeOfTargetDouble = 8
end 

properties ( Access = private )
ModelName;
UseInternalDefines;
end 

methods ( Access = public )
function obj = XCPMemoryConfigurator( modelName, targetConfiguration, opts )
R36
modelName, 
targetConfiguration( 1, 1 )coder.internal.xcp.XCPTargetConfiguration
opts.UseInternalDefines( 1, 1 )logical = false
end 
obj.ModelName = modelName;
obj.TargetConfig = targetConfiguration;
obj.UseInternalDefines = opts.UseInternalDefines;
end 

function [ dataStructures, pktBuffers, numDAQsWithReservedPool, maxEventIdForPools ] =  ...
getMemoryParameters( obj, maxSampleCount, opts )


R36
obj( 1, 1 ), 
maxSampleCount( 1, 1 )double, 
opts.sizeOfLoggingBuffer double = [  ], 
opts.daqCopies( 1, 1 ){ mustBeInteger, mustBePositive } = 3






opts.additionalDAQs( 1, 1 ){ mustBeInteger, mustBeNonnegative } = 3, 
opts.additionalODTs( 1, 1 ){ mustBeInteger, mustBeNonnegative } = 3, 
opts.additionalEntries( 1, 1 ){ mustBeInteger, mustBeNonnegative } = 3, 
end 

[ daqs, missingSignals, maxEventIdForPools ] = obj.getDAQs( true, maxSampleCount );

[ numDAQs, maxODTsInDAQ, totODTs, maxEntriesInODT, poolSizeDTOs ] =  ...
obj.estimateMemoryParams( daqs, missingSignals, opts.daqCopies );

if ~isempty( opts.sizeOfLoggingBuffer )
poolSizeDTOs = opts.sizeOfLoggingBuffer;
end 



numDAQsWithReservedPool = max( numDAQs, 1 );

dataStructures = struct(  ...
numDAQs = numDAQs + opts.additionalDAQs,  ...
maxODTsInDAQ = max( maxODTsInDAQ, opts.additionalODTs ),  ...
totODTs = totODTs + opts.additionalODTs,  ...
maxEntriesInODT = max( maxEntriesInODT, opts.additionalEntries ) );

pktBuffers = struct(  ...
DTOs = poolSizeDTOs,  ...
 ...
CTOs = 2 * ( double( obj.TargetConfig.MaxCTOSize ) + obj.SizeOfAdditionalFields ) );

end 

function addDefines( obj, buildInfo, maxSampleCount, opts )


R36
obj( 1, 1 ), 
buildInfo( 1, 1 ), 
maxSampleCount( 1, 1 )double, 
opts.sizeOfLoggingBuffer double = [  ], 
opts.daqCopies( 1, 1 ){ mustBeInteger, mustBePositive } = 3






opts.additionalDAQs( 1, 1 ){ mustBeInteger, mustBeNonnegative } = 3, 
opts.additionalODTs( 1, 1 ){ mustBeInteger, mustBeNonnegative } = 3, 
opts.additionalEntries( 1, 1 ){ mustBeInteger, mustBeNonnegative } = 3, 
opts.printSummary( 1, 1 )logical = false, 
end 

[ dataStructures, pktBuffers, numDAQsWithReservedPool, maxEventId ] =  ...
obj.getMemoryParameters(  ...
maxSampleCount,  ...
sizeOfLoggingBuffer = opts.sizeOfLoggingBuffer,  ...
daqCopies = opts.daqCopies,  ...
additionalDAQs = opts.additionalDAQs,  ...
additionalODTs = opts.additionalODTs,  ...
additionalEntries = opts.additionalEntries );

[ mainMemBlocks, reservedPools ] = obj.getMemoryConfiguration(  ...
dataStructures.numDAQs,  ...
dataStructures.maxODTsInDAQ,  ...
dataStructures.totODTs,  ...
dataStructures.maxEntriesInODT,  ...
pktBuffers.DTOs,  ...
pktBuffers.CTOs );

obj.addMainMemoryDefines( buildInfo, mainMemBlocks.Numbers, mainMemBlocks.Sizes );

obj.addReservedPoolsDefines( buildInfo, reservedPools.TotalSize, reservedPools.Number );

obj.addDaqDefines( buildInfo, numDAQsWithReservedPool, opts.daqCopies, maxEventId );

if opts.printSummary
obj.printSummary( mainMemBlocks, dataStructures, pktBuffers );
end 
end 

function [ daqs, missing, maxEventId ] = getDAQs( obj, isPackedMode, duration )


buildDir = RTW.getBuildDir( obj.ModelName ).BuildDirectory;
mf0Model = obj.populateMF0Model( isPackedMode, duration, buildDir );



clear extmode_task_info
[ taskInfo, numTasks, isDeploymentDiagram ] = coder.internal.xcp.getExtModeTaskInfo(  ...
buildDir, 'extmode_task_info' );

if numTasks > 0
maxEventId = numTasks - 1;
else 
maxEventId = 0;
end 

updater = coder.internal.xcp.CodeDescriptorUpdater(  ...
buildDir, [  ], taskInfo, numTasks, isDeploymentDiagram, 1 );
updater.updateTID(  );

targetConnection = obj.getTargetConnection(  );

xcpTargetParameters = obj.getTargetConfigurationAsStruct(  );

[ daqs, missing ] = targetConnection.getDAQConfiguration(  ...
buildDir,  ...
xcpTargetParameters,  ...
mf0Model,  ...
obj.SizeOfNativeEnum,  ...
obj.PaddingFactor );
end 

function [ mainMem, reservedPools ] = getMemoryConfiguration( obj,  ...
numDAQs, maxODTsInDAQ, totODTs, maxEntriesInODT, reservedPoolForDTOs, reservedPoolsForCTOs )

R36
obj( 1, 1 ), 
numDAQs( 1, 1 ), 
maxODTsInDAQ( 1, 1 ), 
totODTs( 1, 1 ), 
maxEntriesInODT( 1, 1 ), 
reservedPoolForDTOs( 1, 1 ), 

reservedPoolsForCTOs( 1, 1 ) =  ...
2 * ( double( obj.TargetConfig.MaxCTOSize ) + obj.SizeOfAdditionalFields )
end 

mainMem = struct(  ...
Numbers = [  ...
1 ...
, numDAQs ...
, totODTs ],  ...
Sizes = [  ...
 ...
numDAQs * obj.SizeOfDAQStruct ...
 ...
, maxODTsInDAQ * obj.SizeOfODTStruct ...
 ...
, maxEntriesInODT * obj.SizeOfODTEntryStruct ] );

reservedPools = struct(  ...
Number = numDAQs + 1,  ...
TotalSize = reservedPoolsForCTOs + reservedPoolForDTOs );
end 
end 

methods ( Access = private )

function targetConnection = getTargetConnection( obj )


switch obj.TargetConfig.Transport
case Simulink.ExtMode.Transports.XCPSerial.Transport
targetConnection =  ...
coder.internal.connectivity.XcpTargetConnection( 'XcpOnSerial' );
case Simulink.ExtMode.Transports.XCPTCP.Transport
targetConnection =  ...
coder.internal.connectivity.XcpTargetConnection( 'XcpOnTCPIP' );
case Simulink.ExtMode.Transports.XCPCAN.Transport
targetConnection =  ...
coder.internal.connectivity.XcpTargetConnection( 'XcpOnCAN' );
end 
targetConnection.setSlaveInfo(  ...
"numBitsPerDouble", obj.SizeOfTargetDouble * 8 );
targetConnection.setSlaveInfo(  ...
"numBytesPerMultiWordChunk", obj.NumBytesPerMultiWordChunk );


isHostBased = coder.internal.isHostBasedTarget( obj.ModelName );
memUnitTransformer = coder.internal.xcp.getMemUnitTransformer(  ...
obj.ModelName, isHostBased );
if ~isempty( memUnitTransformer )
targetConnection.MemUnitTransformer = memUnitTransformer;
end 
end 

function xcpTargetParameters = getTargetConfigurationAsStruct( obj )





targetConfigProperties = properties( obj.TargetConfig );
for i = 1:numel( targetConfigProperties )
assert( ~isempty( obj.TargetConfig.( targetConfigProperties{ i } ) ), 'Invalid Target Configuration property' );
xcpTargetParameters.( targetConfigProperties{ i } ) = double( obj.TargetConfig.( targetConfigProperties{ i } ) );
end 
end 

function mf0Model = populateMF0Model( obj, isPackedMode, numContiguousSamples, buildDir )

handle = get_param( obj.ModelName, 'Handle' );
mf0Model = coder.xcp.trig.classic.getModel( handle );



classicTriggerConfig = coder.xcp.trig.classic.TriggerConfig.findConfig( mf0Model );
assert( ~isempty( classicTriggerConfig ), 'no classic trigger configuration found' );
classicTriggerConfig.SignalLoggingOverride = false;
classicTriggerConfig.Duration = uint64( numContiguousSamples );


targetConfig = coder.xcp.trig.classic.TargetConfig.findConfig( mf0Model );
if coder.internal.connectivity.featureOn( 'XcpPackedMode' )
targetConfig.UsePackedMode = isPackedMode;
else 

targetConfig.UsePackedMode = false;
end 

targetConfig.StopTime = inf;

if targetConfig.UsePackedMode
taskConfig = coder.xcp.trig.classic.TaskConfig.findConfig( mf0Model );
err = coder.internal.xcp.populateTaskConfig( taskConfig, buildDir );
if ~isempty( err )


targetConfig.UsePackedMode = false;
end 
end 

end 

function [ numDAQs, maxODTsInDAQ, totODTs, maxEntriesInODT, poolSizeDTOs ] =  ...
estimateMemoryParams( obj, daqs, missingSignals, daqCopies )








missingSigEvent = obj.divideSignals( missingSignals );
if missingSigEvent.isempty(  )
missingNotVisited = containers.Map;
else 
idMissingSig = cell2mat( missingSigEvent.keys );
missingNotVisited = containers.Map( idMissingSig, zeros( 1, numel( idMissingSig ) ) );
end 
maxEntriesInODT = 0;
maxODTsInDAQ = 0;
totODTs = 0;
poolSizeDTOs = 0;

for i = 1:numel( daqs )
odts = daqs( i ).ODT;
eventId = uint64( daqs( i ).EventId );
odtNumber = numel( odts );
totEntryNumber = sum( [ odts.EntryNumber ] );
if odtNumber > 1



odtSize = double( obj.TargetConfig.MaxDTOSize );
else 
odtSize = max( [ odts.Size ] );
end 
if missingSigEvent.isKey( eventId )
missingNotVisited.remove( eventId );
missing = missingSigEvent( eventId );


missingEntries = sum( [ missing.NumEntries ] );
totEntryNumber = totEntryNumber + missingEntries;
odtNumber = odtNumber + missingEntries;
odtSize = double( obj.TargetConfig.MaxDTOSize );
end 
poolSizeDTOs = poolSizeDTOs +  ...
( odtSize + obj.SizeOfAdditionalFields ) * odtNumber * daqCopies;



entryNumber = min( totEntryNumber, obj.MaxODTEntryNumber );
maxEntriesInODT = max( maxEntriesInODT, entryNumber );



maxODTsInDAQ = max( maxODTsInDAQ, odtNumber );
totODTs = totODTs + odtNumber;
end 


additionalIds = cell2mat( missingNotVisited.keys );
for i = 1:numel( additionalIds )
missing = missingSigEvent( additionalIds( i ) );


missingEntries = sum( [ missing.NumEntries ] );
totEntryNumber = missingEntries;
odtNumber = missingEntries;
odtSize = double( obj.TargetConfig.MaxDTOSize );

poolSizeDTOs = poolSizeDTOs +  ...
( odtSize + obj.SizeOfAdditionalFields ) * odtNumber * daqCopies;
entryNumber = min( totEntryNumber, obj.MaxODTEntryNumber );

maxEntriesInODT = max( maxEntriesInODT, entryNumber );
maxODTsInDAQ = max( maxODTsInDAQ, odtNumber );
totODTs = totODTs + odtNumber;
end 

numDAQs = numel( daqs ) + numel( additionalIds );
end 

function events = divideSignals( obj, signals )



events = containers.Map( KeyType = "uint64", ValueType = "any" );

for i = 1:numel( signals )
signal = signals( i );
id = uint64( signal.EventId );

sig = struct(  ...
Size = signal.Size,  ...
NumEntries = ceil( signal.Size / double( obj.TargetConfig.MaxODTEntrySize ) ),  ...
MaxEntrySize = min( signal.Size, double( obj.TargetConfig.MaxODTEntrySize ) ) );
if events.isKey( id )
events( id ) = [ events( id ), sig ];
else 
events( id ) = sig;
end 
end 
end 

function defines = addMainMemoryDefines( obj, buildInfo, blockNumbers, blockSizes )

defines = {  };

for i = 1:numel( blockSizes )
obj.addDefineToBuildInfo(  ...
buildInfo,  ...
[ 'XCP_MEM_BLOCK_', num2str( i ), '_SIZE' ],  ...
blockSizes( i ),  ...
obj.UseInternalDefines );
obj.addDefineToBuildInfo(  ...
buildInfo,  ...
[ 'XCP_MEM_BLOCK_', num2str( i ), '_NUMBER' ],  ...
blockNumbers( i ),  ...
obj.UseInternalDefines );
end 
end 

function addReservedPoolsDefines( obj, buildInfo, totalSize, numberOfPools )

obj.addDefineToBuildInfo(  ...
buildInfo,  ...
'XCP_MEM_RESERVED_POOLS_TOTAL_SIZE',  ...
totalSize,  ...
obj.UseInternalDefines );
obj.addDefineToBuildInfo(  ...
buildInfo,  ...
'XCP_MEM_RESERVED_POOLS_NUMBER',  ...
numberOfPools,  ...
obj.UseInternalDefines );
end 

function addDaqDefines( obj,  ...
buildInfo, numberOfDAQs, bufferingPerTimeStep, maxEventIdReservedPools )


useInternalDefines = false;
obj.addDefineToBuildInfo(  ...
buildInfo,  ...
'XCP_MEM_DAQ_RESERVED_POOL_BLOCKS_NUMBER',  ...
bufferingPerTimeStep,  ...
useInternalDefines );
obj.addDefineToBuildInfo(  ...
buildInfo,  ...
'XCP_MEM_DAQ_RESERVED_POOLS_NUMBER',  ...
numberOfDAQs,  ...
useInternalDefines );
obj.addDefineToBuildInfo(  ...
buildInfo,  ...
'XCP_MIN_EVENT_NO_RESERVED_POOL',  ...
maxEventIdReservedPools + 1,  ...
useInternalDefines );
end 
end 

methods ( Static, Access = private )

function addDefineToBuildInfo( buildInfo, define, value, useInternalDefines )


if useInternalDefines
define = [ 'INTERNAL_', define ];
end 

define = [ '-D', define, '=', num2str( value ) ];

if slsvTestingHook( 'XCPLogLevel' ) > 2
disp( [ 'XCPMemoryConfigurator: adding ', define ] );
end 

buildInfo.addDefines( define, coder.make.internal.BuildInfoGroup.DefinesOptsGroup )
end 

function printSummary( mainMemBlocks, dataStructures, pktBuffers )


totMainMemory = mainMemBlocks.Sizes * mainMemBlocks.Numbers';
disp( message(  ...
'coder_xcp:host:MemorySummary',  ...
totMainMemory,  ...
dataStructures.totODTs,  ...
dataStructures.numDAQs,  ...
dataStructures.maxODTsInDAQ,  ...
dataStructures.maxEntriesInODT,  ...
pktBuffers.CTOs + pktBuffers.DTOs,  ...
pktBuffers.CTOs,  ...
pktBuffers.DTOs ).string );

end 

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprAn1om.p.
% Please follow local copyright laws when handling this file.

