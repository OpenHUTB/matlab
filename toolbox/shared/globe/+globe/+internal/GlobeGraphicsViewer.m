classdef(Hidden)GlobeGraphicsViewer<handle




















    properties(GetAccess=public,SetAccess=protected,Hidden)
        GraphicsController globe.internal.GlobeGraphicsController=globe.internal.GlobeGraphicsController.empty
    end

    methods
        function viewer=GlobeGraphicsViewer(globeController)









            if nargin<1
                globeController=globe.internal.GlobeController;
            end
            graphicsController=globe.internal.GlobeGraphicsController(globeController);
            viewer.GraphicsController=graphicsController;
        end


        function data=remove(viewer,id,waitForResponse,queue)
            data=remove(viewer.GraphicsController,id,waitForResponse,queue);
        end


        function clear(viewer)
            clear(viewer.GraphicsController)
        end


        function delete(viewer)
            if~isempty(viewer)&&~isempty(viewer.GraphicsController)&&isvalid(viewer.GraphicsController)
                delete(viewer.GraphicsController)
            end
        end
    end
end
