classdef ComponentParameters




properties ( Access = private )
Parameters = table( string.empty, string.empty, string.empty, string.empty, string.empty, string.empty ...
, 'VariableNames', [ "ID", "Label", "DefaultValue", "DefaultUnit", "Group", "Scaling" ] );
end 

properties ( Dependent )
IDs
Labels
DefaultValues
DefaultUnits
Groups
Scaling
end 

methods 
function obj = addParameters( obj, id, label, defaultValue, defaultUnit, group, scaling )

R36
obj{ mustBeScalarOrEmpty, mustBeNonempty }
id( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
label( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultValue( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
defaultUnit( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
group( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
scaling( :, 1 )string{ mustBeMember( scaling, [ "1", "P", "M" ] ) }
end 
parametersToAdd = table( id, label, defaultValue, defaultUnit, group, scaling ...
, 'VariableNames', [ "ID", "Label", "DefaultValue", "DefaultUnit", "Group", "Scaling" ] );
obj.Parameters = [ obj.Parameters;parametersToAdd ];
end 

function compositeComponentParameters = getDefaultCompositeComponentParameters( obj )

compositeComponentParameters = simscape.battery.builder.internal.export.CompositeComponentParameters(  );
compositeComponentParameters = compositeComponentParameters.setDefaultComponentParameters( obj );
end 

function obj = removeParametersWithId( obj, ids )

R36
obj{ mustBeScalarOrEmpty, mustBeNonempty }
ids( :, 1 )string{ mustBeNonzeroLengthText, mustBeVector }
end 

controlParameterIdx = ismember( obj.Parameters.ID, ids );
obj.Parameters( controlParameterIdx, : ) = [  ];
end 

function obj = mergeParameters( obj1, obj2 )

R36
obj1{ mustBeScalarOrEmpty, mustBeNonempty }
obj2( 1, 1 ){ mustBeA( obj2, "simscape.battery.builder.internal.export.ComponentParameters" ), mustBeScalarOrEmpty }
end 
obj = obj1;
obj.Parameters = [ obj1.Parameters;obj2.Parameters ];
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpM1lwL9.p.
% Please follow local copyright laws when handling this file.

