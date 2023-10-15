function sectionList = getSectionsForSource( source )

arguments
    source( 1, 1 )string
end

mdl = mf.zero.Model;
configs = sl.data.adapter.AdapterManagerV2.getAdapterConfig( source, mdl );
sectionList = strings( size( configs ) );
for iter = 1:numel( configs )
    sectionList( iter ) = string( configs( iter ).section );
end

end

