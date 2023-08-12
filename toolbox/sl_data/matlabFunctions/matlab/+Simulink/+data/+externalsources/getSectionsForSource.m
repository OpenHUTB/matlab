function sectionList = getSectionsForSource( source )



R36
source( 1, 1 )string
end 

mdl = mf.zero.Model;
configs = sl.data.adapter.AdapterManagerV2.getAdapterConfig( source, mdl );
sectionList = strings( size( configs ) );
for iter = 1:numel( configs )
sectionList( iter ) = string( configs( iter ).section );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpjOj41i.p.
% Please follow local copyright laws when handling this file.

