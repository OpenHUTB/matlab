classdef ConfigUiController < coderapp.internal.log.Loggable

    properties ( SetAccess = private, Transient )
        Owner coderapp.internal.config.ui.ConfigUi
        Configuration coderapp.internal.config.Configuration
        ChannelRoot char = ''
        StateTracker coderapp.internal.undo.StateTracker
    end

    properties ( GetAccess = { ?coderapp.internal.config.ui.ConfigUiController, ?coderapp.internal.config.ui.ConfigUi },  ...
            SetAccess = private, Transient )
        UiModel coderapp.internal.config.ui.ConfigUiModel
        MfzModel mf.zero.Model
        Form codergui.internal.form.model.Form
    end

    properties ( Dependent, Access = private )
        SuppressListener
    end

    properties ( Access = private )
        UiModelSync mf.zero.io.ModelSynchronizer
        UiChannelObj mf.zero.io.ConnectorChannel
        ConfigModelSync mf.zero.io.ModelSynchronizer
        ConfigChannelObj mf.zero.io.ConnectorChannel
        Transaction mf.zero.Transaction
        UiListenerFunction function_handle
        ConfigurationListenerHandle
    end

    methods
        function search( this, query )
            this.Logger.debug( 'Broadcasting search request for query "%s"', query );
            this.UiModel.search.emit( query );
        end

        function delete( this )
            this.Logger.trace( 'Destroying ConfigUiController' );
            if ~isempty( this.UiModelSync )
                this.UiModelSync.stop(  );
            end
            this.SuppressListener = true;
            this.StateTracker.removeStateOwner( this.Configuration );
            this.MfzModel.destroy(  );
        end

        function suppress = get.SuppressListener( this )
            suppress = isempty( this.UiListenerFunction );
        end

        function set.SuppressListener( this, suppress )
            if suppress && ~isempty( this.UiListenerFunction )
                this.MfzModel.removeListener( this.UiListenerFunction );
                this.UiListenerFunction = function_handle.empty(  );
            elseif ~suppress && isempty( this.UiListenerFunction )
                this.UiListenerFunction = @this.aroundHandleUiModelChange;
                this.MfzModel.addObservingListener( this.UiListenerFunction );
            end
        end
    end

    methods ( Access = protected )
        function uiModel = createConfigUiModel( this, mfzModel )
            this.Logger.trace( 'Using default ConfigUiModel implementation' );
            uiModel = coderapp.internal.config.ui.ConfigUiModel( mfzModel );
        end

        function setup( ~ )

        end

        function binding = createBinding( this, bindable )
            arguments
                this %#ok<*INUSA>
                bindable coderapp.internal.config.runtime.ControllableState
            end
            binding = [  ];
        end

        function value = widgetToValue( ~, key, widget )
            arguments
                ~
                key( 1, : )char
                widget( 1, 1 )codergui.internal.form.model.Widget
            end
            if isa( widget, 'codergui.internal.form.model.Field' )
                value = widget.getValue(  );
            else
                error( 'widgetToValue should be overriden to handle custom widget for "%s"', key );
            end
        end

        function populateSubview( this, subview )
            arguments
                this
                subview( 1, 1 )coderapp.internal.config.ui.ConfigSubview
            end

            logCleanup = this.Logger.trace( 'Populating subview: %s', subview.UUID );%#ok<NASGU>
            state = this.Configuration.State;
            cats = state.Categories.toArray(  );

            for i = 1:numel( cats )
                cat = cats( i );
                binding = this.createBinding( cat );
                if ~isempty( binding )
                    binding.Key = cat.Key;
                    subview.WidgetBindings.add( binding );
                end

                params = cat.Params.toArray(  );
                for j = 1:numel( params )
                    param = params( j );
                    binding = this.createBinding( param );
                    if ~isempty( binding )
                        binding.Key = param.Key;
                        subview.WidgetBindings.add( binding );
                    end
                end
            end
        end

        function handleUiModelChange( this, report )%#ok<INUSD>
        end

        function handleConfigurationChange( this, evt )%#ok<INUSD>
        end
    end

    methods ( Sealed, Access = protected )
        function cleanup = transaction( this )
            if ~isempty( this.Transaction )
                cleanup = [  ];
                return
            end
            cleanup = onCleanup( @this.cancelTransaction );
            this.Transaction = this.MfzModel.beginTransaction(  );
        end

        function commit( this )
            if isempty( this.Transaction )
                return
            end
            this.SuppressListener = true;
            this.Transaction.commit(  );
            this.SuppressListener = false;
        end
    end

    methods ( Sealed, Access = ?coderapp.internal.config.ui.ConfigUi )
        function attachToConfiguration( this, owner, configuration, mfzModel )
            arguments
                this( 1, 1 )
                owner( 1, 1 )coderapp.internal.config.ui.ConfigUi
                configuration( 1, 1 )coderapp.internal.config.Configuration
                mfzModel( 1, 1 )mf.zero.Model = mf.zero.Model(  )
            end

            this.Owner = owner;
            this.Configuration = configuration;
            this.MfzModel = mfzModel;

            logCleanup = this.Logger.trace( 'Attaching to Configuration instance' );%#ok<NASGU>
            transaction = this.MfzModel.beginTransaction(  );
            try
                this.UiModel = this.createConfigUiModel( mfzModel );
                validateattributes( this.UiModel, { 'coderapp.internal.config.ui.ConfigUiModel' }, { 'scalar' } );
                if isempty( this.UiModel.Form )
                    this.UiModel.Form = codergui.internal.form.model.Form( mfzModel );
                end
                this.Form = this.UiModel.Form;

                if isempty( this.UiModel.DocProviderConfig )
                    this.setupDefaultDocProvider(  );
                end
                this.setupUndoRedo(  );

                this.setup(  );
                this.populate(  );
                transaction.commit(  );
            catch me
                transaction.rollBack(  );
                me.rethrow(  );
            end

            this.ConfigurationListenerHandle = this.Configuration.listener(  ...
                'ConfigurationChanged', @( ~, evt )this.aroundConfigurationChange( evt ) );
            this.SuppressListener = false;
            this.setupModelSync( owner.ModelChannel );
        end
    end

    methods ( Access = private )
        function aroundHandleUiModelChange( this, report )
            report = coderapp.internal.mfz.ChangeReportFacade( report );
            cleanup = this.transaction(  );%#ok<NASGU>
            this.handleUiModelChange( report );
            this.commit(  );
        end

        function aroundConfigurationChange( this, evt )
            cleanup = this.transaction(  );%#ok<NASGU>
            this.handleConfigurationChange( evt );
            this.commit(  );
        end

        function cancelTransaction( this )
            if ~isempty( this.Transaction )
                this.Transaction.rollBack(  );
                this.Transaction = mf.zero.Transaction.empty(  );
            end
        end

        function setupModelSync( this, channelRoot )
            if strcmp( this.ChannelRoot, channelRoot )
                return
            end
            this.ChannelRoot = channelRoot;
            if ~isempty( this.UiModelSync )
                this.UiModelSync.stop(  );
                this.UiModelSync = [  ];
                this.UiChannelObj = [  ];
                this.ConfigModelSync.stop(  );
                this.ConfigModelSync = [  ];
                this.ConfigChannelObj = [  ];
            end
            if ~isempty( channelRoot )


                uiModelChannel = [ channelRoot, '/uimodel' ];
                this.UiChannelObj = mf.zero.io.ConnectorChannelMS( uiModelChannel, uiModelChannel );
                this.UiModelSync = mf.zero.io.ModelSynchronizer( this.MfzModel, this.UiChannelObj );
                this.UiModelSync.start(  );
                configChannel = [ channelRoot, '/config' ];
                [ this.ConfigModelSync, this.ConfigChannelObj ] = this.Configuration.setupModelSync( configChannel );
                this.ConfigModelSync.start(  );
            end
        end

        function setupDefaultDocProvider( this )
            this.UiModel.DocProviderConfig = coderapp.internal.config.ui.DefaultDocProviderConfig( this.MfzModel );
            this.UiModel.DocProviderConfig.getClassReferenceProperties.registerHandler(  ...
                @( ~, className, resultHolder )this.handleClassReferenceRequest( className, resultHolder ) );
            this.UiModel.DocProviderConfig.openClassReferencePage.registerHandler(  ...
                @( ~, className, prop, resultHolder )this.handleOpenClassReferencePage( className, prop, resultHolder ) );
            this.UiModel.DocProviderConfig.openDocRef.registerHandler(  ...
                @( ~, docRef, resultHolder )this.handleOpenDocRef( docRef, resultHolder ) );
        end

        function populate( this )
            logCleanup = this.Logger.trace( 'Populating UI model' );%#ok<NASGU>
            if isempty( this.UiModel.PrimarySubview )
                this.UiModel.PrimarySubview = coderapp.internal.config.ui.ConfigSubview( this.MfzModel );
                this.UiModel.Subviews.add( this.UiModel.PrimarySubview );
            end
            this.populateSubview( this.UiModel.PrimarySubview );

            this.UiModel.setParam.registerHandler( @( ~, binding, resultHolder )this.handleSetParam( binding, resultHolder ) );
            this.UiModel.setParamJson.registerHandler( @( ~, key, json, resultHolder )this.handleSetParamJson( key, json, resultHolder ) );
            this.UiModel.resetParam.registerHandler( @( ~, key, resultHolder )this.handleResetParam( key, resultHolder ) );
            this.UiModel.refreshParam.registerHandler( @( ~, key, resultHolder )this.handleRefreshParam( key, resultHolder ) );
        end

        function handleSetParam( this, binding, resultHolder )
            this.tryChange( @(  )this.Configuration.set( binding.Key, this.widgetToValue( binding.Key, binding.Widget ) ),  ...
                resultHolder );
        end

        function handleSetParamJson( this, key, jsonValue, resultHolder )
            logCleanup = this.Logger.debug( 'Handling setParamJson request for "%s"', key );%#ok<NASGU>
            this.tryChange( @(  )this.Configuration.set( key, jsondecode( jsonValue ) ),  ...
                resultHolder );
        end

        function handleResetParam( this, key, resultHolder )
            logCleanup = this.Logger.debug( 'Handling resetParam request for "%s"', key );%#ok<NASGU>
            this.tryChange( @(  )this.Configuration.reset( key ), resultHolder );
        end

        function handleRefreshParam( this, key, resultHolder )
            logCleanup = this.Logger.debug( 'Handling refreshParam request for "%s"', key );%#ok<NASGU>
            this.tryChange( @(  )this.Configuration.refresh( key ), resultHolder );
        end

        function handleClassReferenceRequest( this, className, resultHolder )
            logCleanup = this.Logger.debug( 'Handling class reference page request for class "%s"', className );%#ok<NASGU>
            cleanup = this.transaction(  );%#ok<NASGU>
            if ~isempty( className )
                req = matlab.internal.reference.api.ReferenceRequest( className,  ...
                    matlab.internal.reference.property.RefEntityType.empty );
                data = matlab.internal.reference.api.ReferenceDataRetriever( req ).getReferenceData(  );

                if ~isempty( data ) && ~isempty( data( 1 ).ClassPropertyGroups )
                    props = [ data( 1 ).ClassPropertyGroups.ClassProperties ];
                    resultHolder.ResolvableProperties = [ props.Name ];
                else
                    resultHolder.ResolvableProperties = {  };
                end
            else
                resultHolder.ResolvableProperties = {  };
            end
            resultHolder.Passed = true;
            this.commit(  );
        end

        function handleOpenClassReferencePage( this, className, propName, resultHolder )
            cleanup = this.transaction(  );%#ok<NASGU>
            if ~isempty( propName )
                arg = sprintf( '%s.%s', className, propName );
            else
                arg = className;
            end
            logCleanup = this.Logger.debug( 'Handling request to open class reference page: %s', arg );%#ok<NASGU>
            try
                doc( arg );
                resultHolder.Passed = true;
            catch me
                resultHolder.Passed = false;
                coder.internal.gui.asyncDebugPrint( me );
                this.Logger.warn( 'Failed to open class reference page: %s', me.message );
            end
            this.commit(  );
        end

        function handleOpenDocRef( this, docRef, resultHolder )
            logCleanup = this.Logger.debug( 'Handling request to open doc page: MapFile=%s, TopicId=%s', docRef.MapFile, docRef.TopicId );%#ok<NASGU>
            if isempty( docRef.TopicId ) || isempty( docRef.MapFile )
                this.Logger.error( 'Expecting non-empty TopicId and MapFile properties' );
                resultHolder.Passed = false;
                return
            end
            try
                helpview( fullfile( docroot, docRef.MapFile ), docRef.TopicId );
                resultHolder.Passed = true;
            catch me
                resultHolder.Passed = false;
                this.Logger.warn( 'Failed to open doc ref: %s', me.message );
            end
        end

        function setupUndoRedo( this )
            logCleanup = this.Logger.trace( 'Setting up undo/redo facilities' );%#ok<NASGU>
            this.StateTracker = coderapp.internal.undo.StateTracker(  );
            this.UiModel.UndoRedoStatus = coderapp.internal.undo.UndoRedoStatus( this.MfzModel );
            this.StateTracker.ManagedStatusObject = this.UiModel.UndoRedoStatus;
            if ~isempty( this.Configuration.BoundStateTracker )
                this.Configuration.BoundStateTracker.removeStateOwner( this.Configuration );
            end
            this.StateTracker.addStateOwner( this.Configuration );
            this.UiModel.undoRedo.registerHandler( @( ~, isUndo, resultHolder )this.handleUndoRedo( isUndo, resultHolder ) );
        end

        function handleUndoRedo( this, isUndo, resultHolder )
            logCleanup = this.Logger.trace( 'Handling undo/redo: IsUndo=%g', isUndo );%#ok<NASGU>
            cleanup = this.transaction(  );%#ok<NASGU>
            try
                if isUndo
                    this.StateTracker.previous(  );
                else
                    this.StateTracker.next(  );
                end
            catch me
                resultHolder.Passed = false;
                coder.internal.gui.asyncDebugPrint( me );
            end
            this.commit(  );
        end

        function tryChange( this, changer, resultHolder )
            logCleanup = this.Logger.trace( @(  )sprintf( 'Attempting safety-guaranteed change: %s', func2str( changer ) ) );%#ok<NASGU>
            try
                changer(  );
                errMsg = codergui.internal.form.model.UiMessage.empty(  );
            catch me
                errMsg = codergui.internal.form.model.UiMessage(  );
                errMsg.Type = codergui.internal.form.model.MessageType( 'ERROR' );
                errMsg.Message = me.message;
                coder.internal.gui.asyncDebugPrint( me );
                this.Logger.debug( @(  )sprintf( 'Change %s resulted in an error: %s', func2str( changer ), me.message ) );
            end
            txn = this.MfzModel.beginTransaction(  );
            resultHolder.Passed = isempty( errMsg );
            resultHolder.Message = errMsg;
            txn.commit(  );
        end
    end
end



