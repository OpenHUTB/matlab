
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,AllowedSubclasses={?matlab.graphics.illustration.internal.AbstractLegend,?matlab.graphics.illustration.BubbleLegend})AbstractComputedLegend<matlab.graphics.illustration.internal.AbstractChartIllustration




    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            b=false;
        end
    end




    methods
        function hObj=AbstractComputedLegend(varargin)









            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end







end
