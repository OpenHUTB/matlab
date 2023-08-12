function output = compareFiles( treeId, evolution1Id, evolution2Id, fileName )




R36
treeId( 1, : )char
evolution1Id( 1, : )char
evolution2Id( 1, : )char
fileName( 1, : )char
end 

tree = evolutions.internal.getDataObject( treeId );
output = compareFiles( tree, evolution1Id, evolution2Id, fileName );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpvUtCpA.p.
% Please follow local copyright laws when handling this file.

