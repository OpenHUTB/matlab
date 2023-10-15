function props = getBusRenameProperties( numFiles, nodes, oldNode, newFullName )

arguments
    numFiles( 1, 1 )uint64;
    nodes( 1, : )dependencies.internal.graph.Node{ mustBeNonempty };
    oldNode( 1, 1 )dependencies.internal.graph.Node;
    newFullName( 1, 1 )string;
end

import dependencies.internal.refactoring.MessageWithDetails;

variableType = dependencies.internal.graph.Type( "Variable" );
variableNodes = nodes( [ nodes.Type ] == variableType );
falsePositives = variableNodes( variableNodes ~= oldNode );

oldName = oldNode.Location{ end  };

newNameParts = split( newFullName, "." );
newName = newNameParts( end  );

messageParams = { "<b>" + string( numFiles ) + "</b>", oldName, newName };
detailsParams = {  };

resourceCatalog = "SimulinkDependencyAnalysis:Buses:";
commonGroup = resourceCatalog + "BusRefactoring";

if length( oldNode.Location ) > 1
    resourceGroup = resourceCatalog + "BusElementRename";
else
    resourceGroup = resourceCatalog + "BusRename";
end

if numFiles == 1
    appendage = "Single";
else
    appendage = "Multi";
end


if isempty( falsePositives )
    appendage = appendage + "NoFalsePositives";
else
    appendage = appendage + "WithFalsePositives";
    falsePositiveNames = arrayfun( @( n )string( n.Location{ 1 } ), falsePositives );
    falsePositiveNames = sort( unique( falsePositiveNames ) );
    messageParams{ end  + 1 } = strjoin( falsePositiveNames, ", " );
    detailsParams{ end  + 1 } = oldName;
end

msgResource = resourceGroup + "Message" + appendage;
detailsResource = commonGroup + "Details" + appendage;

props = struct;
props.title = string( message( resourceGroup + "Title" ) );
props.message = string( message( msgResource, messageParams{ : } ) );
props.details = string( message( detailsResource, detailsParams{ : } ) );
props.success = MessageWithDetails;
props.success.Message = string( message( resourceGroup + "MessageSuccess" ) );
props.incomplete = MessageWithDetails;
props.incomplete.Message = string( message( commonGroup + "MessageIncomplete" ) );
props.incomplete.Details = string( message( commonGroup + "DetailsIncomplete" ) );
props.error = MessageWithDetails;
props.error.Message = string( message( resourceGroup + "MessageError" ) );
props.error.Details = string( message( commonGroup + "DetailsError" ) );
end


