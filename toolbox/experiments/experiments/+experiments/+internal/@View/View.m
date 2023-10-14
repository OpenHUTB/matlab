classdef View < experiments.internal.JSServiceMixin ...
        & experiments.internal.JSMiscService ...
        & experiments.internal.JSEditorService ...
        & experiments.internal.JSExecutionService ...
        & experiments.internal.JSResultService ...
        & experiments.internal.JSProjectService ...
        & experiments.internal.JSSettingsService ...
        & experiments.internal.JSAppContainerService ...
        & experiments.internal.JSAnnotationsService ...
        & experiments.internal.BatchExecutionService

    properties ( Constant )
        feature = experiments.internal.Feature(  );
    end

    properties ( SetAccess = private )
        cef
    end

    properties ( Constant, Access = private )
        channel = '/experiment_manager';
    end

    properties ( Dependent )
        debugPort
    end

    methods
        function self = View( varargin )
            import matlab.internal.lang.capability.Capability
            if ~experiments.internal.View.feature.matlabOnline

                Capability.require( 'LocalClient' );
            end


            [ hasLicense, ~ ] = builtin( 'license', 'checkout', 'neural_network_toolbox' );
            if ~hasLicense
                ME = MException( message( 'experiments:manager:NoLicense' ) );
                ME.throwAsCaller(  );
            end

            self@experiments.internal.JSServiceMixin( experiments.internal.View.channel, { 'js', 'editor', 'exec', 'exp', 'util', 'rs', 'prj', 'settings', 'appContainer', 'annotations' } );

            p = inputParser(  );
            p.addParameter( 'project', '', @( x )isvector( x ) && ischar( x ) || isscalar( x ) && isstring( x ) && x ~= "" );
            p.addParameter( 'browser', 'cef', @( x )any( validatestring( x, { 'cef', 'chrome', 'none' } ) ) );
            p.addParameter( 'debug', false, @( x )validateattributes( x, { 'logical' }, { 'scalar' } ) );
            p.addParameter( 'prototype', '', @isvarname );
            p.parse( varargin{ : } );

            if isempty( self.feature.instance )
                self.subscribe(  );
                self.feature.set( 'instance', self );
            else
                self = self.feature.instance;
            end

            if strcmp( p.Results.browser, 'none' )
                delete( self.cef );
                self.cef = [  ];
                if ~ismember( 'debug', p.UsingDefaults )
                    self.feature.set( 'debug', p.Results.debug );
                end
            else
                if ~ismember( 'prototype', p.UsingDefaults )
                    self.feature.set( 'debug', true );
                    url = self.makeURL( 'prototype', p.Results.prototype );
                else
                    if ~ismember( 'debug', p.UsingDefaults )
                        self.feature.set( 'debug', p.Results.debug );
                    end
                    url = self.makeURL(  );
                end
                switch p.Results.browser
                    case 'cef'
                        if ~isempty( self.cef )
                            if ~isvalid( self.cef )
                                self.cef = [  ];
                            elseif ~self.cef.isWindowValid(  ) ...
                                    || ~self.feature.debug && contains( self.cef.URL, '&debug=1&' ) ...
                                    || self.feature.debug && ~strcmp( self.cef.URL, url )
                                delete( self.cef );
                                self.cef = [  ];
                            end
                        end
                        if isempty( self.cef )
                            suspendEvents = self.suspendEvents( "initial" );
                            self.cef = self.launchCef( url );
                            self.cef.Title = message( 'experiments:manager:Title' ).getString(  );
                            self.cef.CustomWindowClosingCallback = @( ~, ~ )self.execExperimentStop( true );
                            self.cef.PageLoadFinishedCallback = @( ~, ~ )delete( suspendEvents );
                            self.cef.show(  );
                        else
                            self.cef.bringToFront(  );
                        end
                    case 'chrome'
                        self.launchChrome( url );
                    otherwise
                        assert( false, 'unknown browser ''%s''', p.Results.browser );
                end
                if ~ismember( 'project', p.UsingDefaults )
                    self.emit( 'openProject', p.Results.project );
                end

            end
        end

        function out = import( self, exportData )
            if self.feature.exportToEM
                out = experiments.internal.ImportDataHandler( exportData );
                experiments.internal.JSProjectService.setGetImportHandler( out );
                self.emit( 'processExportToEM' );
            end
        end

        function delete( self )
            if isequal( self, self.feature.instance )
                self.unsubscribe(  );
                delete( self.cef );
                self.feature.set( 'instance', [  ] );
            end
        end

        function self = openDevTools( self )
            if ~isempty( self.cef )
                self.cef.executeJS( 'cefclient.sendMessage("openDevTools")' );
            end
        end

        function port = get.debugPort( self )
            if isempty( self.cef )
                port = 0;
            else
                port = self.cef.RemoteDebuggingPort(  );
            end
        end
    end




    properties ( Constant )
        MaxWindowSize = [ 1600, 900 ]
    end

    methods ( Static )
        function geom = calcWindowGeometry( namedargs )


            arguments
                namedargs.pointer = get( 0, 'PointerLocation' )
                namedargs.screens = get( 0, 'MonitorPositions' )
            end


            pointer = namedargs.pointer;
            screens = namedargs.screens;
            target = screens( 1, : );
            for screen = screens'
                if pointer( 1 ) >= screen( 1 ) && pointer( 1 ) < screen( 1 ) + screen( 3 ) ...
                        && pointer( 2 ) >= screen( 2 ) && pointer( 2 ) < screen( 2 ) + screen( 4 )
                    target = screen';
                    break
                end
            end



            winSize = target( 3:4 ) * 0.83;


            winSize = min( winSize, experiments.internal.View.MaxWindowSize );


            geom( 1:2 ) = target( 1:2 ) + target( 3:4 ) / 2 - winSize / 2;
            geom( 3:4 ) = winSize;
        end

        function url = makeURL( varargin )
            p = inputParser(  );
            p.addParameter( 'prototype', '', @isvarname );
            p.parse( varargin{ : } );

            query = { [ 'channel=', experiments.internal.View.channel ] };
            if experiments.internal.View.feature.debug
                index = 'index-debug.html';
                query = [ query, { 'debug=1', 'snc=dev' } ];
            else
                index = 'index.html';
            end
            if ~ismember( 'prototype', p.UsingDefaults )
                query{ end  + 1 } = [ 'prototype=', p.Results.prototype ];
            end
            if experiments.internal.View.feature.queryClientId
                query{ end  + 1 } = [ 'queryClientId=', num2str( experiments.internal.View.feature.queryClientId ) ];
            end
            url = connector.getUrl( sprintf( '/toolbox/experiments/html/%s?%s', index, strjoin( query, '&' ) ) );
            if experiments.internal.View.feature.debug
                warning( 'Experiments:DebugOn', 'URL: %s', url );
            end
        end

        function cef = launchCef( url )
            import matlab.internal.lang.capability.Capability
            args = {  };
            if Capability.isSupported( Capability.LocalClient )

                args = { 'Position', experiments.internal.View.calcWindowGeometry(  ) };
            end
            if experiments.internal.View.feature.debug || ~isempty( experiments.internal.View.feature.queryClientId )
                port = matlab.internal.getDebugPort(  );
                warning( 'Experiments:DebugOn', 'Using debug port %d', port );
                cef = matlab.internal.webwindow( url, port, args{ : } );
            else
                cef = matlab.internal.webwindow( url, args{ : } );
            end
        end

        function launchChrome( url )
            chrome_options = {  };

            if ispc

                chrome = 'C:\PROGRA~2\Google\Chrome\Application\chrome.exe';
            elseif ismac
                chrome_options = [ chrome_options, '--new-window' ];
                chrome = 'open -n -a /Applications/Google\ Chrome.app --args';
                url = replace( url, '&', '\&' );
            elseif isunix
                chrome = 'env LD_LIBRARY_PATH= /usr/bin/google-chrome';
                url = replace( url, '&', '\&' );
            else
                assert( false, 'unknown platform' );
            end
            system( strjoin( [ chrome, url, chrome_options, '&' ] ) );
        end
    end

end

