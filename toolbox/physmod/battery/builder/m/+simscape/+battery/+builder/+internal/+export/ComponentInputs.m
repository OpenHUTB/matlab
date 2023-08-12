classdef ComponentInputs




properties ( Access = private )
Inputs = table( string.empty, string.empty, string.empty, string.empty, string.empty ...
, 'VariableNames', [ "ID", "Label", "DefaultValue", "DefaultUnit", "ScalingVariable" ] );
end 

properties ( Dependent )
IDs
Labels
DefaultValues
DefaultUnits
end 

methods 
function obj = addInputs( obj, id, label, defaultValue, defaultUnit )

R36
obj{ mustBeScalarOrEmpty, mustBeNonempty }
id( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
label( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultValue( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultUnit( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
end 

inputsToAdd = table( id, label, defaultValue, defaultUnit, repmat( "", size( id ) ) ...
, 'VariableNames', [ "ID", "Label", "DefaultValue", "DefaultUnit", "ScalingVariable" ] );
obj.Inputs = [ obj.Inputs;inputsToAdd ];
end 

function obj = addDimensionScalingForInput( obj, id, scalingVariable )

R36
obj
id string{ mustBeTextScalar, mustBeNonzeroLengthText }
scalingVariable string{ mustBeTextScalar }
end 
hasId = obj.IDs == id;
obj.Inputs.ScalingVariable( hasId ) = scalingVariable;
end 

function obj = mergeInputs( obj1, obj2 )

R36
obj1{ mustBeScalarOrEmpty, mustBeNonempty }
obj2( 1, 1 ){ mustBeA( obj2, "simscape.battery.builder.internal.export.ComponentInputs" ), mustBeScalarOrEmpty }
end 
obj = obj1;
obj.Inputs = [ obj1.Inputs;obj2.Inputs ];
end 

function ids = get.IDs( obj )

ids = obj.Inputs.ID;
end 

function labels = get.Labels( obj )

labels = obj.Inputs.Label;
end 

function defaultValues = get.DefaultValues( obj )

hasScalingVariable = ~ismember( obj.Inputs.ScalingVariable, "" );
defaultValues = obj.Inputs.DefaultValue;
defaultValues( hasScalingVariable ) = "repmat(" + defaultValues( hasScalingVariable ) ...
 + "," + obj.Inputs.ScalingVariable( hasScalingVariable ) + ",1)";
end 

function defaultUnits = get.DefaultUnits( obj )

defaultUnits = obj.Inputs.DefaultUnit;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMUdsRC.p.
% Please follow local copyright laws when handling this file.

