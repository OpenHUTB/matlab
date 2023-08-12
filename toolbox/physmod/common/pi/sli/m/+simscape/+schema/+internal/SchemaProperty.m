classdef SchemaProperty





properties 
Label( 1, 1 )string
Value( 1, 1 )string
Tooltip( 1, 1 )string
Children( 1, : )simscape.schema.internal.SchemaProperty
end 
methods 
function obj = SchemaProperty( props )
R36
props.Label( 1, 1 )string
props.Value( 1, 1 )string = string( missing )
props.Tooltip( 1, 1 )string = string( missing )
props.Children( 1, : )simscape.schema.internal.SchemaProperty
end 
obj.Label = props.Label;
obj.Value = props.Value;
obj.Tooltip = props.Tooltip;
if isfield( props, 'Children' )
obj.Children = props.Children;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZDUDr_.p.
% Please follow local copyright laws when handling this file.

