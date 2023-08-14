
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,AllowedSubclasses={?matlab.graphics.illustration.Legend})AbstractExpandableLegend<matlab.graphics.illustration.internal.AbstractChartIllustration




    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            b=false;
        end
    end




    methods
        function hObj=AbstractExpandableLegend(varargin)









            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end







end
