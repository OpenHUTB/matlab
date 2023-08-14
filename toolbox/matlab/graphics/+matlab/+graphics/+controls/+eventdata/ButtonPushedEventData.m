classdef ButtonPushedEventData


    properties(SetAccess=private)
Source
Axes
EventName
    end

    methods

        function data=ButtonPushedEventData(button,~,~)
            data.Source=button;



            layout=ancestor(button,'matlab.graphics.layout.Layout');

            if~isempty(layout)&&~isempty(layout.Toolbar)&&...
                layout.Toolbar==ancestor(button,'matlab.ui.controls.AxesToolbar')
                data.Axes=layout.Children;
            else
                data.Axes=ancestor(button,'matlab.graphics.axis.AbstractAxes');
            end

            data.EventName='ButtonPushed';
        end
    end
end