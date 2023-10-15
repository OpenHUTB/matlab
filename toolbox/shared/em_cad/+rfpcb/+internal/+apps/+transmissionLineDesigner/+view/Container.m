classdef Container < matlab.ui.container.internal.AppContainer

    properties ( Access = private )
        Logger
    end

    methods

        function obj = Container( Logger, options )

            arguments
                Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
                options.Tag = '';
                options.Title = '';
            end
            obj.Logger = Logger;
            obj.Tag = options.Tag;
            obj.Title = options.Title;

            debug( obj.Logger, [ 'AppContainer = matlab.ui.container.internal.AppContainer("Tag", "', options.Tag, '", "Title", "', options.Title, '");' ] );

            defaultLayout( obj );
        end


        function defaultLayout( obj )
            obj.DocumentGridDimensions = [ 2, 2 ];
            obj.DocumentTileCoverage = [ 1, 2;3, 3 ];
            obj.DocumentColumnWeights = [ 0.6, 0.4 ];
            obj.DocumentRowWeights = [ 0.8, 0.2 ];
        end


        function rtn = getCurrentState( obj )

            rtn = struct;
            props = properties( obj );
            props
            rtn.ContainerState = cellfun( @( x )obj.( x ), props, 'UniformOutput', false );
        end
    end
end



