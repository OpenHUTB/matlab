classdef ( Abstract )InternalNodeAdapter < coderapp.internal.config.runtime.NodeAdapter &  ...
        coderapp.internal.config.runtime.DataObjectNodeMixin

    properties ( SetAccess = immutable )
        Id char
        SchemaDef coderapp.internal.config.schema.InternalDef
    end

    properties ( Abstract, SetAccess = private )
        DependencyKeys
    end

    properties ( SetAccess = protected )
        Dirty logical = false
        DependsOnAll logical = false
    end

    properties ( GetAccess = ?coderapp.internal.config.runtime.NodeAdapter, SetAccess = protected )
        State coderapp.internal.config.data.UserVisibleData
    end

    properties ( Access = private )
        CachedDepNodes = codergui.internal.undefined(  )
    end

    methods
        function this = InternalNodeAdapter( def, state, id )
            arguments
                def coderapp.internal.config.schema.InternalDef
                state( 1, 1 )coderapp.internal.config.data.UserVisibleData = def.InitialState
                id( 1, : )char = state.Id
            end
            this.SchemaDef = def;
            this.State = state;
            this.Id = id;
            this.DataObject = state;
        end
    end

    methods ( Sealed )
        function equals = ne( a, b )
            equals = ne@handle( a, b );
        end

        function equals = eq( a, b )
            equals = eq@handle( a, b );
        end
    end

    methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
            ?coderapp.internal.config.runtime.ConfigStoreAdapter } )
        function initNode( this, configuration )
            initNode@coderapp.internal.config.runtime.NodeAdapter( this, configuration );
            this.DataObjectStrategy = configuration.TypeManager.UserVisibleStrategy;

            if configuration.ResolveMessages && ~isempty( this.SchemaDef )
                this.DataObjectStrategy.resolveMessages( this.DataObject, this.SchemaDef.UnresolvedMessages );
            end
        end
    end
end


