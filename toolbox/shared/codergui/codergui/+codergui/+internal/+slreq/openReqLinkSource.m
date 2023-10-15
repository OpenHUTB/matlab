function openReqLinkSource( aRangeIdentifier )

arguments
    aRangeIdentifier( 1, 1 )string
end

[ file, id ] = codergui.internal.slreq.decomposeRangeIdentifier( aRangeIdentifier );



codergui.internal.slreq.loadLinkSet( file );

rmicodenavigate( char( file ), char( id ) );
end

