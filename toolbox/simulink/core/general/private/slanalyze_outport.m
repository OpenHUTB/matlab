function [ messageInfo, migrateInfo ] = slanalyze_outport( model )





















model = get_param( model, 'Name' );
assert( isequal( get_param( bdroot( model ), 'Handle' ), get_param( model, 'Handle' ) ) );


simulationStatus = get_param( model, 'SimulationStatus' );

lastErr = [  ];
try 
[ messageInfo, migrateInfo ] = localRunOutportAnalysis( model );
catch lastErr
end 




if strcmpi( simulationStatus, 'stopped' ) &&  ...
~strcmpi( get_param( model, 'SimulationStatus' ), 'stopped' )
localModelAPI( model, 'term' );
end 

if ~isempty( lastErr )
rethrow( lastErr )
end 

end 







function [ messageInfo, migrateInfo ] = localRunOutportAnalysis( model )


if strcmpi( get_param( model, 'SimulationStatus' ), 'stopped' )
localModelAPI( model, 'compile' );
end 





messageInfo = get_param( 0, 'OutportUpgradeMessagesForSimplifiedMode' );
migrateInfo = get_param( 0, 'OutportUpgradeDispositionsForSimplifiedMode' );
libraryInfo = struct( 'Handle', {  }, 'Instances', {  } );







numMsgsFromSlEngine = length( messageInfo );
for idx = 1:length( migrateInfo )
messageInfo( numMsgsFromSlEngine + idx ).ObjectType =  ...
migrateInfo( idx ).ObjectType;
messageInfo( numMsgsFromSlEngine + idx ).MessageType = 'Disposition';
messageInfo( numMsgsFromSlEngine + idx ).Message = migrateInfo( idx ).Disposition;
end 


libBlkErrMsgID = length( messageInfo ) + 1;
messageInfo( libBlkErrMsgID ).ObjectType = 'LibraryBlock';
messageInfo( libBlkErrMsgID ).MessageType = 'Error';
messageInfo( libBlkErrMsgID ).Message = 'Migration';

libBlkWarnMsgID = length( messageInfo ) + 1;
messageInfo( libBlkWarnMsgID ).ObjectType = 'LibraryBlock';
messageInfo( libBlkWarnMsgID ).MessageType = 'Warning';
messageInfo( libBlkWarnMsgID ).Message = 'Migration';



for idx = 1:length( messageInfo )
messageInfo( idx ).ParamsToExplore =  ...
localGetParamsToExplore( messageInfo( idx ).ObjectType );
messageInfo( idx ).Objects = [  ];
end 


for idx = 1:length( migrateInfo )
migrateInfo( idx ).ParamsToSet = eval( migrateInfo( idx ).ParamsToSet );
migrateInfo( idx ).Handles = [  ];
end 




finalMsgIDSet = cell( 1, length( messageInfo ) );
for idx = 1:length( messageInfo )
finalMsgIDSet{ idx } = [ messageInfo( idx ).ObjectType ...
, messageInfo( idx ).MessageType ...
, messageInfo( idx ).Message ];
end 

finalDispositionIDSet = cell( 1, length( migrateInfo ) );
for idx = 1:length( migrateInfo )
finalDispositionIDSet{ idx } = [ migrateInfo( idx ).ObjectType ...
, 'Disposition' ...
, migrateInfo( idx ).Disposition ];
end 






if strcmpi( get_param( model, 'UnderspecifiedInitializationDetection' ), 'Classic' )


analysisStruct = get_param( model, 'OutportUpgradeAnalysisForSimplifiedMode' );
for idx = 1:length( analysisStruct )
handle = analysisStruct( idx ).Handle;
msgIDs = analysisStruct( idx ).MessageIDs;
dispositionID = analysisStruct( idx ).DispositionID;



libBlk = get_param( handle, 'ReferenceBlock' );

for msgIdx = 1:length( msgIDs )
msgID = msgIDs( msgIdx );
messageInfo( msgID ).Objects( end  + 1 ) = handle;
end 

if isempty( libBlk )


if dispositionID > 0
migrateInfo( dispositionID ).Handles( end  + 1 ) = handle;
end 
else 


libBd = strtok( libBlk, '/' );
if ~bdIsLoaded( libBd )
load_system( libBd );
end 


libHandle = get_param( libBlk, 'Handle' );


libBlkSet = [ libraryInfo.Handle ];
libBlkIdx = find( libBlkSet == libHandle );


if isempty( libBlkIdx )
libBlkIdx = length( libBlkSet ) + 1;
libraryInfo( libBlkIdx ).Handle = libHandle;
libraryInfo( libBlkIdx ).Instances = [  ];
end 


libraryInfo( libBlkIdx ).Instances( end  + 1 ) = idx;
end 
end 


libErrorIndices = [  ];
libWarningIndices = [  ];
for libIdx = 1:length( libraryInfo )
libBlkType = get_param( libraryInfo( libIdx ).Handle, 'BlockType' );
instances = libraryInfo( libIdx ).Instances;
allDispositions = unique( [ analysisStruct( instances ).DispositionID ] );

if ( strcmpi( libBlkType, 'Outport' ) ||  ...
strcmpi( libBlkType, 'DiscreteIntegrator' ) )

if length( allDispositions ) > 1


for instIdx = 1:length( instances )
instanceInfo = analysisStruct( instances( instIdx ) );
dispositionID = instanceInfo.DispositionID;
if dispositionID > 0
handle = instanceInfo.Handle;
msgID = numMsgsFromSlEngine + dispositionID;
messageInfo( msgID ).Objects( end  + 1 ) = handle;
analysisStruct( instances( instIdx ) ).MessageIDs( end  + 1 ) = msgID;
end 
end 
errorFound = true;
else 

dispositionID = analysisStruct( instances( 1 ) ).DispositionID;
if dispositionID > 0


libHandle = libraryInfo( libIdx ).Handle;
migrateInfo( dispositionID ).Handles( end  + 1 ) = libHandle;

errorFound = false;
else 




errorFound = false;
end 
end 
else 

assert( length( allDispositions ) == 1 && ( allDispositions ==  - 1 ) );

errorFound = nestedSearchInstancesForMessageType( 'Error' );
end 

if errorFound
libErrorIndices( end  + 1 ) = libIdx;%#ok
end 


warningFound = nestedSearchInstancesForMessageType( 'Warning' );
if warningFound
libWarningIndices( end  + 1 ) = libIdx;%#ok
end 
end 


nestedComputeLibraryMessageInfo( libBlkErrMsgID, libErrorIndices );
nestedComputeLibraryMessageInfo( libBlkWarnMsgID, libWarningIndices );
clear libraryInfo
clear analysisStruct

end 





numMsgsTotal = length( messageInfo );
messageInfoOut = struct(  );
for idx = 1:numMsgsTotal
if ~isempty( messageInfo( idx ).Objects )
messageInfoOut.( finalMsgIDSet{ idx } ) = messageInfo( idx );
end 
end 
messageInfo = messageInfoOut;

migrateInfoOut = struct(  );
for idx = 1:length( migrateInfo )
if ~isempty( migrateInfo( idx ).Handles )
migrateInfoOut.( finalDispositionIDSet{ idx } ) = migrateInfo( idx );
end 
end 
migrateInfo = migrateInfoOut;





function nestedComputeLibraryMessageInfo( msgID, libInfoIndices )


messageInfo( msgID ).Objects = libraryInfo( libInfoIndices );

allInstMsgIDs = [  ];
for libIdx2 = 1:length( messageInfo( msgID ).Objects )
instances = messageInfo( msgID ).Objects( libIdx2 ).Instances;



messageInfo( msgID ).Objects( libIdx2 ).Instances =  ...
analysisStruct( instances );



for instIdx2 = 1:length( instances )
currInstMsgIDs = analysisStruct( instances( instIdx2 ) ).MessageIDs;
allInstMsgIDs = union( allInstMsgIDs, currInstMsgIDs );
messageInfo( msgID ).Objects( libIdx2 ).Instances( instIdx2 ).Messages =  ...
finalMsgIDSet( currInstMsgIDs );
end 
messageInfo( msgID ).Objects( libIdx2 ).Instances =  ...
rmfield( messageInfo( msgID ).Objects( libIdx2 ).Instances,  ...
'MessageIDs' );
end 

assert( strcmp( messageInfo( msgID ).ObjectType, 'LibraryBlock' ) );


paramsToExplore = messageInfo( msgID ).ParamsToExplore;
for msgIdx2 = 1:length( allInstMsgIDs )
paramsToExplore =  ...
union( paramsToExplore,  ...
messageInfo( allInstMsgIDs( msgIdx2 ) ).ParamsToExplore );
end 
messageInfo( msgID ).ParamsToExplore = paramsToExplore;

end 


function found = nestedSearchInstancesForMessageType( msgType )

found = false;
for instIdx2 = 1:length( instances )
msgIDs = analysisStruct( instances( instIdx2 ) ).MessageIDs;
for msgIdx2 = 1:length( msgIDs )
msgID = msgIDs( msgIdx2 );
if strcmp( messageInfo( msgID ).MessageType, msgType )
found = true;
break ;
end 
end 
if found
break ;
end 
end 

end 


end 









function localModelAPI( model, command )



if isequal( model, 'model' )
model1 = model;
clear model
evalc( [ model1, '([],[],[],''', command, ''')' ] );
else 
evalc( [ model, '([],[],[],''', command, ''')' ] );
end 

end 







function paramsToExplore = localGetParamsToExplore( objectType )

switch objectType
case 'BlockDiagram', 
paramsToExplore = { 'StrictBusMsg', 'MergeDetectMultiDrivingBlocksExec' };

case 'Outport', 
paramsToExplore = { 'InitialOutput', 'OutputWhenDisabled' };

case 'Merge', 
paramsToExplore = { 'Inputs', 'InitialOutput',  ...
'AllowUnequalInputPortWidths', 'InputPortOffsets' };
case 'ModelReference', 
paramsToExplore = { 'ModelName' };

case 'SubSystem', 
paramsToExplore = { 'PropExecContextOutsideSubsystem' };

case 'DiscreteIntegrator', 
paramsToExplore = { 'IntegratorMethod', 'InitialConditionMode',  ...
'InitialCondition' };

case 'AnyBlock', 
paramsToExplore = { 'BlockType' };

case 'LibraryBlock', 
paramsToExplore = { 'BlockType' };

otherwise , 
paramsToExplore = {  };

end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpVRIMuj.p.
% Please follow local copyright laws when handling this file.

