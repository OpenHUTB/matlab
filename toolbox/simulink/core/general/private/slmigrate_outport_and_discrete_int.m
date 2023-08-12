function msg = slmigrate_outport_and_discrete_int( system, migrateInfo, ~ )














systemName = get_param( system, 'Name' );

if strcmpi( get_param( system, 'UnderspecifiedInitializationDetection' ), 'Classic' )
dispositionSet = fieldnames( migrateInfo );





allUniqueModels = { systemName };
uniqueUpdateModels = { systemName };
for resultIdx = 1:length( dispositionSet )
currentResult = migrateInfo.( dispositionSet{ resultIdx } );
handles = currentResult.Handles;
paramsToSet = currentResult.ParamsToSet;
needUpdateHandles = [  ];
for blkIdx = 1:length( handles )
blk = handles( blkIdx );
model = bdroot( blk );
modelName = get_param( model, 'Name' );


allUniqueModels = union( allUniqueModels, { modelName } );

blkNeedsUpdate = false;
for paramIdx = 1:2:length( paramsToSet ) - 1
paramName = paramsToSet{ paramIdx };
desiredParamVal = paramsToSet{ paramIdx + 1 };
currentParamVal = get_param( blk, paramName );
if ~isequal( currentParamVal, desiredParamVal )
blkNeedsUpdate = true;
break ;
end 
end 

if blkNeedsUpdate
needUpdateHandles( end  + 1 ) = blk;%#ok

uniqueUpdateModels = union( uniqueUpdateModels, modelName );
end 
end 
migrateInfo.( dispositionSet{ resultIdx } ).Handles = needUpdateHandles;
end 


for k = 1:length( allUniqueModels )
model = allUniqueModels{ k };


simStatus = get_param( model, 'SimulationStatus' );
if ~strcmpi( simStatus, 'stopped' )
msg = DAStudio.message(  ...
'Simulink:tools:MAErrorSimulationNotStopped', model );
return ;
end 
end 


for k = 1:length( uniqueUpdateModels )
model = uniqueUpdateModels{ k };


modelFile = get_param( model, 'FileName' );
[ stat, modelAttrib ] = fileattrib( modelFile );
if ~modelAttrib.UserWrite
bdtype = get_param( model, 'BlockDiagramType' );
bdtype = [ upper( bdtype( 1 ) ), lower( bdtype( 2:end  ) ) ];
msg = DAStudio.message(  ...
[ 'Simulink:tools:MAError', bdtype, 'FileNotWritable' ], modelFile );
return ;
end 
end 


for k = 1:length( uniqueUpdateModels )
model = uniqueUpdateModels{ k };
set_param( model, 'Lock', 'off' );
end 


disp( [ '### ' ...
, DAStudio.message( 'Simulink:tools:OutportMigrateRunning', systemName ) ] );

for resultIdx = 1:length( dispositionSet )
currentResult = migrateInfo.( dispositionSet{ resultIdx } );
paramsToSet = currentResult.ParamsToSet;
if ~isempty( paramsToSet )
handles = currentResult.Handles;
for blkIdx = 1:length( handles )

set_param( handles( blkIdx ), paramsToSet{ : } );
end 
end 
end 


for k = 1:length( uniqueUpdateModels )
save_system( uniqueUpdateModels{ k } );
end 

msg = DAStudio.message( 'Simulink:tools:OutportMigrateCompleted' );


else 
msg = DAStudio.message( 'Simulink:tools:OutportMigrateNotNeeded',  ...
get_param( system, 'Name' ) );
end 

return 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprAtAkk.p.
% Please follow local copyright laws when handling this file.

