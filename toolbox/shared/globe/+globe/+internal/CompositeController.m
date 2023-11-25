classdef CompositeController<globe.internal.GlobeGraphicsController

    methods
        function CompositeController=CompositeController(varargin)

            CompositeController=CompositeController@globe.internal.GlobeGraphicsController(varargin{:});
        end

        function composite(CompositeController,plotDescriptors)
            controller=CompositeController.GlobeController;
            if(nargout<2)
                try
                    controller.visualRequest('composite',plotDescriptors);
                catch e
                    throwAsCaller(e)
                end
            end
        end
    end
end
