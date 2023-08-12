classdef PreorderTraverser < handle




properties ( Access = private )
GetChildren
RootEntry
end 

methods ( Access = public )
function obj = PreorderTraverser( rootEntry, getChildren )
obj.RootEntry = rootEntry;
obj.GetChildren = getChildren;
end 

function forEach( traverser, func )
R36
traverser comparisons.internal.tree.PreorderTraverser
func function_handle
end 

stack = traverser.GetChildren( traverser.RootEntry );

while ~isempty( stack )
popEntry = stack( 1 );
func( popEntry );
stack = [ traverser.GetChildren( popEntry ), stack( 2:end  ) ];
end 
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpnEruUQ.p.
% Please follow local copyright laws when handling this file.

