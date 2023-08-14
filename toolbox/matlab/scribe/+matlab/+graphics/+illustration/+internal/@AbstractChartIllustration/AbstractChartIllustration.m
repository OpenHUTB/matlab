
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true,AllowedSubclasses={?matlab.graphics.illustration.internal.AbstractComputedLegend,?matlab.graphics.illustration.internal.AbstractExpandableLegend})AbstractChartIllustration<matlab.graphics.primitive.world.Group&matlab.graphics.internal.Legacy&matlab.graphics.mixin.Selectable&matlab.graphics.internal.GraphicsJavaVisible&matlab.graphics.mixin.UIParentable&matlab.graphics.mixin.Background&matlab.graphics.mixin.ChartLayoutable




    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            b=false;
        end
    end





    methods
        function hObj=AbstractChartIllustration(varargin)









            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end



    methods(Access='public',Hidden=true)

        varargout=setParentImpl(hObj,proposedValue)
    end




end
