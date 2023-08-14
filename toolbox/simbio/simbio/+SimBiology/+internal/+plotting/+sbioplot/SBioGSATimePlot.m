classdef SBioGSATimePlot<SimBiology.internal.plotting.sbioplot.SBioGSAPlot




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.GSA_TIME;
        end
    end




    methods(Access=protected)
        function createSobolPlot(obj,gsaObj)



            currentColorOrder=colororder(obj.figure.handle);
            currentColorOrder(1,:)=obj.convertHexToRGB(obj.definition.props.SobolOptions.FirstOrderColor);
            currentColorOrder(2,:)=obj.convertHexToRGB(obj.definition.props.SobolOptions.TotalOrderColor);
            colororder(obj.figure.handle,currentColorOrder);

            gsaObj.plot(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Observables',obj.getObservables(),...
            'VarianceColor',obj.convertHexToRGB(obj.definition.props.SobolOptions.VarianceColor),...
            'DelimiterColor',obj.convertHexToRGB(obj.definition.props.SobolOptions.DelimiterColor));
        end

        function createElementaryEffectsPlot(obj,gsaObj)
            gsaObj.AbsoluteEffects=obj.getUseAbsoluteEffects(gsaObj);
            gsaObj.plot(obj.figure.handle,'Parameters',obj.getParameters(),...
            'Observables',obj.getObservables(),...
            'ShowMean',obj.definition.props.EEOptions.ShowMean,...
            'ShowStandardDeviation',obj.definition.props.EEOptions.ShowStandardDeviation,...
            'MeanColor',obj.convertHexToRGB(obj.definition.props.EEOptions.MeanColor),...
            'StandardDeviationColor',obj.convertHexToRGB(obj.definition.props.EEOptions.StandardDeviationColor));
        end
    end


    methods(Access=protected)
        function updateTrellisTickLabels(obj)
            updateTrellisTickLabels@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj);
        end
    end
end