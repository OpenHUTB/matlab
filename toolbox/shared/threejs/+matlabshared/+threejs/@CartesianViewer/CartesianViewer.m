classdef CartesianViewer < handle
    properties
        Figure
        HTML
        Window
        Name
        Controller
        Queue = false
    end

    properties ( Dependent )
        Position
    end

    properties ( Hidden )
        CompositeModel
    end

    properties ( Access = private, Constant )
        DEFAULT_POSITION = [ 500, 200, 800, 600 ]
        DEFAULT_NAME = message( 'shared_threejs:viewer:DefaultViewerTitle' ).getString
    end

    methods
        function viewer = CartesianViewer( NameValueArgs )
            arguments
                NameValueArgs.Position( 1, 4 )double = matlabshared.threejs.CartesianViewer.DEFAULT_POSITION
                NameValueArgs.Parent( 1, 1 )matlab.ui.Figure = uifigure( 'Position', matlabshared.threejs.CartesianViewer.DEFAULT_POSITION,  ...
                    'Name', matlabshared.threejs.CartesianViewer.DEFAULT_NAME )
                NameValueArgs.Name string = matlabshared.threejs.CartesianViewer.DEFAULT_NAME
                NameValueArgs.UseDebug = false
            end
            viewer.Figure = NameValueArgs.Parent;
            viewer.Figure.Name = NameValueArgs.Name;
            viewer.Name = NameValueArgs.Name;
            viewer.Figure.Position = NameValueArgs.Position;


            figURL = matlab.ui.internal.FigureServices.getFigureURL( viewer.Figure );
            wmgr = matlab.internal.webwindowmanager.instance;
            windowlist = wmgr.windowList;
            viewer.Window = findobj( windowlist, 'URL', figURL );


            viewer.HTML.Position = [ 0, 0, viewer.Figure.Position( 3 ), viewer.Figure.Position( 4 ) ];
            viewer.Controller = matlabshared.threejs.CartesianController( viewer.Figure, "UseDebug", NameValueArgs.UseDebug );


            viewer.CompositeModel = createCompositeModel(  );
        end

        function openDevTools( viewer )
            viewer.Window.executeJS( 'cefclient.sendMessage("openDevTools");' );
        end

        function delete( viewer )
            if ~isempty( viewer.Figure ) && isvalid( viewer.Figure )
                delete( viewer.Figure );
            end
            if ~isempty( viewer.Controller ) && isvalid( viewer.Controller )
                delete( viewer.Controller );
            end
        end
    end

    methods
        function queuePlots( viewer )
            viewer.Queue = true;
        end
        function submitPlots( viewer, args )
            arguments
                viewer
                args.Animation = 'none'
            end
            viewer.CompositeModel.Animation = args.Animation;
            viewer.Controller.request( 'composite', viewer.CompositeModel );
            viewer.CompositeModel = createCompositeModel;
            viewer.Queue = false;
        end
        function unqueuePlots( viewer )
            viewer.Queue = false;
            viewer.CompositeModel = createCompositeModel(  );
        end

        function remove( viewer, IDs )
            viewer.request( 'remove', struct( 'ID', { IDs } ) );
        end

        function clear( viewer, forceClearAll )
            if nargin < 2
                forceClearAll = false;
            end
            viewer.request( 'clear', struct( 'ForceClearAll', forceClearAll ) );
        end

        function position = get.Position( viewer )
            position = viewer.Figure.Position;
        end

        function set.Position( viewer, position )
            viewer.Figure.Position = position;
        end

        ID = model3DScene( viewer, filename, opacity )
        ID = line( viewer, positions, args )
        ID = marker( viewer, position, icon, args )
        ID = legend( viewer, title, colors, values, args )
        ID = model3D( viewer, model, position, NameValueArgs )
        setOriginVisibility( viewer, visibility )
        updateModel3DScene( viewer, ID, NameValueArgs )
    end

    methods ( Access = protected )
        function request( viewer, plotType, plotDescriptors )


            if viewer.Queue
                viewer.addToCompositeModel( plotType, plotDescriptors );
            else
                viewer.Controller.request( plotType, plotDescriptors );
            end
        end

        function addToCompositeModel( viewer, plotType, plotDescriptors )
            viewer.CompositeModel.PlotTypes{ end  + 1 } = plotType;
            viewer.CompositeModel.PlotDescriptors{ end  + 1 } = plotDescriptors;
        end
    end

    methods ( Static )
        function url = getResourceURL( filePath, URLToken )
            [ filePathFolder, fileName, fileExt ] = fileparts( filePath );
            connector.ensureServiceOn;
            contentURL = connector.addStaticContentOnPath( URLToken, filePathFolder );
            url = [ contentURL, '/', fileName, fileExt ];
        end
    end

end

function compositeModel = createCompositeModel(  )
compositeModel = struct(  ...
    'PlotTypes', { {  } },  ...
    'PlotDescriptors', { {  } } );
end

