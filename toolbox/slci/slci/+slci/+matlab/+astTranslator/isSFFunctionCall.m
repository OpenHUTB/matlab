



function flag = isSFFunctionCall( mtreeNode, aParent )
assert( isa( mtreeNode, 'mtree' ) );
if isa( aParent, 'slci.ast.SFAst' ) ...
 && any( strcmpi( mtreeNode.kind, { 'CALL', 'LP' } ) )
fnode = mtreeNode.Left;
if strcmp( fnode.kind, 'ID' )
fname = fnode.string;
chart = aParent.ParentChart;
flag = isa( chart, 'slci.stateflow.Chart' ) ...
 && strcmpi( slci.internal.getLanguageFromSFObject( chart ), 'MATLAB' ) ...
 && isKey( chart.getSFFuncNamesMap, fname );
else 



flag = false;
end 
else 
flag = false;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpEKqPtj.p.
% Please follow local copyright laws when handling this file.

