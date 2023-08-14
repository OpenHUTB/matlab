classdef(ConstructOnLoad)SelectionChangedEventData<event.EventData


    properties
        Axes;
        Selection;
        PreviousSelection;
    end

    methods
        function obj=SelectionChangedEventData(source,prevSel)


            layout=ancestor(source,'matlab.graphics.layout.Layout');

            if~isempty(layout)&&~isempty(layout.Toolbar)&&...
                layout.Toolbar==ancestor(source,'matlab.ui.controls.AxesToolbar')
                obj.Axes=layout.Children;
            else
                obj.Axes=ancestor(source,'matlab.graphics.axis.AbstractAxes');
            end
            obj.Selection=source;
            obj.PreviousSelection=prevSel;
        end
    end
end

