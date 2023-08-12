classdef Node




properties ( Dependent, SetAccess = private )
ID( 1, 1 )cell
Data( 1, 1 )simscape.ui.internal.NodeData
Terminal( 1, 1 )logical
end 

properties ( SetAccess = immutable, GetAccess = private )
DataImpl( 1, 3 )cell
end 

methods 
function obj = Node( args )
R36
args.ID( 1, 1 )cell = { uint32( 1 ) }
args.Data( 1, 1 )simscape.ui.internal.NodeData = simscape.ui.internal.NodeData
args.Terminal( 1, 1 )logical = false
end 
obj.DataImpl = { args.ID, args.Data, args.Terminal };
end 

function out = get.ID( obj )
out = obj.DataImpl{ 1 };
end 

function out = get.Data( obj )
out = obj.DataImpl{ 2 };
end 

function out = get.Terminal( obj )
out = obj.DataImpl{ 3 };
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpBbGCC1.p.
% Please follow local copyright laws when handling this file.

