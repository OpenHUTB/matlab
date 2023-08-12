function [ messageInfo, migrateInfo ] = slanalyze_discreteint( system )




model = get_param( bdroot( system ), 'Name' );



simulationStatus = get_param( model, 'SimulationStatus' );

lastErr = [  ];
try 
[ messageInfo, migrateInfo ] = localRunDiscreteIntAnalysis( system );
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








function [ messageInfo, migrateInfo ] = localRunDiscreteIntAnalysis( system )

model = get_param( bdroot( system ), 'Name' );


sess = Simulink.CMI.EIAdapter( Simulink.EngineInterfaceVal.byFiat );%#ok<NASGU>


if strcmpi( get_param( model, 'SimulationStatus' ), 'stopped' )
localModelAPI( model, 'compile' );
end 

messageInfo = get_param( 0, 'DiscreteIntegratorMessagesForSimplifiedMode' );
migrateInfo = get_param( 0, 'DiscreteIntegratorDispositionsForSimplifiedMode' );







numMsgsFromSlEngine = length( messageInfo );
for idx = 1:length( migrateInfo )
messageInfo( numMsgsFromSlEngine + idx ).ObjectType =  ...
migrateInfo( idx ).ObjectType;
messageInfo( numMsgsFromSlEngine + idx ).MessageType = 'Disposition';
messageInfo( numMsgsFromSlEngine + idx ).Message = migrateInfo( idx ).Disposition;
end 


for idx = 1:length( messageInfo )
messageInfo( idx ).ParamsToExplore = { 'IntegratorMethod',  ...
'InitialConditionMode', 'InitialCondition' };
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


analysisStruct = get_param( model, 'DiscreteIntegratorAnalysisForSimplifiedMode' );
for idx = 1:length( analysisStruct )
handle = analysisStruct( idx ).Handle;
msgIDs = analysisStruct( idx ).MessageIDs;
dispositionID = analysisStruct( idx ).DispositionID;



libBlk = get_param( handle, 'ReferenceBlock' );


instanceMsgIDs = [  ];
for msgIdx = 1:length( msgIDs )
msgID = msgIDs( msgIdx );
messageInfo( msgID ).Objects( end  + 1 ) = handle;
instanceMsgIDs( end  + 1 ) = msgID;%#ok
end 

if isempty( libBlk ) && dispositionID > 0


migrateInfo( dispositionID ).Handles( end  + 1 ) = handle;
end 

end 
clear analysisStruct

end 









numMsgsTotal = length( messageInfo );
numMsgsForBlkDiag = 0;

messageInfoOut = struct(  );
outputOrder = [ numMsgsTotal - numMsgsForBlkDiag + 1:numMsgsTotal ...
, 1:numMsgsTotal - numMsgsForBlkDiag ];
for idx = outputOrder
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









function localModelAPI( model, command )



if isequal( model, 'model' )
model1 = model;
clear model
evalc( [ model1, '([],[],[],''', command, ''')' ] );
else 
evalc( [ model, '([],[],[],''', command, ''')' ] );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpWLQEHk.p.
% Please follow local copyright laws when handling this file.

