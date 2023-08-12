classdef DesktopModelParameterHelper < Simulink.Simulation.internal.ModelParameterHelper
properties ( Constant, Access = private )
AllModelParams = locGetAllModelParams
end 

methods ( Static )
function TF = isReadOnly( name )
TF = false;
lowerName = lower( name );
allModelParams = Simulink.Simulation.internal.DesktopModelParameterHelper.AllModelParams;
if isfield( allModelParams, lowerName )
attrs = allModelParams.( lowerName ).Attributes;
if any( strcmp( attrs, 'read-only' ) )
TF = true;
end 
end 
end 

function validateParam( name, SlObj )
R36
name
SlObj( 1, 1 )double = 0
end 

oldWarningState = warning( "off", "Simulink:Commands:GetParamDefaultBlockDiagram" );
restoreWarningState = onCleanup( @(  )warning( oldWarningState ) );





additionalSimParams = Simulink.Simulation.internal.simOnlyParams(  );

if ~any( strcmpi( additionalSimParams, name ) )


try 
get_param( SlObj, name );
catch ME

if strcmp( ME.identifier, 'Simulink:Commands:ParamUnknown' )
throwAsCaller( ME )
end 
end 
end 
end 
end 
end 

function params = locGetAllModelParams
modelParams = get_param( 0, 'ObjectParameters' );
modelParamNames = fieldnames( modelParams );
for i = 1:numel( modelParamNames )
params.( lower( modelParamNames{ i } ) ) = modelParams.( modelParamNames{ i } );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp4MINQU.p.
% Please follow local copyright laws when handling this file.

