classdef(ConstructOnLoad,Abstract,AllowedSubclasses={?matlab.graphics.chart.internal.PositionableChartWithAxes})...
    ChartGroup<matlab.graphics.chart.Chart

    methods(Hidden)



        function support=supportsGesture(obj,featureString)
            support=false;
            switch lower(featureString)
            case 'title'
                support=supportsTitle(obj);
            case 'legend'
                support=supportsLegend(obj);
            case 'colorbar'
                support=supportsColorbar(obj);
            case 'caxis'
                support=supportsCaxis(obj);
            case 'grid'
                support=supportsGrid(obj);
            case 'xlabel'
                support=supportsXlabel(obj);
            case 'ylabel'
                support=supportsYlabel(obj);
            end
        end
    end

end

