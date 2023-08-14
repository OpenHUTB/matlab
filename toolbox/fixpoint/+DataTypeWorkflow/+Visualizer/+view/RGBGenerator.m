classdef RGBGenerator<handle








    properties(Constant)
        ZERO=129;
    end

    properties(SetAccess=private)
RGB
YLimits
GlobalYLimit
HistogramRenderingData


        HistogramGeneratorStrategy=DataTypeWorkflow.Visualizer.view.generatorstrategy.FixedPointGeneratorStrategy;

    end
    methods

        function constructVisualizationData(this)











            numSignals=numel(this.HistogramRenderingData);
            this.RGB=cell(numSignals,1);

            ylimits=cell(numSignals,1);

            for idx=1:numSignals
                histogramVisualizationData=this.HistogramRenderingData{idx};
                if~isempty(histogramVisualizationData.HistogramData)
                    histogramView=DataTypeWorkflow.Visualizer.view.HistogramView;
                    this.HistogramGeneratorStrategy.generate(histogramView,histogramVisualizationData);
                    this.RGB{idx}=[histogramView.RGBColorVector;histogramView.RGBValueVector];
                    ylimits{idx}=histogramView.YLimits;
                end
            end



            ylimit=int32([ylimits{:}]);
            ylimit=[min(ylimit),max(ylimit)];

            this.YLimits=ylimits;
            this.GlobalYLimit=ylimit;

        end

        function setHistogramVisualizationInfo(this,histogramVisualizationData)
            this.HistogramRenderingData=histogramVisualizationData;
        end

        function setHistogramGeneratorStrategy(this,strategy)
            this.HistogramGeneratorStrategy=strategy;
        end
    end


end


