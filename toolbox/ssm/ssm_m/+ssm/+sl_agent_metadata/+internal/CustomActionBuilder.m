classdef CustomActionBuilder < ssm.sl_agent_metadata.internal.BusObjectToStructDataBuilder







properties ( Access = public )
ActionName( 1, : )char
end 
methods 
function obj = CustomActionBuilder( BusName, options )
R36
BusName
options.outputFileName = strcat( baseModelName( BusName ), '.seaction' )
options.actionName = baseModelName( BusName )
end 
super_args{ 1 } = BusName;
super_args{ 2 } = 'outputFileName';
super_args{ 3 } = options.outputFileName;

obj = obj@ssm.sl_agent_metadata.internal.BusObjectToStructDataBuilder( super_args{ : } );
obj.ActionName = options.actionName;
end 

function writeToFile( obj )
customAct = mathworks.scenario.simulation.CustomCommand;
customAct.name = obj.ActionName;



fNames = fieldnames( obj.StructuredData );
if ~isempty( fNames )
for idx = length( fNames ): - 1:1
attrib = mathworks.scenario.simulation.Attribute;
attrib.name = fNames{ idx };
attrib.data = ssm.sl_agent_metadata.MxArrayToProto( obj.StructuredData.( fNames{ idx } ) );
attributes( idx ) = attrib;
end 
customAct.attributes = attributes;
end 


writeToFile@ssm.sl_agent_metadata.internal.BusObjectToStructDataBuilder( obj, customAct );
end 
end 
end 

function ModelName = baseModelName( ModelName )
[ ~, ModelName, ~ ] = fileparts( ModelName );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpl7rV89.p.
% Please follow local copyright laws when handling this file.

