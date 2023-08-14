classdef SLEditorZoomHandler<handle




    methods(Abstract)

        canHandle(obj,location);

        zoomTo(obj,location);

    end
end
