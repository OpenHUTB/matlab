classdef TimeAxisListenersManager









    methods(Access=public)
        function obj=TimeAxisListenersManager

        end
    end

    methods(Static,Hidden)
        function obj=loadobj(obj)














            assert(isstruct(obj));




            obj.TimeAxes.XTickMode=obj.XTickModeState;
            obj.TimeAxes.XTickLabelMode=obj.XTickLabelModeState;
            obj.TimeAxes.DataSpace.XLimWithInfsMode=obj.XLimModeState;

            obj.TimeAxes.YLimMode=obj.YLimModeState;
            obj.TimeAxes.YTickMode=obj.YTickModeState;
            obj.TimeAxes.DataSpace.YLimWithInfsMode=obj.YLimModeState;


















            mcDynaProp=addprop(obj.TimeAxes,'DatetimeDurationPlotAxesListenersManager');
            mcDynaProp.Hidden=true;
            mcDynaProp.Transient=true;






            if~isempty(obj.TimeAxes.Children)
                matlab.graphics.internal.timePlotLoadHelper(obj.TimeAxes);
            end

            obj=matlab.internal.datetime.TimeAxisListenersManager;
        end
    end
end