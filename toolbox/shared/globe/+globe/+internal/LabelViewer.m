classdef ( Hidden )LabelViewer < globe.internal.VisualizationViewer



















    methods
        function viewer = LabelViewer( globeController )
            if nargin < 1
                globeController = globe.internal.GlobeController;
            end

            viewer = viewer@globe.internal.VisualizationViewer( globeController );
            primitiveController = globe.internal.PrimitiveController( globeController );
            viewer.PrimitiveController = primitiveController;
        end

        function [ IDs, plotDescriptors ] = label( viewer, text, location, varargin )
            [ IDs, plotDescriptors ] = viewer.buildPlotDescriptors( text, location, varargin{ : } );
            viewer.PrimitiveController.plot( 'label', plotDescriptors );
        end

        function [ ID, plotDescriptors ] = buildPlotDescriptors( viewer, text, location, nameValueArgs )
            arguments
                viewer( 1, 1 )globe.internal.LabelViewer
                text( 1, 1 )string
                location( 1, 3 )double
                nameValueArgs.FontSize( 1, 1 )double = 14
                nameValueArgs.Font( 1, 1 )string = "monospace"
                nameValueArgs.ID = [  ]
                nameValueArgs.WaitForResponse( 1, 1 )logical = true
                nameValueArgs.Animation = 'none'
                nameValueArgs.Color( 1, 3 )double = [ 1, 1, 1 ]
                nameValueArgs.InitiallyVisible( 1, 1 )logical = true
                nameValueArgs.Offset( 1, 2 )double = [ 15, 0 ]
                nameValueArgs.BackgroundColor( 1, 4 )double = [ 0, 0, 0, 0.5 ]
            end
            primitiveController = viewer.PrimitiveController;
            if isempty( nameValueArgs.ID )
                nameValueArgs.ID = primitiveController.getId( 1 );
            end
            ID = nameValueArgs.ID;
            plotDescriptors = struct(  ...
                'ID', ID,  ...
                'Location', location,  ...
                'Text', text,  ...
                'Font', nameValueArgs.FontSize * 2 + "px" + " " + nameValueArgs.Font,  ...
                'Color', nameValueArgs.Color,  ...
                'InitiallyVisible', nameValueArgs.InitiallyVisible,  ...
                'Animation', nameValueArgs.Animation,  ...
                'Offset', nameValueArgs.Offset,  ...
                'BackgroundColor', nameValueArgs.BackgroundColor,  ...
                'WaitForResponse', nameValueArgs.WaitForResponse,  ...
                'EnableWindowLaunch', true );
        end
    end
end


