classdef AbstractModeStrategy<handle




    properties
CurrentToolbar
    end

    methods(Abstract)

        handleModeChange(obj,ax,eventData);

        createListeners(obj,can,ax);

        result=hasFigureChanged(obj,fig);

        resetListeners(obj);
    end

    methods
        function fig=getCanvasFigure(~,canvas)
            if~isempty(canvas)
                fig=ancestor(canvas,'figure');
            else

                fig=[];
            end
        end
    end
end

