classdef DefaultNodeProvider < simscape.ui.internal.NodeProvider
methods 
function out = children( obj, nodePath )
R36
obj( 1, 1 )%#ok<INUSA> 
nodePath( 1, : )cell %#ok<INUSA> 
end 
out = repmat( simscape.ui.internal.Node, 0, 1 );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpagU5Oy.p.
% Please follow local copyright laws when handling this file.

