classdef GlobeGraphicsController<handle


    properties(SetAccess=protected)
        GlobeController globe.internal.GlobeController=globe.internal.GlobeController.empty
    end


    properties(Access=private)
        pUID=1
    end


    methods
        function graphicsController=GlobeGraphicsController(globeController)

            if nargin>0
                graphicsController.GlobeController=globeController;
            else
                graphicsController.GlobeController=globe.internal.GlobeController;
            end
        end


        function data=remove(graphicController,id,waitForResponse,queue)
            if(~iscell(id))
                id=num2cell(id);
            end
            data=struct('EnableWindowLaunch',true,...
            'Animation','',...
            'WaitForResponse',waitForResponse,...
            'ID',{id});
            if(~queue)
                try
                    graphicController.GlobeController.visualRequest('remove',data);
                catch e
                    throwAsCaller(e)
                end
            end

        end

        function ids=getId(graphicsController,numIds)

            ids=graphicsController.GlobeController.getId(numIds);
        end

        function clear(graphicController)
            try
                graphicController.GlobeController.removeVisualRequest('clear');
            catch e
                throwAsCaller(e)
            end
        end
    end
end
