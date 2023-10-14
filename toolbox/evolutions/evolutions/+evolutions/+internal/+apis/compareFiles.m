function output = compareFiles( treeId, evolution1Id, evolution2Id, fileName )

arguments
    treeId( 1, : )char
    evolution1Id( 1, : )char
    evolution2Id( 1, : )char
    fileName( 1, : )char
end

tree = evolutions.internal.getDataObject( treeId );
output = compareFiles( tree, evolution1Id, evolution2Id, fileName );
end


