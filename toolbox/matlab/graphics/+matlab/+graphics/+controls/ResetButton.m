classdef(ConstructOnLoad)ResetButton<matlab.graphics.controls.PushButton





    methods
        function obj=ResetButton()
            obj@matlab.graphics.controls.PushButton();

            obj.Icon='restoreview';

            obj.ButtonPushedFcn=@(e,d)obj.resetCallback();

            obj.Tooltip=matlab.internal.Catalog('MATLAB:uistring:figuretoolbar')...
            .getString('TooltipString_Exploration_RestoreView');
        end

        function enabled=isEnabledForAxes(~,ax)

            if isa(ax,'matlab.graphics.axis.PolarAxes')


                enabled=false;
            else
                enabled=true;
            end
        end
    end

    methods(Access=protected)
        function resetCallback(obj)
            tb=ancestor(obj,'matlab.graphics.controls.AxesToolbar','node');
            resetplotview(tb.Parent,'ApplyStoredView');
        end
    end
end

