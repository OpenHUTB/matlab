classdef GraphMLReader < dependencies.internal.graph.GraphReader




properties ( Constant )
Extensions = ".graphml";
end 

methods 

function graph = read( ~, file, root )
R36
~
file( 1, 1 )string
root( 1, 1 )string = "";
end 

graph = dependencies.internal.graph.readGraphML( file, root );
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeC7bln.p.
% Please follow local copyright laws when handling this file.

