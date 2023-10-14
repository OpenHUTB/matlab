classdef ConfigUi < coderapp.internal.log.HierarchyLoggable



    properties ( Hidden, SetAccess = immutable, Transient )
        Client codergui.WebClient = codergui.internal.WebWindowWebClient.empty(  )
        Controller coderapp.internal.config.ui.ConfigUiController = coderapp.internal.config.ui.ConfigUiController.empty
    end

    properties ( SetAccess = private, Transient )
        Configuration coderapp.internal.config.Configuration
    end

    properties ( GetAccess = { ?coderapp.internal.config.ui.ConfigUi, ?coderapp.internal.config.ui.ConfigUiController },  ...
            SetAccess = immutable, Transient )
        ModelChannel( 1, : )char
    end

    properties ( Access = protected )
        DestroyConfiguration( 1, 1 )logical = true
    end

    properties ( SetAccess = private, Transient )
        Showing( 1, 1 )logical = false
    end

    methods
        function this = ConfigUi( controller, webClient, opts )
            arguments
                controller( 1, 1 )coderapp.internal.config.ui.ConfigUiController
                webClient codergui.WebClient = codergui.internal.WebWindowWebClient.empty(  )
                opts.ConfigArg{ mustBeConfigurationOrSchema( opts.ConfigArg ) } = coderapp.internal.config.Schema.empty(  )
                opts.ParentLoggable{ mustBeA( opts.ParentLoggable, [ "coderapp.internal.log.Loggable", "coderapp.internal.log.Logger" ] ) } =  ...
                    coderapp.internal.log.DummyLogger.empty(  )
                opts.EnableLogging logical = [  ]
            end

            this@coderapp.internal.log.HierarchyLoggable( 'configui', Parent = opts.ParentLoggable, EnableLogging = opts.EnableLogging );
            this.Controller = controller;
            controller.Logger = this.Logger;
            this.Client = webClient;

            if ~isempty( webClient )
                this.ModelChannel = [ webClient.ChannelGroup, '/model' ];
            else
                this.ModelChannel = '';
            end
            if ~isempty( opts.ConfigArg )
                this.setConfiguration( configArg );
            end
        end

        function goTo( this, key )
            arguments
                this( 1, 1 )
                key{ mustBeTextScalar( key ) } = ''
            end
            if this.preRequest(  ) && ismember( key, this.Configuration.Keys )
                this.Controller.UiModel.goToKey.emit( key, codergui.internal.form.model.ResultHolder( this.Controller.MfzModel ) );
            end
        end

        function search( this, query )
            arguments
                this( 1, 1 )
                query{ mustBeTextScalar( query ) } = ''
            end
            if this.preRequest(  )
                this.Controller.UiModel.search.emit( query, codergui.internal.form.model.ResultHolder( this.Controller.MfzModel ) );
            end
        end

        function delete( this )
            if ~isempty( this.Client ) && isvalid( this.Client )
                this.Client.delete(  );
            end
            if ~isempty( this.Controller ) && isvalid( this.Controller )
                this.Controller.delete(  );
            end
            if this.DestroyConfiguration
                this.Configuration.delete(  );
            end
        end
    end

    methods ( Sealed )
        function show( this )
            if this.Showing
                if ~isempty( this.Client )
                    this.Client.show(  );
                end
                return
            end
            this.doShow(  );
            this.Showing = true;
        end

        function close( this )
            if ~this.Showing
                return
            end
            this.doClose(  );
            this.Showing = false;
        end
    end

    methods ( Access = protected )
        function doShow( this )
            if ~isempty( this.Client )
                logCleanup = this.Logger.trace( 'Entering doShow' );%#ok<NASGU>
                if ~this.Showing
                    this.Logger.trace( 'Processing first time show' );
                    this.Showing = true;
                    this.Client.subscribe( 'requestModel', @( ~, ~ )this.resetClientModel(  ) );
                else
                    this.Logger.trace( 'Already showing; bringing to front' );
                end
                this.Client.show(  );
            end
        end

        function doClose( this )
            if ~isempty( this.Client )
                this.Client.dispose(  );
            end
        end

        function setConfiguration( this, configArg )
            arguments
                this( 1, 1 )
                configArg( 1, 1 ){ mustBeConfigurationOrSchema( configArg ) }
            end

            logCleanup = this.Logger.info( 'Applying Configuration to ConfigUI' );%#ok<NASGU>
            if isa( configArg, 'coderapp.internal.config.Schema' )
                configArg = coderapp.internal.config.Configuration( configArg, Parent = this );
            end

            this.Configuration = configArg;
            if ~isempty( this.Client )
                this.Configuration.Debug = this.Client.Debug;
            end
            this.Controller.attachToConfiguration( this, configArg );
            this.resetClientModel(  );
        end

        function resetClientModel( this )
            if ~this.Showing || isempty( this.Configuration )
                return
            end
            data.channel = this.ModelChannel;
            data.configUuid = this.Configuration.State.UUID;
            data.uiModelUuid = this.Controller.UiModel.UUID;
            this.Logger.debug( 'Rebroadcasting model sync parameters: channel=%s, configUuid=%s, uiModelUuid=%s',  ...
                data.channel, data.configUuid, data.uiModelUuid );
            this.Client.publish( 'resetModel', data );
        end
    end

    methods ( Access = private )
        function pass = preRequest( this )
            this.show(  );
            pass = ~isempty( this.Configuration );
        end
    end
end


function mustBeConfigurationOrSchema( arg )
if isempty( arg )
    return
end
if isobject( arg )
    validateattributes( arg, { 'coderapp.internal.config.Configuration',  ...
        'coderapp.internal.config.Schema' }, { 'scalar' } );
else
    assert( isfile( arg ), 'Must be a valid configuration, schema, or file path' );
end
end


