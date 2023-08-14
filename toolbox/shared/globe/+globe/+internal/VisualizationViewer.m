classdef VisualizationViewer<globe.internal.GlobeGraphicsViewer

    properties(Hidden)
        PrimitiveController globe.internal.PrimitiveController=globe.internal.PrimitiveController.empty
    end

    methods
        function viewer=VisualizationViewer(globeController)
            viewer=viewer@globe.internal.GlobeGraphicsViewer(globeController);
        end
    end

    methods(Abstract)
        [IDs,plotDescriptors]=buildPlotDescriptors(viewer,locations,varargin)
    end
end