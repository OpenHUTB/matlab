classdef PrimitiveController<globe.internal.GlobeGraphicsController























    methods
        function primitiveController=PrimitiveController(varargin)









            primitiveController=primitiveController@globe.internal.GlobeGraphicsController(varargin{:});
        end

        function plot(primitiveController,request,plotDescriptors)
            controller=primitiveController.GlobeController;
            try
                controller.visualRequest(request,plotDescriptors);
            catch e
                throwAsCaller(e)
            end
        end
    end
end
