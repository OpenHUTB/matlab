function [ result, migrateInfo ] = slanalyze_modelref( system )
















migrateInfo.Action = 'Switch to simplified mode';
model = get_param( bdroot( system ), 'Name' );



simulationStatus = get_param( model, 'SimulationStatus' );

lastErr = [  ];
try 
result = localRunModelRefAnalysis( system );
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








function result = localRunModelRefAnalysis( system )

model = get_param( bdroot( system ), 'Name' );


sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>


if strcmpi( get_param( model, 'SimulationStatus' ), 'stopped' )
localModelAPI( model, 'compile' );
end 

messageInfo = get_param( 0, 'ModelRefMessagesForSimplifiedMode' );

simplifiedModeMsgID = length( messageInfo ) + 1;
messageInfo( simplifiedModeMsgID ).ObjectType = 'BlockDiagram';
messageInfo( simplifiedModeMsgID ).MessageType = 'Warning';
messageInfo( simplifiedModeMsgID ).Message = 'ClassicMode';

blkDiagStrictBusMsgID = length( messageInfo ) + 1;
messageInfo( blkDiagStrictBusMsgID ).ObjectType = 'BlockDiagram';
messageInfo( blkDiagStrictBusMsgID ).MessageType = 'Error';
messageInfo( blkDiagStrictBusMsgID ).Message = 'NeedStrictBusMode';

for idx = 1:length( messageInfo )
messageInfo( idx ).ParamsToExplore = { 'ModelName',  ...
'PropExecContextOutsideSubsystem', 'BlockType' };
messageInfo( idx ).Objects = [  ];
end 




finalMsgIDSet = cell( 1, length( messageInfo ) );
for idx = 1:length( messageInfo )
finalMsgIDSet{ idx } = [ messageInfo( idx ).ObjectType ...
, messageInfo( idx ).MessageType ...
, messageInfo( idx ).Message ];
end 






if strcmpi( get_param( model, 'UnderspecifiedInitializationDetection' ), 'Classic' )


messageInfo( simplifiedModeMsgID ).Objects = get_param( model, 'Handle' );


analysisStruct = get_param( model, 'ModelRefAnalysisForSimplifiedMode' );
for idx = 1:length( analysisStruct )
handle = analysisStruct( idx ).Handle;
msgIDs = analysisStruct( idx ).MessageIDs;




instanceMsgIDs = [  ];
for msgIdx = 1:length( msgIDs )
msgID = msgIDs( msgIdx );
messageInfo( msgID ).Objects( end  + 1 ) = handle;
instanceMsgIDs( end  + 1 ) = msgID;%#ok
end 
end 
clear analysisStruct

if ( strcmpi( get_param( model, 'StrictBusMsg' ), 'None' ) ||  ...
strcmpi( get_param( model, 'StrictBusMsg' ), 'Warning' ) )


messageInfo( blkDiagStrictBusMsgID ).Objects =  ...
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













































function node = localFindMergeTree( mergeHandle )

treeNode = struct( 'Handle', [  ], 'Children', [  ] );


node = treeNode;
node.Handle = mergeHandle;
node.Children = treeNode( 1:0 );


mergeBlkObj = get_param( mergeHandle, 'Object' );
for iPort = 1:length( mergeBlkObj.PortHandles.Inport )

iPortObj = get( mergeBlkObj.PortHandles.Inport( iPort ), 'Object' );
actSrcs = iPortObj.getActualSrc;
for j = 1:size( actSrcs, 1 )
blockHandle = get( actSrcs( j, 1 ), 'ParentHandle' );
blockType = get( blockHandle, 'BlockType' );
if strcmpi( blockType, 'Merge' )
new = length( node.Children ) + 1;
node.Children( new ) = localFindMergeTree( blockHandle );
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









function localModelAPI( model, command )



if isequal( model, 'model' )
model1 = model;
clear model
evalc( [ model1, '([],[],[],''', command, ''')' ] );
else 
evalc( [ model, '([],[],[],''', command, ''')' ] );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpjdHTRr.p.
% Please follow local copyright laws when handling this file.

