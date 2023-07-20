classdef ValueChangedEventData


    properties(SetAccess=private)
Source
Axes
EventName
        Value matlab.lang.OnOffSwitchState
        PreviousValue matlab.lang.OnOffSwitchState
    end

    methods

        function data=ValueChangedEventData(button,~,~)
            data.Source=button;



            layout=ancestor(button,'matlab.graphics.layout.Layout');

            if~isempty(layout)&&~isempty(layout.Toolbar)&&...
                layout.Toolbar==ancestor(button,'matlab.ui.controls.AxesToolbar')
                data.Axes=layout.Children;
            else
                data.Axes=ancestor(button,'matlab.graphics.axis.AbstractAxes');
            end
            data.EventName='ValueChanged';


            data.Value=button.Value;
            data.PreviousValue=~button.Value;
        end
    end
end