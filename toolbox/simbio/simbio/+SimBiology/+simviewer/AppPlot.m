










classdef AppPlot<hgsetget

    properties(Access=public)
        AxesColor=[1,1,1]
        Grid='off';
        GridColor=[0.1500,0.1500,0.1500];
        Name='';
        LegendLocation='northeast';
        PlotLines=SimBiology.simviewer.AppPlotLine.empty;
        PlotStyle='line';
        XDir='normal';
        XLimMode='auto';
        XMax=10;
        XMin=1;
        XScale='linear';
        YDir='normal';
        YLimMode='auto';
        YMax=10;
        YMin=1;
        YScale='linear';
        MathLinePQNMap=[];
    end

    methods
        function obj=AppPlot(name)
            obj.Name=name;
        end

        function temp=addLine(obj,name)
            temp=SimBiology.simviewer.AppPlotLine(SimBiology.simviewer.LineTypes.STATE,name);
            obj.PlotLines(end+1)=temp;
        end

        function temp=addMathLine(obj,name,expression)
            temp=SimBiology.simviewer.AppPlotLine(SimBiology.simviewer.LineTypes.MATH,name);
            temp.Expression=expression;
            obj.PlotLines(end+1)=temp;
        end

        function temp=addExternalDataLine(obj,name,time,ydata)
            temp=SimBiology.simviewer.AppPlotLine(SimBiology.simviewer.LineTypes.EXTERNAL_DATA,name);
            temp.Time=time;
            temp.YData=ydata;

            obj.PlotLines(end+1)=temp;
        end
    end
end