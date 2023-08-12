classdef Constraint < handle




properties 
Name( 1, 1 )string
Value
Status( 1, 1 )string{ mustBeMember( Status, [ "", "Disabled", "Hidden" ] ) } = ""
end 

methods 
function obj = Constraint( name, value, status )

obj.Name = name;
obj.Value = value;
if nargin > 2
obj.Status = status;
end 
end 

function apply( obj, cs, param, value )


R36
obj
cs
end 
R36( Repeating )
param( 1, 1 )string
value
end 

owner = cs.getPropOwner( obj.Name );



if ~isa( obj.Value, 'missing' )
if isa( obj.Value, 'function_handle' )

args = reshape( [ param';value' ], 1, length( value ) * 2 );

msg = obj.Value( "apply", owner,  ...
obj.Name, get_param( cs, obj.Name ), args{ : } );
if ~isempty( msg )

error( msg );
end 
elseif ~isequal( get_param( owner, obj.Name ), obj.Value )
owner.( obj.Name ) = obj.Value;
end 
end 


obj.applyStatus( cs );
end 

function applyStatus( obj, cs )

if obj.Status ~= ""

cs.setPropEnabled( obj.Name, false );
end 
end 

function out = isCompatible( obj, cs )

owner = cs.getPropOwner( obj.Name );

if isa( obj.Value, 'missing' ) || obj.Status == ""
out = true;
else 
if isa( obj.Value, 'function_handle' )

msg = obj.Value( "check", owner, obj.Name, get_param( cs, obj.Name ) );
out = isempty( msg );
else 
out = isequal( get_param( owner, obj.Name ), obj.Value );
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpKkQAxZ.p.
% Please follow local copyright laws when handling this file.

