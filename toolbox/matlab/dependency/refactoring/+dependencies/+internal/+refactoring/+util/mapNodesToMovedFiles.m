function [ nodes, movedFiles ] = mapNodesToMovedFiles( sourceDirs, destDirs, graph )






R36
sourceDirs( 1, : )string;
destDirs( 1, : )string{ i_mustBeSameLength( sourceDirs, destDirs ) };
graph( 1, 1 )dependencies.internal.graph.Graph;
end 

nodes = dependencies.internal.graph.Node.empty( 1, 0 );
movedFiles = strings( 1, 0 );

sourceDirsWithFinalSlash = fullfile( sourceDirs, filesep );

for node = graph.Nodes
if ~i_isFileBased( node )
continue ;
end 
path = node.Path;
matchingDirIdx = i_findStart( path, sourceDirsWithFinalSlash );
if isnan( matchingDirIdx )
continue ;
end 
matchingSource = sourceDirsWithFinalSlash( matchingDirIdx );
matchingDest = destDirs( matchingDirIdx );

relativePath = extractAfter( path, matchingSource );
%#ok<*AGROW>: we don't know how many they are going to be
nodes( end  + 1 ) = node;
movedFiles( end  + 1 ) = fullfile( matchingDest, relativePath );
end 
end 

function foundOrNaN = i_findStart( path, sourceDirs )
for n = 1:length( sourceDirs )
if startsWith( path, sourceDirs( n ) )
foundOrNaN = n;
return ;
end 
end 
foundOrNaN = nan;
end 

function fileBased = i_isFileBased( node )
R36
node( 1, 1 )dependencies.internal.graph.Node;
end 
import dependencies.internal.graph.Type;
type = node.Type;
fileBased = ( type == Type.FILE || type == Type.TEST_HARNESS ) && ~isempty( node.Location );
end 

function i_mustBeSameLength( source, dest )
if ~isequal( length( source ), length( dest ) )
error( message( "MATLAB:dependency:refactoring:NumberOfDirectoriesMustBeTheSame" ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMKKU4D.p.
% Please follow local copyright laws when handling this file.

