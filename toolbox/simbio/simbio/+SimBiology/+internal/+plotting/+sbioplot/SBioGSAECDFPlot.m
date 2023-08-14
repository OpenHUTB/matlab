classdef SBioGSAECDFPlot<SimBiology.internal.plotting.sbioplot.SBioGSAPlot




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.GSA_ECDF;
        end
    end




    methods(Access=protected)
        function createMPGSAPlot(obj,gsaObj)
            gsaObj.plot(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Classifiers',obj.getClassifiers(),...
            'AcceptedSamplesColor',obj.convertHexToRGB(obj.definition.props.MPGSAOptions.AcceptedSamplesColor),...
            'RejectedSamplesColor',obj.convertHexToRGB(obj.definition.props.MPGSAOptions.RejectedSamplesColor));
        end
    end




    methods(Access=protected)
        function[legendArray,dummyAxes]=getLegendArrayForExportForMPGSA(obj,destinationFigure)
            [legendArray,dummyAxes]=getLegendArrayForExportHelper(obj,destinationFigure,'',@(dummyAxes)obj.createDummyLinesForMPSGA(dummyAxes));
        end

        function dummyLines=createDummyLinesForMPSGA(obj,dummyAxes)
            acceptedSamplesColor=obj.convertHexToRGB(obj.definition.props.MPGSAOptions.AcceptedSamplesColor);
            rejectedSamplesColor=obj.convertHexToRGB(obj.definition.props.MPGSAOptions.RejectedSamplesColor);

            props={'LineStyle','-'};
            dummyLines(1)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'Color',acceptedSamplesColor,'DisplayName','Accepted Samples');
            dummyLines(2)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'Color',rejectedSamplesColor,'DisplayName','Rejected Samples');
        end
    end
end