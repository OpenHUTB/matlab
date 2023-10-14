classdef ConfigDialog < coderapp.internal.config.ui.ConfigUi

    properties ( Constant, Abstract )
        Factory( 1, 1 )coder.internal.gui.Serviceable
    end

    properties ( SetAccess = immutable )
        BoundObjectKey( 1, : )char
    end

    properties ( SetAccess = protected, Transient )
        BoundObject
    end

    properties ( Access = private, Transient )
        DeferredConfigArg
        DeferredBinding
        ListenerHandle
        RanSetup( 1, 1 )logical = false
        AllowClientReset( 1, 1 )logical = false
    end

    methods
        function this = ConfigDialog( configArg, opts )
            arguments
                configArg
                opts.Controller coderapp.internal.config.ui.ConfigDialogController{ mustBeScalarOrEmpty( opts.Controller ) } =  ...
                    coderapp.internal.config.ui.ConfigDialogController.empty(  )
                opts.Page{ mustBeTextScalar( opts.Page ) } = ''
                opts.Debug( 1, 1 ){ mustBeNumericOrLogical( opts.Debug ) } = coderapp.internal.globalconfig( 'WebDebugMode' )
                opts.Show( 1, 1 ){ mustBeNumericOrLogical( opts.Show ) } = true
                opts.BoundObject = [  ]
                opts.BoundObjectKey{ mustBeTextScalar( opts.BoundObjectKey ) } = ''
                opts.DeferSetup( 1, 1 ){ mustBeNumericOrLogical( opts.DeferSetup ) } = false
                opts.EnableLogging logical = [  ]
            end

            page = opts.Page;
            [ ~, ~, ext ] = fileparts( page );
            if isempty( ext )
                if opts.Debug
                    page = fullfile( page, 'index-debug.html' );
                else
                    page = fullfile( page, 'index.html' );
                end
            end

            controller = opts.Controller;
            if isempty( controller )
                controller = coderapp.internal.config.ui.ConfigDialogController(  );
            else
                assert( isa( controller, 'coderapp.internal.config.ui.ConfigDialogController' ),  ...
                    'Not a ConfigUiController' );
            end

            client = codergui.ReportServices.WebClientFactory.run(  ...
                page, rmfield( opts, 'Page' ),  ...
                'IdPrefix', 'cd',  ...
                'RemoteControl', true,  ...
                'EnableLogging', opts.EnableLogging );
            client.WindowSize = [ 900, 700 ];

            this@coderapp.internal.config.ui.ConfigUi( controller, client, EnableLogging = opts.EnableLogging );
            client.addlistener( 'Disposed', 'PostSet', @( ~, ~ )this.delete(  ) );

            this.BoundObjectKey = opts.BoundObjectKey;
            this.BoundObject = opts.BoundObject;
            this.DestroyConfiguration = ~isa( configArg, 'coderapp.internal.config.Configuration' );
            if opts.DeferSetup
                this.Logger.trace( 'Deferring application of configuration' );
                this.DeferredConfigArg = configArg;
            else
                this.setConfiguration( configArg );
                this.finishSetup(  );
            end

            if opts.Show
                this.show(  );
            end
        end

        function boundObj = get.BoundObject( this )
            if ~isempty( this.DeferredBinding )
                boundObj = this.DeferredBinding;
            else
                boundObj = this.BoundObject;
            end
        end

        function set.BoundObject( this, boundObj )
            if ~isempty( this.ListenerHandle )
                this.ListenerHandle = [  ];
            end
            if ~isempty( this.BoundObjectKey )
                if ~isa( boundObj, 'handle' )
                    boundObj = [  ];
                end
                if ~isempty( this.Configuration )
                    this.BoundObject = boundObj;
                    this.Configuration.set( this.BoundObjectKey, boundObj );
                    if isa( boundObj, 'handle' )
                        this.ListenerHandle = addlistener( boundObj, 'ObjectBeingDestroyed',  ...
                            @( src, ~ )this.onBoundObjectDestroyed( src ) );
                    end
                    this.Controller.postObjectBind( boundObj );
                else
                    this.DeferredBinding = boundObj;
                end
            end
        end

        function delete( this )
            this.ListenerHandle = [  ];
        end
    end

    methods ( Access = protected )
        function doShow( this )
            doShow@coderapp.internal.config.ui.ConfigUi( this );
            this.finishSetup(  );
            this.Controller.attachToUi(  );
            this.AllowClientReset = true;
            this.resetClientModel(  );
        end

        function finishSetup( this )
            if this.RanSetup
                return
            end
            this.RanSetup = true;
            logCleanup = this.Logger.debug( 'Entering finishSetup' );%#ok<NASGU>


            if ~isempty( this.DeferredConfigArg )
                arg = this.DeferredConfigArg;
                this.DeferredConfigArg = [  ];
                this.setConfiguration( arg );
            end
            binding = this.DeferredBinding;
            this.DeferredBinding = [  ];
            this.BoundObject = binding;
        end

        function resetClientModel( this )
            if ~this.AllowClientReset
                return
            end
            resetClientModel@coderapp.internal.config.ui.ConfigUi( this );
        end

        function setConfiguration( this, configuration )
            setConfiguration@coderapp.internal.config.ui.ConfigUi( this, configuration );
            assert( isa( this.Controller.UiModel, 'coderapp.internal.config.ui.ConfigDialogModel' ),  ...
                'UIModels used by ConfigDialog controllers must extend ConfigDialogModel' );
        end
    end

    methods ( Access = private )
        function onBoundObjectDestroyed( this, targetObj )

            if isvalid( this ) && ~isempty( this.BoundObject ) && this.BoundObject == targetObj
                this.Logger.info( 'Destroying UI due to bound object being destroyed' );
                this.delete(  );
            end
        end
    end
end



