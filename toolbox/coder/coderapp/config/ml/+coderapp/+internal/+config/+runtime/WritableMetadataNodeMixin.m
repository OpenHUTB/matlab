classdef ( Abstract )WritableMetadataNodeMixin < coderapp.internal.config.runtime.ReadableMetadataNodeMixin


    methods
        function modified = setMetadata( this, prop, value )
            arguments
                this
                prop char{ mustBeNonempty( prop ) }
                value = [  ]
            end
            if isempty( this.MetadataMap )
                error( 'MetadataMap not set' );
            end
            entry = this.MetadataMap.getByKey( prop );
            modified = false;
            if nargin == 3
                if isempty( entry )
                    entry = coderapp.internal.config.runtime.Metadata(  ...
                        struct( 'Property', prop, 'Value', [  ] ) );
                    this.MetadataMap.add( entry );
                    modified = true;
                end
                if ~isequal( entry.Value, value )
                    entry.Value = value;
                    modified = true;
                end
            elseif ~isempty( entry )
                entry.destroy(  );
                modified = true;
            end
        end
    end
end


