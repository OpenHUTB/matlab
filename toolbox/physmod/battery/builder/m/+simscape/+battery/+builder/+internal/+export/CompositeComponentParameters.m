classdef CompositeComponentParameters




properties ( Access = protected )
Parameters = table( string.empty, string.empty, string.empty, string.empty, string.empty, string.empty, string.empty, logical.empty ...
, 'VariableNames', [ "Value", "ID", "Label", "DefaultValue", "DefaultUnit", "Group", "Scaling", "IsComponentParameter" ] );
end 

properties ( Dependent )
IDs
Labels
DefaultValues
DefaultUnits
Groups
Scaling
Values
end 

methods 
function obj = setDefaultComponentParameters( obj, componentParameters )

R36
obj
componentParameters( 1, 1 ){ mustBeA( componentParameters, "simscape.battery.builder.internal.export.ComponentParameters" ) }
end 

parameterValue = componentParameters.IDs;
isScaledParameter = componentParameters.Scaling ~= "1";
if any( isScaledParameter )
parameterValue( isScaledParameter ) = parameterValue( isScaledParameter ).append( "Scaled" );
end 
obj.Parameters = table( parameterValue, componentParameters.IDs, componentParameters.Labels, componentParameters.DefaultValues,  ...
componentParameters.DefaultUnits, componentParameters.Groups, componentParameters.Scaling, true( size( componentParameters.IDs ) ),  ...
'VariableNames', [ "Value", "ID", "Label", "DefaultValue", "DefaultUnit", "Group", "Scaling", "IsComponentParameter" ] );
end 

function obj = setParameterSpecification( obj, id, specification, value )

R36
obj
id string{ mustBeTextScalar }
specification string{ mustBeTextScalar, mustBeMember( specification, [ "Value", "ID", "Label", "DefaultValue", "DefaultUnit", "Group", "IsComponentParameter" ] ) }
value
end 
parameterIndex = obj.Parameters.ID == id;
if ( any( parameterIndex ) )
obj.Parameters{ parameterIndex, specification } = value;
end 
end 

function componentParameters = getParentComponentParameters( obj )

componentParametersTable = obj.Parameters( obj.Parameters.IsComponentParameter, : );
componentParameters = simscape.battery.builder.internal.export.ComponentParameters(  );

parameterNames = componentParametersTable.Value;
isScaledParameter = componentParametersTable.Scaling ~= "1";
parameterNames( isScaledParameter ) = componentParametersTable.ID( isScaledParameter );
componentParameters = componentParameters.addParameters( parameterNames,  ...
componentParametersTable.Label, componentParametersTable.DefaultValue, componentParametersTable.DefaultUnit,  ...
componentParametersTable.Group, componentParametersTable.Scaling );
end 

function values = get.Values( obj )

values = obj.Parameters.Value;
end 

function ids = get.IDs( obj )

ids = obj.Parameters.ID;
end 

function labels = get.Labels( obj )

labels = obj.Parameters.Label;
end 

function defaultValues = get.DefaultValues( obj )

defaultValues = obj.Parameters.DefaultValue;
end 

function defaultUnits = get.DefaultUnits( obj )

defaultUnits = obj.Parameters.DefaultUnit;
end 

function groups = get.Groups( obj )

groups = obj.Parameters.Group;
end 

function scaling = get.Scaling( obj )

scaling = obj.Parameters.Scaling;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzg_b2A.p.
% Please follow local copyright laws when handling this file.

