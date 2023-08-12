classdef ComponentVariables




properties ( Access = private )
Variables = table( string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ), string.empty( 0, 1 ) ...
, 'VariableNames', [ "ID", "Label", "DefaultValue", "DefaultValueSize", "DefaultUnit", "DefaultPriority" ] );
end 

properties ( Dependent )
IDs
Labels
DefaultValues
DefaultValuesSize
DefaultUnits
DefaultPriorities
end 

methods 
function obj = addVariables( obj, id, label, defaultValue, defaultValueSize, defaultUnit, defaultPriority )

R36
obj{ mustBeScalarOrEmpty, mustBeNonempty }
id( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
label( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultValue( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultValueSize( :, 1 )string{ mustBeMember( defaultValueSize, [ "1", "P", "S", "CellCount", "TotalNumModels" ] ), mustBeVector }
defaultUnit( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultPriority( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
end 

variablesToAdd = table( id, label, defaultValue, defaultValueSize, defaultUnit, defaultPriority ...
, 'VariableNames', [ "ID", "Label", "DefaultValue", "DefaultValueSize", "DefaultUnit", "DefaultPriority" ] );
obj.Variables = [ obj.Variables;variablesToAdd ];
end 

function compositeComponentVariables = getCompositeComponentVariables( obj, factor )

compositeComponentVariables = simscape.battery.builder.internal.export.CompositeComponentVariables( obj, factor );
end 

function obj = mergeVariables( obj1, obj2 )

R36
obj1{ mustBeScalarOrEmpty, mustBeNonempty }
obj2( 1, 1 ){ mustBeA( obj2, "simscape.battery.builder.internal.export.ComponentVariables" ), mustBeScalarOrEmpty }
end 
obj = obj1;
obj.Variables = [ obj1.Variables;obj2.Variables ];
end 

function ids = get.IDs( obj )

ids = obj.Variables.ID;
end 

function labels = get.Labels( obj )

labels = obj.Variables.Label;
end 

function defaultValues = get.DefaultValues( obj )

defaultValues = obj.Variables.DefaultValue;
end 

function defaultValuesSize = get.DefaultValuesSize( obj )

defaultValuesSize = obj.Variables.DefaultValueSize;
end 

function defaultUnits = get.DefaultUnits( obj )

defaultUnits = obj.Variables.DefaultUnit;
end 

function defaultPriorities = get.DefaultPriorities( obj )

defaultPriorities = obj.Variables.DefaultPriority;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyQlrcI.p.
% Please follow local copyright laws when handling this file.

