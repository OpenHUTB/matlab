function dataLinkSet = loadLinkSet( aFile )
arguments
    aFile( 1, 1 )string
end
dataLinkSet = tryGetLinkSet( aFile );
if isempty( dataLinkSet ) && slreq.utils.loadLinkSet( char( aFile ) )

    dataLinkSet = tryGetLinkSet( aFile );
end
if isempty( dataLinkSet )

    error( message( 'coderWeb:reportMessages:requirementLinkSetFailedToLoad', aFile ) );
end
end


function dataLinkSet = tryGetLinkSet( aFile )

dataLinkSet = slreq.utils.getLinkSet( char( aFile ), 'linktype_rmi_matlab', false );
end
