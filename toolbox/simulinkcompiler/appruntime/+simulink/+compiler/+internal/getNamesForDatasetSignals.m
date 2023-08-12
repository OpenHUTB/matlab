function signalsAndNamesStruct = getNamesForDatasetSignals( dataset )




signalsAndNamesStruct = struct( 'signalObject', {  }, 'signalNames', {  } );
numSigs = dataset.numElements;





for sigIdx = 1:numSigs

signal = dataset.get( sigIdx );

if isa( signal, "timeseries" )
values = signal;
signalData = [  ];
elseif isa( signal, 'Simulink.SimulationData.Signal' )
values = signal.Values;
signalData = extractSimulinkSignalData( signal );
else 
error( message( "simulinkcompiler:genapp:UnsupportedSignalFormat" ) );
end 

if isa( values, 'timeseries' )




currDatasetMeta = getTimeseriesSignalData(  ...
values, signalData, sigIdx, numSigs );

elseif isa( values, 'timetable' )


ttIdx = 1;numTT = 1;prefix = "";
currDatasetMeta = getTimetableSignalData( values, signalData,  ...
ttIdx, numTT, prefix );

elseif iscell( values )




currDatasetMeta = getCellSignalData( values, signalData );


elseif isstruct( values )







currDatasetMeta = getStructSignalData( values, signalData );

end 

signalsAndNamesStruct = mergeStructArrays( signalsAndNamesStruct,  ...
currDatasetMeta );
end 
end 



function tsSigData = getTimeseriesSignalData( timeseries, signalData,  ...
sigIdx, numSigs )



tsSigData = struct( 'signalObject', {  }, 'signalNames', {  } );
numTS = numel( timeseries );

for tsIdx = 1:numTS
currTSmeta = getScalarTimeseriesSignalData(  ...
timeseries( tsIdx ), signalData, tsIdx, numTS, "", sigIdx, numSigs );
tsSigData = mergeStructArrays( tsSigData, currTSmeta );
end 
end 



function tsSigData = getScalarTimeseriesSignalData(  ...
inTimeseries, signalData, tsIdx, numTS, prefix, sigIdx, numSigs )

R36
inTimeseries
signalData
tsIdx
numTS
prefix
sigIdx = 1
numSigs = 1
end 



data = inTimeseries.Data;
numLines = size( data, 2 );

signalPrefix = "";
substitueSigName = getSubstituteSigNameFromSigData( signalData );
isSubstituteSigNameEmpty = isequal( substitueSigName, "" );

if isTimeseriesNameEmpty( inTimeseries ) &&  ...
( isempty( signalData ) || isSubstituteSigNameEmpty )

signalPrefix = "signal";
if numSigs > 1
signalPrefix = signalPrefix + sigIdx;
end 
end 

if isTimeseriesNameEmpty( inTimeseries )
inTimeseries.Name = substitueSigName;

if numTS > 1

inTimeseries.Name = inTimeseries.Name + prefix + "(" + tsIdx + ")";

if isSubstituteSigNameEmpty && ~isequal( signalPrefix, "" )
inTimeseries.Name = signalPrefix + inTimeseries.Name;
end 
elseif isSubstituteSigNameEmpty
inTimeseries.Name = signalPrefix;
end 
else 
inTimeseries.Name = inTimeseries.Name + prefix;
end 

tsSigData.signalObject = inTimeseries;
names( numLines ) = "";

if numLines > 1
for idx = 1:numLines
names( idx ) = inTimeseries.Name + prefix + "(" + idx + ")";
end 
tsSigData.signalNames = names;
else 
tsSigData.signalNames = string( inTimeseries.Name );
end 
end 



function ttSigData = getTimetableSignalData( inTimetable, signalData,  ...
ttIdx, numTT, prefix )



numLines = numel( inTimetable.Properties.VariableNames );
names( numLines ) = "";

ttSigData.signalObject = inTimetable;

for idx = 1:numLines
names( idx ) = signalData.sigName + prefix;

if isequal( signalData.sigName, "" )
names( idx ) =  ...
string( inTimetable.Properties.VariableNames{ idx } ) + prefix;
end 

if numTT > 1

names( idx ) = names( idx ) + "(" + ttIdx + ")";
end 

if ~isequal( signalData.sigName, "" )

names( idx ) = names( idx ) + "(" + idx + ")";
end 
end 

ttSigData.signalNames = names;
end 



function cellSigData = getCellSignalData( inCell, signalData )
cellSigData = struct( 'signalObject', {  }, 'signalNames', {  } );

numTT = numel( inCell );

for ttIdx = 1:numTT
prefix = "";
currTimetable = inCell{ ttIdx };
currCellMeta = getTimetableSignalData( currTimetable,  ...
signalData, ttIdx, numTT, prefix );
cellSigData = mergeStructArrays( cellSigData, currCellMeta );
end 
end 



function structSigData = getStructSignalData( inStruct, signalData )
structSigData = struct( 'signalObject', {  }, 'signalNames', {  } );
numStructs = numel( inStruct );

for structIdx = 1:numStructs
currStuct = inStruct( structIdx );
currStructMeta = getScalarStructSignalData( currStuct,  ...
signalData, structIdx, numStructs );
structSigData = mergeStructArrays( structSigData, currStructMeta );
end 
end 



function tsStructSigData = getScalarStructSignalData(  ...
inStruct, signalData, structIdx, numStructs )

tsStructSigData = struct( 'signalObject', {  }, 'signalNames', {  } );
fieldNames = string( fieldnames( inStruct ) );
fieldNames = reshape( fieldNames, 1, numel( fieldNames ) );

if isStructOf( 'timeseries', inStruct )
processFcn = 'getScalarTimeseriesSignalData';
elseif isStructOf( 'timetable', inStruct )
processFcn = 'getTimetableSignalData';
end 

numFields = numel( fieldNames );

for fIdx = 1:numFields
fName = fieldNames( fIdx );
fieldVal = inStruct.( fName );
prefix = "";

if numStructs > 1
prefix = "(" + structIdx + ")";
end 

currStructFieldMeta = feval( processFcn, fieldVal,  ...
signalData, fIdx, numFields, prefix );%#ok<FVAL> 
tsStructSigData = mergeStructArrays( tsStructSigData,  ...
currStructFieldMeta );
end 
end 



function TF = isStructOf( dataType, inStruct )
fieldNames = fields( inStruct );
TF = all( cellfun( @( fName )isa( inStruct.( fName ), dataType ), fieldNames ) );
end 



function outStruct = mergeStructArrays( inStructArr1, inStructArr2 )
fieldNames = string( fieldnames( inStructArr1 ) );
fieldNames = reshape( fieldNames, 1, numel( fieldNames ) );

outStruct = inStructArr1;
startIdx = numel( outStruct );

for idxInArr = 1:numel( inStructArr2 )
for fieldIdx = 1:numel( fieldNames )
fName = fieldNames( fieldIdx );
outStruct( startIdx + idxInArr ).( fName ) =  ...
inStructArr2( idxInArr ).( fName );
end 
end 
end 



function signalData = extractSimulinkSignalData( signal )

blockPath = "";
if signal.BlockPath.getLength > 0
blockPath = signal.BlockPath.getBlock( 1 );
end 
signalData.srcBlkPath = blockPath;
signalData.srcBlkPort = signal.PortIndex;
signalData.sigName = string( signal.Name );

if isempty( signal.Name )
signalData.sigName = string( signal.PropagatedName );
end 
end 



function TF = isTimeseriesNameEmpty( inTimeseries )
TF = isequal( inTimeseries.Name, "" ) || isequal( inTimeseries.Name, "unnamed" );
end 



function sigName = getSubstituteSigNameFromSigData( signalData )
sigName = "";
if isempty( signalData )
return ;
end 

if isequal( signalData.sigName, "" )
if isequal( signalData.srcBlkPath, "" )
return ;
end 
sigName = extractAfter( signalData.srcBlkPath, "/" ) +  ...
":" + num2str( signalData.srcBlkPort );
else 
sigName = signalData.sigName;
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpvhhzl6.p.
% Please follow local copyright laws when handling this file.

