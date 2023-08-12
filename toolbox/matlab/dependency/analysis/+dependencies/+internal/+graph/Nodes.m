classdef ( Abstract )Nodes




properties ( Constant )
BaseWorkspaceNode = dependencies.internal.graph.Node( strings( 1, 0 ), "BaseWorkspace", true );
end 

methods ( Static )

function node = createProductNode( basecodes )



R36
basecodes( 1, : )string{ mustBeNonempty };
end 

node = dependencies.internal.graph.Node.createProductNode( basecodes );
end 

function node = createToolboxNode( path, name, version )


location = [ path, name + " " + version ];
node = dependencies.internal.graph.Node( location, "Toolbox", true );
end 

function node = createTestHarnessNode( path, hOwner, hName )
node = dependencies.internal.graph.Node.createTestHarnessNode( path, hOwner, hName );
end 

function node = createVariableNode( busElements )
node = dependencies.internal.graph.Node( busElements, "Variable", true );
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppEpOSU.p.
% Please follow local copyright laws when handling this file.

