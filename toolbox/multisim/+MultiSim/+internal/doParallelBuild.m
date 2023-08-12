





function doParallelBuild( simInput, buildFcn )
R36
simInput( 1, 1 )Simulink.SimulationInput
buildFcn( 1, 1 )function_handle = @doParallelBuildForSimMode
end 

modelName = simInput.ModelName;
load_system( modelName );







if strcmp( simInput.get_param( 'EnableParallelModelReferenceBuilds' ), 'off' )
return ;
end 




[ refMdls, ~, modelrefGraph ] = find_mdlrefs( modelName, 'MatchFilter', @Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices );


refMdls = refMdls( ~strcmp( refMdls, modelName ) );

if isempty( refMdls )
return ;
end 


simMode = simInput.get_param( 'SimulationMode' );



allSimModes = [ "normal", "accelerator", "rapid-accelerator" ];
simMode = allSimModes( startsWith( allSimModes, simMode, 'IgnoreCase', true ) );
buildFcn( modelName, simMode, modelrefGraph );
end 

function doParallelBuildForSimMode( modelName, simMode, modelrefGraph )
switch simMode
case "normal"



analyzer = Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
resultAnyAccel = analyzer.analyze( modelrefGraph, 'AnyAccel', 'IncludeTopModel', false );
accelModels = resultAnyAccel.RefModel;
if ~isempty( accelModels )
set_param( modelName, 'SimulationCommand', 'update' );
end 

case "accelerator"
accelbuild( modelName );

case "rapid-accelerator"

Simulink.BlockDiagram.buildRapidAcceleratorTarget( modelName );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpL7RDiv.p.
% Please follow local copyright laws when handling this file.

