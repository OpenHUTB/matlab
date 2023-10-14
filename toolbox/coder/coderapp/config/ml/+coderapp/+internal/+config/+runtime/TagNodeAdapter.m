classdef ( Sealed )TagNodeAdapter < coderapp.internal.config.runtime.InternalNodeAdapter

    properties ( Constant )
        NodeType coderapp.internal.config.runtime.NodeType = coderapp.internal.config.runtime.NodeType.Tag
    end

    properties ( Dependent, SetAccess = private )
        DependencyKeys
    end

    properties ( GetAccess = private, SetAccess = immutable )
        TagDef
    end

    methods
        function this = TagNodeAdapter( tagDef )
            arguments
                tagDef( 1, 1 )coderapp.internal.config.schema.TagDef
            end

            this@coderapp.internal.config.runtime.InternalNodeAdapter( tagDef );
        end

        function keys = get.DependencyKeys( this )
            keys = { this.State.Tagged.toArray(  ).Key };
        end
    end

    methods ( Access = protected )
        function depNodes = getDependencyNodes( this )
            deps = this.State.Tagged.toArray(  );
            deps = [ deps{ : } ];
            if ~isempty( deps )
                depNodes = this.Configuration.getNodes( { deps.Key } );
            else
                depNodes = [  ];
            end
        end
    end
end


