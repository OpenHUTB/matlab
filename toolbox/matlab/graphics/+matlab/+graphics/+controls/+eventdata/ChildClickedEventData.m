classdef(ConstructOnLoad)ChildClickedEventData<event.EventData




    properties(SetAccess=private)
Axes
    end

    methods
        function data=ChildClickedEventData(button,~,~)
            data.Axes=ancestor(button,'matlab.graphics.axis.AbstractAxes');
        end
    end
end

