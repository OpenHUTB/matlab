function linkStatus = pmsl_linkstatus( block )

















property = 'StaticLinkStatus';

obj = pmsl_getsimulinkobject( block );


linkStatus = cell( size( obj ) );

idx = isprop( obj, property );
if any( idx )
linkStatus( idx ) = get( obj( idx ), { property } );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpWkC34K.p.
% Please follow local copyright laws when handling this file.

