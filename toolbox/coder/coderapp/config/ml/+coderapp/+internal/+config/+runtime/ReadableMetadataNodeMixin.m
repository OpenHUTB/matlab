classdef ( Abstract )ReadableMetadataNodeMixin < handle

    properties ( Access = protected )
        MetadataMap mf.zero.Map
    end

    
    methods
        function result = getMetadata( this, prop )
            arguments
                this( 1, 1 )
                prop char = ''
            end
            if isempty( this.MetadataMap )
                if isempty( prop )
                    result = containers.Map(  );
                else
                    result = [  ];
                end
            elseif isempty( prop )
                entries = this.MetadataMap.toArray(  );
                if ~isempty( entries )
                    result = containers.Map( { entries.Property }, { entries.Value } );
                else
                    result = containers.Map(  );
                end
            else
                entry = this.MetadataMap.getByKey( prop );
                if ~isempty( entry )
                    result = entry.Value;
                else
                    result = [  ];
                end
            end
        end

        function set.MetadataMap( this, metaMap )
            if isempty( metaMap )
                this.MetadataMap = mf.zero.Map.empty(  );
            else
                this.MetadataMap = metaMap;
            end
        end

        function yes = hasMetadata( this, metadataProp )
            yes = ~isempty( this.MetadataMap ) && ismember( metadataProp, this.MetadataMap.keys(  ) );
        end
    end
end


