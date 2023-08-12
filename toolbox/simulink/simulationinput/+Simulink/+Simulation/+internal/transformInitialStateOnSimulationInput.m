function simInput = transformInitialStateOnSimulationInput( simInput, options )





R36
simInput( 1, 1 )Simulink.SimulationInput
options.HasConfigSetRef( 1, 1 )matlab.lang.OnOffSwitchState = "off"
end 

persistent emptyOperatingPoint;
if isempty( emptyOperatingPoint )
emptyOperatingPoint = getSimulationInputInitialStateHelper(  ).EmptyOperatingPoint;
end 

if ~isequal( simInput.InitialState, emptyOperatingPoint )
checkForDuplicateInitialStateSpecification( simInput );




if isdeployed
return ;
end 

varName = get_param( simInput.ModelName, 'InitialState' );
if ~isvarname( varName )
[ ~, varName, ~ ] = fileparts( tempname );
end 

if options.HasConfigSetRef
varWorkspace = 'global-workspace';
else 
varWorkspace = simInput.ModelName;
end 
simInput = simInput.setVariable( varName, simInput.InitialState,  ...
'Workspace', varWorkspace );

simInput = simInput.setModelParameter( 'LoadInitialState', 'on' );
simInput = simInput.setModelParameter( 'InitialState', varName );
end 
end 

function checkForDuplicateInitialStateSpecification( simInput )
if ~isempty( simInput.InitialState ) &&  ...
( hasModelParameter( simInput, 'LoadInitialState' ) ||  ...
hasModelParameter( simInput, 'InitialState' ) )
error( message( 'Simulink:Commands:SimInputRepeatedInitialStateSpec' ) );
end 
end 

function TF = hasModelParameter( simInput, paramName )
TF = false;
modelParams = simInput.ModelParameters;
if ~isempty( modelParams )
paramNames = string( { modelParams.Name } );
TF = any( strcmpi( paramNames, paramName ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpH4DxCP.p.
% Please follow local copyright laws when handling this file.

