classdef ConfigDialogController < coderapp.internal.config.ui.ConfigUiController


    properties ( SetAccess = immutable )
        ProductionKey( 1, : )char
        ResyncProductionOnFocus( 1, 1 )logical = true
    end

    properties
        MonitorWorkspace( 1, 1 )logical = false
        ScriptVariableKey char
    end

    properties ( SetAccess = private, SetObservable )
        WorkspaceVariable char
        WindowFocused( 1, 1 )logical = false
    end

    properties ( Access = private, Transient )
        PollingTimer timer
        LastSynchronized datetime
        WorkspaceMonitorPrimed( 1, 1 )logical = false
    end

    methods
        function this = ConfigDialogController( options )
            arguments
                options.ProductionKey{ mustBeTextScalar( options.ProductionKey ) } = ''
                options.WorkspaceVariable{ mustBeTextScalar( options.WorkspaceVariable ) } = ''
                options.MonitorWorkspace{ mustBeNumericOrLogical( options.MonitorWorkspace ) } = false
                options.ResyncProductionOnFocus{ mustBeNumericOrLogical( options.ResyncProductionOnFocus ) } = true
            end

            this.ProductionKey = options.ProductionKey;
            this.WorkspaceVariable = options.WorkspaceVariable;
            this.MonitorWorkspace = options.MonitorWorkspace;

            if ~isempty( this.WorkspaceVariable ) && ~evalin( 'base',  ...
                    sprintf( 'exist("%s","var")', this.WorkspaceVariable ) )
                this.WorkspaceVariable = '';
            end
        end

        function set.MonitorWorkspace( this, monitor )
            if this.MonitorWorkspace == monitor
                return
            end
            this.MonitorWorkspace = monitor;
            if monitor
                this.setupWorkspaceMonitoring(  );
            else
                this.cleanupWorkspaceMonitor(  );
            end
        end

        function delete( this )
            if ~isempty( this.Owner.Client ) && isvalid( this.Owner.Client )
                this.Owner.Client.CustomCloseCallback = [  ];
            end
            this.cleanupWorkspaceMonitor(  );
        end
    end

    methods ( Access = protected )
        function uiModel = createConfigUiModel( ~, mfzModel )
            uiModel = coderapp.internal.config.ui.ConfigDialogModel( mfzModel );
        end

        function handleUiModelChange( this, report )
            if report.isModified( this.UiModel, 'CurrentCategoryKey' )
                this.Configuration.wake( this.UiModel.CurrentCategoryKey );
            end
        end

        function resyncBoundObject( this, force )
            arguments
                this
                force = false
            end
            if isempty( this.ProductionKey ) || this.Configuration.IsProcessing
                return
            end
            producer = this.Configuration.getProducer( this.ProductionKey );
            if ~isa( producer, 'coderapp.internal.config.util.CompositeProducer' )
                return
            end
            this.Logger.trace( 'Requesting bound object resynchronization (force=%g)', force );
            if force || isempty( this.LastSynchronized ) || ( datetime(  ) - this.LastSynchronized > duration( 0, 0, 2 ) )
                producer.resyncBoundObject(  );
                this.LastSynchronized = datetime(  );
            end
        end

        function onWindowFocusChanged( this, focused )
            arguments
                this
                focused = this.WindowFocused
            end

            this.WindowFocused = focused;
            if focused

                this.Logger.trace( 'Resyncing bound object due to focusing of the dialog window' );
                this.resyncBoundObject( true );
            end
        end
    end

    methods ( Access = { ?coderapp.internal.config.ui.ConfigDialogController, ?coderapp.internal.config.ui.ConfigDialog } )
        function attachToUi( this )
            this.UiModel.syncBoundObject.registerHandler( @( ~, resultHolder )this.handleResync( resultHolder ) );
            this.UiModel.MainProductionKey = this.ProductionKey;
            this.Configuration.TrackedScriptDeltaKeys = this.ProductionKey;
            this.UiModel.ResyncPolling = ~isempty( this.Owner.BoundObjectKey );
            this.updateVarName(  );

            if ~isempty( this.Owner.Client )
                if this.ResyncProductionOnFocus
                    this.Owner.Client.addlistener( 'WindowFocusGained', @( varargin )this.onWindowFocusChanged( true ) );
                    this.Owner.Client.addlistener( 'WindowFocusLost', @( varargin )this.onWindowFocusChanged( false ) );
                end
                this.Owner.Client.CustomCloseCallback = @(  )this.onDialogClosing(  );
            else
                this.WindowFocused = true;
            end
        end

        function postObjectBind( this, ~ )
            this.setupWorkspaceMonitoring( true );
        end
    end

    methods ( Access = private )
        function handleResync( this, resultHolder )
            cleanup = this.transaction(  );%#ok<NASGU>
            if ~isempty( this.Owner.BoundObjectKey ) && ~isempty( this.ProductionKey )
                try
                    this.resyncBoundObject(  );
                    errMsg = codergui.internal.form.model.UiMessage.empty(  );
                catch me
                    errMsg = codergui.internal.form.model.UiMessage(  );
                    errMsg.Type = codergui.internal.form.model.MessageType( 'ERROR' );
                    errMsg.Message = me.message;
                    coder.internal.gui.asyncDebugPrint( me );
                end
                resultHolder.Message = errMsg;
                resultHolder.Passed = isempty( errMsg );
            else
                resultHolder.Passed = true;
            end
            this.commit(  );
        end

        function cleanupWorkspaceMonitor( this )
            if ~isempty( this.PollingTimer )
                this.PollingTimer.stop(  );
                this.PollingTimer.delete(  );
                this.PollingTimer = timer.empty(  );
            end
        end

        function setupWorkspaceMonitoring( this, reset )
            arguments
                this
                reset = false
            end
            if ~isempty( this.PollingTimer )
                if reset
                    this.cleanupWorkspaceMonitor(  );
                else
                    return
                end
            end
            if ~this.MonitorWorkspace || isempty( this.Owner ) || isempty( this.Owner.BoundObject )
                return
            end
            this.Logger.debug( 'Setting up polling for workspace monitoring of bound object' );
            this.WorkspaceMonitorPrimed = false;
            this.PollingTimer = timer(  ...
                'ExecutionMode', 'fixedSpacing',  ...
                'ObjectVisibility', 'off',  ...
                'Period', 2,  ...
                'StartDelay', 0.1,  ...
                'TimerFcn', @( ~, ~ )this.updateWorkspaceMonitor(  ),  ...
                'Tag', sprintf( 'CompositeProducerPoll[%s]', this.Owner.BoundObjectKey ) );
            this.PollingTimer.start(  );
        end

        function updateWorkspaceMonitor( this )
            boundObj = this.Owner.BoundObject;
            matched = false;
            if ~isempty( this.WorkspaceVariable )
                varInfo = evalin( 'base', sprintf( 'whos("%s")', this.WorkspaceVariable ) );
                if ~isempty( varInfo )
                    liveValue = evalin( 'base', varInfo.name );
                    if isscalar( liveValue ) && liveValue == boundObj
                        matched = true;
                    end
                end
            end
            if ~matched

                if this.WorkspaceMonitorPrimed
                    this.Logger.debug( 'Closing config dialog due to absence of bound variable "%s"', this.WorkspaceVariable );
                    this.Owner.delete(  );
                else
                    this.Logger.trace( 'Deactivating workspace monitoring for bound object' );
                    this.cleanupWorkspaceMonitor(  );
                end
            elseif ~this.WorkspaceMonitorPrimed
                this.Logger.debug( 'Workspace monitoring for bound variable "%s" fully activated', this.WorkspaceVariable );
                this.WorkspaceMonitorPrimed = true;
            end
        end

        function updateVarName( this, varName )
            arguments
                this
                varName = this.WorkspaceVariable
            end

            this.WorkspaceVariable = varName;
            this.UiModel.BoundVariableName = varName;
        end

        function onDialogClosing( this )
            if ~isempty( this.WorkspaceVariable )
                this.Logger.debug( 'Hiding config dialog instead of disposing' );
                this.Owner.Client.hide(  );
            else
                this.Owner.Client.dispose(  );
            end
        end
    end
end


