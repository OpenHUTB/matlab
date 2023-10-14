classdef ( Abstract, Hidden )ReferableNodeAdapter < coderapp.internal.config.runtime.NodeAdapter &  ...
        coderapp.internal.config.runtime.ReadableMetadataNodeMixin



    properties ( GetAccess = protected, SetAccess = immutable )
        SchemaDef coderapp.internal.config.schema.BaseDef
    end

    properties ( Abstract, SetAccess = private )
        Dependencies coderapp.internal.config.runtime.ReferableNodeAdapter
    end

    properties ( Abstract, Dependent, Hidden, SetAccess = immutable )
        ReferableValue
        ExportedValue
        ScriptValue
        ScriptCode
    end

    properties ( SetAccess = immutable )
        Key char
        Ordinal uint32
        SchemaIndex uint32
    end

    properties ( SetAccess = private )
        Successors coderapp.internal.config.runtime.ReferableNodeAdapter
    end

    properties ( Access = protected )
        RequiresDepView logical = true
    end

    properties ( Access = private )
        ReferableView struct
        ExportedView struct
    end

    methods
        function this = ReferableNodeAdapter( schemaDef, declIndex )
            arguments
                schemaDef coderapp.internal.config.schema.ReferableDef
                declIndex double{ mustBeGreaterThan( declIndex, 0 ) }
            end
            this.SchemaDef = schemaDef;
            this.SchemaIndex = declIndex;
        end

        function key = get.Key( this )
            key = this.SchemaDef.Key;
        end

        function ordinal = get.Ordinal( this )
            ordinal = this.SchemaDef.Ordinal;
        end

        function messageObj = newGlobalMessage( this )
            messageObj = coderapp.internal.config.runtime.MetaMessage( this.Configuration.RuntimeModel );
            messageObj.Sticky = true;
            this.RootStateObject.Messages.add( messageObj );
            this.Logger.debug( @(  )sprintf( 'Adding new global message object: %s', messageObj.UUID ) );
        end

        function prodConfig = getProductionConfig( ~, key )
            arguments
                ~
                key{ mustBeTextScalar( key ) }%#ok<INUSA>
            end
            prodConfig = [  ];
        end

        function depView = getDependencyView( this, exported )
            arguments
                this
                exported logical = false
            end

            if exported
                depView = this.ExportedView;
            else
                depView = this.ReferableView;
            end
            if ~isempty( depView )
                return
            end
            deps = this.Dependencies;
            if isempty( deps ) || ~this.RequiresDepView
                this.ExportedView = struct(  );
                this.ReferableView = this.ExportedView;
                depView = this.ExportedView;
            elseif exported
                depView = cell2struct( { deps.ExportedValue }, { deps.Key }, 2 );
                this.ExportedView = depView;
            else
                depView = cell2struct( { deps.ReferableValue }, { deps.Key }, 2 );
                this.ReferableView = depView;
            end
        end
    end

    methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
            ?coderapp.internal.config.runtime.ConfigStoreAdapter } )
        function activateNode( ~ )
        end

        function initNode( this, configuration )
            initNode@coderapp.internal.config.runtime.NodeAdapter( this, configuration );
            if ~isempty( this.SchemaDef.Successors )
                this.Successors = configuration.getNodes( this.SchemaDef.Successors );
            end
        end

        function resetNode( this )
            this.ReferableView = struct.empty;
            this.ExportedView = struct.empty;
        end

        function revertNode( ~ )
        end
    end

    methods ( Access = protected )
        function updateSuccessorDepViews( this )
            exported = false;
            for i = 1:numel( this.Successors )
                successor = this.Successors( i );
                if ~successor.RequiresDepView
                    continue
                end
                if ~isempty( successor.ExportedView )
                    if ~exported
                        exported = true;
                        exportedVal = this.ExportedValue;
                    end
                    successor.ExportedView.( this.Key ) = exportedVal;
                end
                if ~isempty( successor.ReferableView )
                    successor.ReferableView.( this.Key ) = this.ReferableValue;
                end
            end
        end
    end
end

