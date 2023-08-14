classdef SBioGSABarPlot<SimBiology.internal.plotting.sbioplot.SBioGSAPlot




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.GSA_BAR;
        end
    end




    methods(Access=protected)
        function createMPGSAPlot(obj,gsaObj)
            gsaObj.bar(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Classifiers',obj.getClassifiers(),...
            'Color',obj.convertHexToRGB(obj.definition.props.MPGSAOptions.KStatColor),...
            'PValueColor',obj.convertHexToRGB(obj.definition.props.MPGSAOptions.PValueColor));
        end

        function createSobolPlot(obj,gsaObj)
            gsaObj.bar(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Observables',obj.getObservables(),...
            'FirstOrderColor',obj.convertHexToRGB(obj.definition.props.SobolOptions.FirstOrderColor),...
            'TotalOrderColor',obj.convertHexToRGB(obj.definition.props.SobolOptions.TotalOrderColor));
        end

        function createElementaryEffectsPlot(obj,gsaObj)
            gsaObj.AbsoluteEffects=obj.getUseAbsoluteEffects(gsaObj);
            gsaObj.bar(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Observables',obj.getObservables(),...
            'ShowMean',obj.definition.props.EEOptions.ShowMean,...
            'ShowStandardDeviation',obj.definition.props.EEOptions.ShowStandardDeviation,...
            'MeanColor',obj.convertHexToRGB(obj.definition.props.EEOptions.MeanColor),...
            'StandardDeviationColor',obj.convertHexToRGB(obj.definition.props.EEOptions.StandardDeviationColor));
        end
    end




    methods(Access=protected)
        function[legendArray,dummyAxes]=getLegendArrayForExportForMPGSA(obj,destinationFigure)
            [legendArray,dummyAxes]=getLegendArrayForExportHelper(obj,destinationFigure,'',@(dummyAxes)obj.createDummyLinesForMPSGA(dummyAxes));
        end

        function[legendArray,dummyAxes]=getLegendArrayForExportForSobol(obj,destinationFigure)
            [legendArray,dummyAxes]=getLegendArrayForExportHelper(obj,destinationFigure,'',@(dummyAxes)obj.createDummyLinesForSobol(dummyAxes));
        end

        function[legendArray,dummyAxes]=getLegendArrayForExportForElementaryEffects(obj,destinationFigure)
            [legendArray,dummyAxes]=getLegendArrayForExportHelper(obj,destinationFigure,'',@(dummyAxes)obj.createDummyLinesForElementaryEffects(dummyAxes));
        end

        function dummyLines=createDummyLinesForMPSGA(obj,dummyAxes)
            kStatColor=obj.convertHexToRGB(obj.definition.props.MPGSAOptions.KStatColor);
            pValueColor=obj.convertHexToRGB(obj.definition.props.MPGSAOptions.PValueColor);

            props={'LineStyle','none','Marker','square'};
            dummyLines(1)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'MarkerEdgeColor',kStatColor,'MarkerFaceColor',kStatColor,'DisplayName','K-Statistic');
            dummyLines(2)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'MarkerEdgeColor',pValueColor,'MarkerFaceColor',pValueColor,'DisplayName','P-Value');
        end

        function dummyLines=createDummyLinesForSobol(obj,dummyAxes)
            firstOrderColor=obj.convertHexToRGB(obj.definition.props.SobolOptions.FirstOrderColor);
            totalOrderColor=obj.convertHexToRGB(obj.definition.props.SobolOptions.TotalOrderColor);

            props={'LineStyle','none','Marker','square'};
            dummyLines(1)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'MarkerEdgeColor',firstOrderColor,'MarkerFaceColor',firstOrderColor,'DisplayName','First Order Index');
            dummyLines(2)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'MarkerEdgeColor',totalOrderColor,'MarkerFaceColor',totalOrderColor,'DisplayName','Total Order Index');
        end

        function dummyLines=createDummyLinesForElementaryEffects(obj,dummyAxes)
            meanColor=obj.convertHexToRGB(obj.definition.props.EEOptions.MeanColor);
            standardDeviationColor=obj.convertHexToRGB(obj.definition.props.EEOptions.StandardDeviationColor);

            props={'LineStyle','none','Marker','square'};
            dummyLines(1)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'MarkerEdgeColor',meanColor,'MarkerFaceColor',meanColor,'DisplayName','Mean');
            dummyLines(2)=line(dummyAxes,1,1,'Visible','on','tag','dummyLineForLegend',props{:},...
            'MarkerEdgeColor',standardDeviationColor,'MarkerFaceColor',standardDeviationColor,'DisplayName','Standard Deviation');
        end
    end
end