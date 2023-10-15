function generateTraceabilityDiagram( startingNode )
arguments
    startingNode{ mustBeNonempty, isValidStartingNode }
end

if builtin( '_license_checkout', 'Simulink_Requirements', 'quiet' )
    errordlg( getString( message( 'Slvnv:slreq:SimulinkRequirementsNoLicense' ) ),  ...
        getString( message( 'Slvnv:slreq:SimulinkRequirements' ) ), 'modal' );
    return ;
end

if isstring( startingNode )
    startingNode = convertStringsToChars( startingNode );
end

if ischar( startingNode )
    newFilePath = getFilePathAfterChecking( startingNode );
    slreq.internal.tracediagram.utils.generateTraceDiagram( newFilePath );
else
    startingNode.generateTraceDiagram(  );
end

end

function filePath = getFilePathAfterChecking( filePath )




fileHandler = slreq.uri.FilePathHelper( filePath );
if ~fileHandler.doesExist
    throwAsCaller( MException( message( "Slvnv:slreq_tracediagram:APIErrorArtifactsFound", filePath ) ) );
end

switch fileHandler.getDomain(  )
    case { 'linktype_rmi_slreq', 'linktype_rmi_matlab', 'linktype_rmi_simulink', 'linktype_rmi_testmanager', 'linktype_rmi_data' }

        return ;
    case 'linkset'
        reqData = slreq.data.ReqData.getInstance;
        dataLinkSet = reqData.getLinkSetByFilepath( fileHandler.getFullPath(  ) );
        if isempty( dataLinkSet )
            throwAsCaller( MException( message( "Slvnv:slreq_tracediagram:APIErrorLinkSetNotLoaded", filePath ) ) );
        end
        filePath = dataLinkSet;
        return ;
end


throwAsCaller( MException( message( "Slvnv:slreq_tracediagram:APIErrorUnsupportedArtifact", filePath ) ) );
end
function isValidStartingNode( startingNode )
isValid = isa( startingNode, 'slreq.BaseItem' ) ||  ...
    isa( startingNode, 'slreq.internal.BaseSet' ) ||  ...
    isa( startingNode, 'slreq.Link' ) ||  ...
    ischar( startingNode ) ||  ...
    isstring( startingNode );

if ~isValid
    supportedTypes = { 'slreq.Requirement', 'slreq.Reference', 'slreq.Justification', 'slreq.ReqSet', 'slreq.Link', 'slreq.LinkSet', 'Char Arrary', 'String' };
    supportedTypesChars = strjoin( supportedTypes, ',' );
    throwAsCaller( MException( message( "Slvnv:slreq_tracediagram:APIErrorInvalidInput", supportedTypesChars ) ) );
end
end

