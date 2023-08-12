function setOptionValue( obj, optionID, optionValue )





if strcmp( optionValue, obj.get( optionID ) )
return ;
end 
if strcmp( optionValue, 'Microsemi Libero SoC' )
optionValue = 'Microchip Libero SoC';
end 


choice = obj.getOptionChoice( optionID );



if length( choice ) == 1 && isempty( choice{ 1 } ) && ~isempty( optionValue )
error( message( 'hdlcommon:workflow:InvalidOptionID', optionID ) );
end 

try 


downstream.tool.validateOptionChoice( optionValue, choice, optionID );
catch me


if strcmpi( optionID, 'ExecutionMode' )


errStr = 'ProcessorFPGASynchronization';
error( message( 'hdlcommon:workflow:DownstreamInvalidValue', optionValue, errStr, errStr, sprintf( '%s; ', choice{ : } ) ) );
end 

if strcmpi( optionID, 'Tool' )

if obj.isHLSWorkflow
obj.setToolName( optionValue );
return ;
end 
if obj.isGenericWorkflow || obj.isBoardEmpty
availableToolList = obj.hAvailableToolList.getToolNameList;



if isempty( intersect( optionValue, availableToolList, 'stable' ) )
if isempty( availableToolList )
availableToolStr = obj.NoAvailableToolStr;
else 
availableToolStr = sprintf( '%s; ', availableToolList{ : } );
end 

setupToolMsg = obj.printSetupToolMsg;
error( message( 'hdlcommon:workflow:ToolNotAvailable', optionValue, availableToolStr, setupToolMsg ) );
end 

else 
boardName = obj.get( 'Board' );
requiredToolList = obj.getRequiredTool( boardName );





if obj.isToolInBoardRequiredToolList( optionValue, boardName )
availableToolList = obj.hAvailableToolList.getToolNameList;
if isempty( intersect( optionValue, availableToolList, 'stable' ) )
availReqToolList = intersect( requiredToolList, availableToolList, 'stable' );
if isempty( availReqToolList )
availableToolStr = obj.NoAvailableToolStr;
else 
availableToolStr = sprintf( '%s; ', availReqToolList{ : } );
end 

setupToolMsg = obj.printSetupToolMsg;
error( message( 'hdlcommon:workflow:ToolNotAvailableBoardSelected', optionValue, boardName, availableToolStr, setupToolMsg ) );
end 


else 
requiredToolVersionList = obj.getRequiredToolVersion( boardName );
for ii = 1:length( requiredToolList )
requiredTool = requiredToolList{ ii };
if ~isempty( requiredToolVersionList )
requiredToolVersion = sprintf( ' %s', requiredToolVersionList{ ii } );
else 
requiredToolVersion = '';
end 
if ii == 1
requiredToolStr = sprintf( '%s%s', requiredTool, requiredToolVersion );
else 
requiredToolStr = sprintf( '%s, %s%s', requiredToolStr, requiredTool, requiredToolVersion );
end 
end 

setupToolMsg = obj.printSetupToolMsg;
error( message( 'hdlcommon:workflow:ToolNotAvailableBoardMismatch', boardName, requiredToolStr, optionValue, setupToolMsg ) );
end 
end 
end 


rethrow( me )
end 

if strcmpi( optionID, 'Workflow' )
obj.setWorkflowName( optionValue )

elseif strcmpi( optionID, 'Board' )

obj.setBoardName( optionValue );

elseif strcmpi( optionID, 'Tool' )

obj.setToolName( optionValue );

elseif strcmpi( optionID, 'SimulationTool' )

hOption = obj.getOption( optionID );


hOption.Value = optionValue;

elseif strcmpi( optionID, 'ExecutionMode' )

obj.hTurnkey.setExecutionMode( optionValue );

else 

hOption = obj.getOption( optionID );


hOption.Value = optionValue;


if obj.cmdDisplay && ~obj.cliDisplay
fprintf( 'Option ''%s'' is assigned with new value ''%s''.\n', optionID, optionValue );
end 


workflowID = hOption.WorkflowID;
if strcmpi( workflowID, 'Device' )

switch optionID
case 'Family'
devicelist = obj.hToolDriver.hDevice.listDevice( optionValue );
if ~isempty( devicelist )
obj.setOptionValue( 'Device', devicelist{ 1 } );
else 
obj.setOptionValue( 'Device', '' )
end 
case 'Device'
plist = obj.hToolDriver.hDevice.listPackage( get( obj, 'Family' ), optionValue );
slist = obj.hToolDriver.hDevice.listSpeed( get( obj, 'Family' ), optionValue );

if ~isempty( plist )
obj.setOptionValue( 'Package', plist{ 1 } );
else 
obj.setOptionValue( 'Package', '' )
end 
if ~isempty( slist )
obj.setOptionValue( 'Speed', slist{ 1 } );
else 
obj.setOptionValue( 'Speed', '' )
end 
otherwise 
end 
obj.hToolDriver.hEngine.CurrentStage = obj.hToolDriver.hEngine.sidx.Start;
else 

if obj.hToolDriver.hEngine.sidx.( workflowID ) <= obj.hToolDriver.hEngine.CurrentStage
obj.hToolDriver.hEngine.CurrentStage = obj.hToolDriver.hEngine.sidx.( workflowID ) - 1;
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpkn4KtP.p.
% Please follow local copyright laws when handling this file.

