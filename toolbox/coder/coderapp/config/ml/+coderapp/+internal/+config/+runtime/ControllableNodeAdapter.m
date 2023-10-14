classdef ( Abstract )ControllableNodeAdapter < coderapp.internal.config.runtime.ReferableNodeAdapter &  ...
        coderapp.internal.config.runtime.DataObjectNodeMixin


    properties ( GetAccess = protected, SetAccess = private, Transient )
        Controllers coderapp.internal.config.runtime.ControllerAdapter
    end

    properties ( Access = protected )
        StateObject coderapp.internal.config.runtime.ControllableState
        CategoryNode coderapp.internal.config.runtime.CategoryNodeAdapter
    end

    properties ( SetAccess = immutable )
        InCategory logical
    end

    properties ( Dependent, SetAccess = private )
        NodeActive logical
        Visible logical
    end

    properties ( Abstract, SetAccess = private )
        Awake
    end

    properties ( Dependent )
        EffectiveVisible
        InPerspective
    end

    properties ( Access = private )
        FollowedNodes coderapp.internal.config.runtime.ReferableNodeAdapter
        LocalNodeActive logical
    end

    methods
        function this = ControllableNodeAdapter( schemaDef, schemaIdx )
            arguments
                schemaDef coderapp.internal.config.schema.ControllableDef
                schemaIdx double
            end

            this@coderapp.internal.config.runtime.ReferableNodeAdapter( schemaDef, schemaIdx );
            this.StateObject = schemaDef.InitialState;
            this.DataObject = this.StateObject.Data;
            this.MetadataMap = this.StateObject.Metadata;
            this.InCategory = ~isempty( this.StateObject.Category );
        end

        function messageObj = newLocalMessage( this )
            messageObj = coderapp.internal.config.runtime.MetaMessage( this.Configuration.RuntimeModel );
            messageObj.Sticky = false;
            this.StateObject.Messages.add( messageObj );
        end

        function active = get.NodeActive( this )
            active = this.LocalNodeActive;
            if isempty( active )
                active = this.StateObject.Initialized;
                this.LocalNodeActive = active;
            end
        end

        function set.NodeActive( this, active )
            this.LocalNodeActive = active;
            this.StateObject.Initialized = active;
        end

        function vis = get.EffectiveVisible( this )
            vis = this.StateObject.EffectiveVisible;
        end

        function set.EffectiveVisible( this, visible )
            this.StateObject.EffectiveVisible = visible;
        end

        function vis = get.InPerspective( this )
            vis = this.StateObject.InPerspective;
        end

        function set.InPerspective( this, visible )
            this.StateObject.InPerspective = visible;
        end

        function vis = get.Visible( this )
            vis = this.DataObject.Visible;
        end

        function deferredSetPerspective( this, perspectiveId )
            this.Configuration.deferredSetPerspective( perspectiveId );
        end

        function deferredRefresh( this )
            this.Configuration.deferredRefresh( this );
        end
    end

    methods ( Sealed, Access = protected )
        function invokeControllersVoid( this, methodName, varargin )
            if isempty( this.Controllers )
                return
            end
            logCleanup = this.Logger.trace( 'Invoking controllers (void)' );%#ok<NASGU>
            method = str2func( methodName );
            for i = 1:numel( this.Controllers )
                method( this.Controllers( i ), varargin{ : } );
            end
        end

        function output = invokeControllers( this, methodName, varargin )
            if isempty( this.Controllers )
                return
            end
            logCleanup = this.Logger.trace( 'Invoking controllers' );%#ok<NASGU>
            method = str2func( methodName );
            output = cell( 1, numel( this.Controllers ) );
            for i = 1:numel( this.Controllers )
                output{ i } = method( this.Controllers( i ), varargin{ : } );
            end
        end
    end

    methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
            ?coderapp.internal.config.runtime.ConfigStoreAdapter } )
        function initNode( this, configuration )
            logCleanup = this.Logger.trace( 'Initializing node "%s" (%s)', this.Key, this.NodeType );%#ok<NASGU>
            initNode@coderapp.internal.config.runtime.ReferableNodeAdapter( this, configuration );

            if configuration.ResolveMessages
                this.DataObjectStrategy.resolveMessages( this.DataObject, this.SchemaDef.UnresolvedMessages );
            end

            if ~isempty( this.SchemaDef.Logic )
                evalController = coderapp.internal.config.runtime.ExprControllerAdapter( this.SchemaDef.Logic );
                evalController.initAdapter( this );
            else
                evalController = coderapp.internal.config.runtime.ControllerAdapter.empty(  );
            end

            controllerRefs = this.SchemaDef.Controllers;
            if ~isempty( controllerRefs )
                customs = configuration.getControllers( { controllerRefs.Id } );
                customAdapters = cell( 1, numel( customs ) );
                for i = 1:numel( customs )
                    customAdapters{ i } = coderapp.internal.config.runtime.CustomControllerAdapter(  ...
                        customs( i ), controllerRefs( i ) );
                    customAdapters{ i }.initAdapter( this );
                end
                customAdapters = [ customAdapters{ : } ];
            else
                customAdapters = coderapp.internal.config.runtime.ControllerAdapter.empty(  );
            end

            this.Controllers = [ evalController, customAdapters, reshape( this.getExtraControllers(  ), 1, [  ] ) ];
            this.RequiresDepView = ~isempty( this.Controllers ) || ~isempty( this.SchemaDef.Follows );
        end

        function activateNode( this )
            logCleanup = this.Logger.trace( 'Activating node "%s" (%s)', this.Key, this.NodeType );%#ok<NASGU>
            this.NodeActive = true;
            this.applyFollows(  );
            try
                this.invokeControllersVoid( 'initialize' );
            catch me
                this.NodeActive = false;
                me.rethrow(  );
            end
        end

        function updateNode( this, triggers )
            logCleanup = this.Logger.debug( 'Updating node "%s" (%s)', this.Key, this.NodeType );%#ok<NASGU>
            this.clearTemporaryMessages(  );
            this.applyFollows( triggers );
            this.invokeControllersVoid( 'update' );
        end

        function [ next, changed ] = updateEffectiveVisibility( this )
            prev = this.StateObject.EffectiveVisible;
            next = this.InPerspective && this.DataObject.Visible &&  ...
                ( isempty( this.StateObject.Category ) || this.StateObject.Category.EffectiveVisible );
            if prev ~= next
                this.StateObject.EffectiveVisible = next;
                changed = true;
                this.Logger.trace( @(  )sprintf(  ...
                    'Effective visibility of "%s" changed to %g (InPerspective=%g, Visible=%g, HasCategory=%g, CategoryShowing=%g)',  ...
                    this.Key, next, this.InPerspective, this.DataObject.Visible, ~isempty( this.StateObject.Category ),  ...
                    isempty( this.StateObject.Category ) || this.StateObject.Category.EffectiveVisible ) );
            else
                changed = false;
            end
        end
    end

    methods ( Access = protected )
        function clearTemporaryMessages( this )
            messages = this.StateObject.Messages.toArray(  );
            messages = messages( ~[ messages.Sticky ] );
            for i = 1:numel( messages )
                messages( i ).destroy(  );
            end
        end

        function clearAllMessages( this )
            this.StateObject.Messages.clear(  );
        end

        function extraControllers = getExtraControllers( ~ )
            extraControllers = [  ];
        end

        function changed = applyFollows( this, ~ )
            changed = false;
            followsDefs = this.SchemaDef.Follows;
            if isempty( followsDefs )
                return
            end

            logCleanup = this.Logger.trace( 'Applying "follows" expressions' );%#ok<NASGU>
            [ values, evalChanged ] = coderapp.internal.config.expr.evaluate(  ...
                [ followsDefs.Expr ], this.getDependencyView( true ) );

            for i = reshape( find( evalChanged ), 1, [  ] )
                attr = followsDefs( i ).Attribute;
                if strcmp( attr, 'Value' )
                    attr = 'DefaultValue';
                end
                changed = this.importAttr( attr, values{ i } ) || changed;
            end
        end

        function modified = doSetAttr( this, attr, attrValue, report )
            arguments
                this
                attr
                attrValue
                report = true
            end

            modified = doSetAttr@coderapp.internal.config.runtime.DataObjectNodeMixin( this, attr, attrValue );
            if modified && report
                if strcmp( attr, 'Visible' )
                    this.updateEffectiveVisibility(  );
                end
                if report
                    this.Configuration.reportChange( this, attr, false );
                end
            end
        end
    end
end


function str = concatSubscripts( subs )
strs = cell( size( subs ) );
for i = 1:numel( subs )
    if isnumeric( subs{ i } ) || islogical( subs{ i } )
        strs{ i } = [ '(', num2str( subs{ i } ), ')' ];
    else
        strs{ i } = [ '.', subs{ i } ];
    end
end
str = strjoin( strs, '' );
end


