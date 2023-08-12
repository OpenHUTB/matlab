function result = slanalyze_merge( system )

















model = get_param( bdroot( system ), 'Name' );



simulationStatus = get_param( model, 'SimulationStatus' );

lastErr = [  ];
try 
result = localRunMergeAnalysis( system );
catch e
lastErr = e;
end 




if strcmpi( simulationStatus, 'stopped' ) &&  ...
~strcmpi( get_param( model, 'SimulationStatus' ), 'stopped' )
localModelAPI( model, 'term' );
end 

if ~isempty( lastErr )
rethrow( lastErr )
end 

end 







function result = localRunMergeAnalysis( system )

model = get_param( bdroot( system ), 'Name' );


sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>


if strcmpi( get_param( model, 'SimulationStatus' ), 'stopped' )
localModelAPI( model, 'compile' );
end 

messageInfo = get_param( 0, 'MergeUsageMessagesForSimplifiedMode' );
libraryInfo = struct( 'Handle', {  }, 'Instances', {  } );

for idx = 1:length( messageInfo )
messageInfo( idx ).ParamsToExplore = { 'Inputs', 'InitialOutput',  ...
'AllowUnequalInputPortWidths', 'InputPortOffsets' };
messageInfo( idx ).Objects = [  ];
end 


libBlkErrMsgID = length( messageInfo ) + 1;
messageInfo( libBlkErrMsgID ).ObjectType = 'LibraryBlock';
messageInfo( libBlkErrMsgID ).MessageType = 'Error';
messageInfo( libBlkErrMsgID ).Message = 'Migration';
messageInfo( idx ).ParamsToExplore = { 'BlockType' };

libBlkWarnMsgID = length( messageInfo ) + 1;
messageInfo( libBlkWarnMsgID ).ObjectType = 'LibraryBlock';
messageInfo( libBlkWarnMsgID ).MessageType = 'Warning';
messageInfo( libBlkWarnMsgID ).Message = 'Migration';
messageInfo( idx ).ParamsToExplore = { 'BlockType' };


blkDiagStrictBusMsgID = length( messageInfo ) + 1;
messageInfo( blkDiagStrictBusMsgID ).ObjectType = 'BlockDiagram';
messageInfo( blkDiagStrictBusMsgID ).ParamsToExplore = { 'StrictBusMsg',  ...
'MergeDetectMultiDrivingBlocksExec' };
messageInfo( blkDiagStrictBusMsgID ).MessageType = 'Error';
messageInfo( blkDiagStrictBusMsgID ).Message = 'NeedStrictBusMode';

blkDiagMergeDiagMsgID = length( messageInfo ) + 1;
messageInfo( blkDiagMergeDiagMsgID ).ObjectType = 'BlockDiagram';
messageInfo( blkDiagStrictBusMsgID ).ParamsToExplore = { 'StrictBusMsg',  ...
'MergeDetectMultiDrivingBlocksExec' };
messageInfo( blkDiagMergeDiagMsgID ).MessageType = 'Error';
messageInfo( blkDiagMergeDiagMsgID ).Message = 'NeedMergeDiagnostics';





finalMsgIDSet = cell( 1, length( messageInfo ) );
for idx = 1:length( messageInfo )
finalMsgIDSet{ idx } = [ messageInfo( idx ).ObjectType ...
, messageInfo( idx ).MessageType ...
, messageInfo( idx ).Message ];
end 






if strcmpi( get_param( model, 'UnderspecifiedInitializationDetection' ), 'Classic' )


analysisStruct = get_param( model, 'MergeUsageAnalysisForSimplifiedMode' );
for idx = 1:length( analysisStruct )
handle = analysisStruct( idx ).Handle;
msgIDs = analysisStruct( idx ).MessageIDs;



libBlk = get_param( handle, 'ReferenceBlock' );

instanceMsgIDs = [  ];
for msgIdx = 1:length( msgIDs )
msgID = msgIDs( msgIdx );
messageInfo( msgID ).Objects( end  + 1 ) = handle;
instanceMsgIDs( end  + 1 ) = msgID;%#ok
end 

if ~isempty( libBlk )



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

instances = libraryInfo( libIdx ).Instances;
allDispositions = unique( [ analysisStruct( instances ).DispositionID ] );

assert( length( allDispositions ) == 1 && ( allDispositions ==  - 1 ) );

errorFound = nestedSearchInstancesForMessageType( 'Error' );
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



mergeBlockList = find_system( model, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'Merge' );

if ( ~isempty( mergeBlockList ) &&  ...
~strcmpi( get_param( model, 'MergeDetectMultiDrivingBlocksExec' ),  ...
'Error' ) )

messageInfo( blkDiagMergeDiagMsgID ).Objects =  ...
get_param( model, 'Handle' );
end 
end 









numMsgsTotal = length( messageInfo );
numMsgsForBlkDiag = 2;
for idx = 1:numMsgsTotal
isBlkDiagMsg = strcmp( messageInfo( idx ).ObjectType, 'BlockDiagram' );
if idx <= numMsgsTotal - numMsgsForBlkDiag;
assert( ~isBlkDiagMsg );
else 
assert( isBlkDiagMsg );
end 
end 

messageInfoOut = struct(  );
outputOrder = [ numMsgsTotal - numMsgsForBlkDiag + 1:numMsgsTotal ...
, 1:numMsgsTotal - numMsgsForBlkDiag ];
for idx = outputOrder
if ~isempty( messageInfo( idx ).Objects )
messageInfoOut.( finalMsgIDSet{ idx } ) = messageInfo( idx );
end 
end 
messageInfo = messageInfoOut;

result = messageInfo;





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










function result = localMergeTreeContainsBlockInList( node, handleList )

if ismember( node.Handle, handleList )
result = true;
else 
result = false;
for k = 1:length( node.Children )
result =  ...
localMergeTreeContainsBlockInList( node.Children( k ), handleList );
if result
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


% Decoded using De-pcode utility v1.2 from file /tmp/tmpLt9d2_.p.
% Please follow local copyright laws when handling this file.

