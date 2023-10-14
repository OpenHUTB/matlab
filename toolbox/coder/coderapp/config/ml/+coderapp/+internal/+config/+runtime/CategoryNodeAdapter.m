classdef ( Sealed )CategoryNodeAdapter < coderapp.internal.config.runtime.ControllableNodeAdapter

    properties ( Constant )
        NodeType coderapp.internal.config.runtime.NodeType = coderapp.internal.config.runtime.NodeType.Category
    end

    properties ( SetAccess = private )
        Dependencies coderapp.internal.config.runtime.ReferableNodeAdapter
        ContentNodes coderapp.internal.config.runtime.ControllableNodeAdapter
        TransitiveContentNodes coderapp.internal.config.runtime.ControllableNodeAdapter
        Awake = true
    end

    properties ( Dependent, Hidden, SetAccess = immutable )
        ReferableValue
        ExportedValue
        ScriptValue
        ScriptCode
    end

    properties ( SetAccess = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration } )
        VisibilityChanged = false
    end

    methods ( Access = ?coderapp.internal.config.Configuration )
        function this = CategoryNodeAdapter( catDef, schemaIdx )
            arguments
                catDef coderapp.internal.config.schema.CategoryDef
                schemaIdx
            end
            this@coderapp.internal.config.runtime.ControllableNodeAdapter( catDef, schemaIdx );
        end
    end

    methods
        function value = get.ReferableValue( ~ )
            value = [  ];
        end

        function value = get.ExportedValue( ~ )
            value = [  ];
        end

        function value = get.ScriptValue( ~ )
            value = '';
        end

        function code = get.ScriptCode( ~ )
            code = '';
        end
    end

    methods ( Access = protected )
        function modified = doSetAttr( this, attr, attrValue )
            modified = doSetAttr@coderapp.internal.config.runtime.ControllableNodeAdapter( this, attr, attrValue );
            if modified && strcmp( attr, 'Visible' )
                this.VisibilityChanged = true;
            end
        end
    end

    methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
            ?coderapp.internal.config.runtime.ConfigStoreAdapter } )
        function initNode( this, configuration )
            catDef = this.SchemaDef;
            this.DataObjectStrategy = configuration.TypeManager.UserVisibleStrategy;

            if ~isempty( catDef.Contents )
                contentNodes = configuration.getNodes( [ catDef.Contents.Ordinal ] );
                this.ContentNodes = contentNodes;
                for i = 1:numel( contentNodes )
                    contentNodes( i ).CategoryNode = this;
                end
                if numel( catDef.Contents ) < numel( catDef.TransitiveContents )
                    this.TransitiveContentNodes = configuration.getNodes( [ catDef.TransitiveContents.Ordinal ] );
                else
                    this.TransitiveContentNodes = this.ContentNodes;
                end
            end
            if ~isempty( catDef.Requires )
                this.Dependencies = configuration.getNodes( [ catDef.Requires.Ordinal ] );
            end
            initNode@coderapp.internal.config.runtime.ControllableNodeAdapter( this, configuration );
        end

        function [ next, changed ] = updateEffectiveVisibility( this )

            [ next, changed ] = updateEffectiveVisibility@coderapp.internal.config.runtime.ControllableNodeAdapter( this );


            members = this.ContentNodes;
            logCleanup = this.Logger.trace( 'Propagating effective visibility update to category contents for "%s"', this.Key );%#ok<NASGU>
            for i = 1:numel( members )
                if members( i ).NodeType == "Param"
                    members( i ).updateEffectiveVisibility(  );
                end
            end
            logCleanup = [  ];%#ok<NASGU>

            if next && ~isempty( members ) && ~this.anyChildrenVisible(  )

                next = false;
                this.EffectiveVisible = false;
                changed = false;
                this.Logger.debug( 'EffectiveVisible for category "%s" set to false due to fully hidden subtree', this.Key );
            end
        end
    end

    methods ( Access = private )
        function visible = anyChildrenVisible( this )
            visible = false;
            for i = 1:numel( this.ContentNodes )
                node = this.ContentNodes( i );
                if node.InPerspective && node.DataObject.Visible
                    visible = true;
                    break
                end
            end
        end

        function followDirtyState( this )

            this.Dirty = any( [ this.StateObject.Contents.toArray(  ).Dirty ] );
        end
    end
end


