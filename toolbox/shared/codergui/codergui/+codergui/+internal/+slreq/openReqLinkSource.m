function openReqLinkSource( aRangeIdentifier )






R36
aRangeIdentifier( 1, 1 )string
end 

[ file, id ] = codergui.internal.slreq.decomposeRangeIdentifier( aRangeIdentifier );



codergui.internal.slreq.loadLinkSet( file );

rmicodenavigate( char( file ), char( id ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzR8UhD.p.
% Please follow local copyright laws when handling this file.

