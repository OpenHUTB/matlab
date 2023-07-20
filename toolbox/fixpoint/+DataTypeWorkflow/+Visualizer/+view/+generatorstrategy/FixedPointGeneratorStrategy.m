classdef FixedPointGeneratorStrategy<DataTypeWorkflow.Visualizer.view.generatorstrategy.GeneratorStrategy





    methods
        function generate(this,viewData,histogramVisualizationInfo)

            representableBins=histogramVisualizationInfo.RepresentableBins;
            representableOpacity=this.generateUniformVector(representableBins,1);
            this.addGroup(viewData,representableBins,representableOpacity,DataTypeWorkflow.Visualizer.view.VisualizerColorCodes.ContainerColor);



            observedBins=histogramVisualizationInfo.HistogramData(:,1);
            overflowBins=histogramVisualizationInfo.OverflowBins;
            underflowBins=histogramVisualizationInfo.UnderflowBins;



            observedValues=histogramVisualizationInfo.HistogramData(:,4);
            observedOpacity=this.generateLinearInterpolatedVector(observedValues,this.MinOpacityValue,this.MaxOpacityValue);


            [inRangeBins,inRangeIndices]=intersect(observedBins,representableBins);
            inRangeOpacity=observedOpacity(inRangeIndices);
            this.addGroup(viewData,inRangeBins,inRangeOpacity,DataTypeWorkflow.Visualizer.view.VisualizerColorCodes.InrangeColor);


            underflowOpacity=observedOpacity(ismember(observedBins,underflowBins));
            this.addGroup(viewData,underflowBins,underflowOpacity,DataTypeWorkflow.Visualizer.view.VisualizerColorCodes.UnderflowColor);


            overflowOpacity=observedOpacity(ismember(observedBins,overflowBins));
            this.addGroup(viewData,overflowBins,overflowOpacity,DataTypeWorkflow.Visualizer.view.VisualizerColorCodes.OverflowColor);

            limits=this.extractLimits(histogramVisualizationInfo);
            this.addLimits(viewData,limits);

        end

        function yLimits=extractLimits(this,histogramVisualizationInfo)

            histogramData=histogramVisualizationInfo.HistogramData;
            observedBoundaries=[min(histogramData(:,1)),max(histogramData(:,1))];


            containerBoundaries=int32([]);
            if isFixed(histogramVisualizationInfo.ContainerType)
                representableBins=histogramVisualizationInfo.RepresentableBins;
                containerBoundaries=[min(representableBins),max(representableBins)];
            end



            allLimits=[observedBoundaries,containerBoundaries];
            yLimits=[min(allLimits),max(allLimits)];

            if(yLimits(1)==yLimits(2))
                if(yLimits(2)<this.MaxBinLimit)
                    yLimits(2)=yLimits(2)+1;
                elseif(yLimits(1)>this.MinBinLimit)
                    yLimits(1)=yLimits(1)-1;
                end
            end

        end

        function translatedVector=translate(this,bins)
            translatedVector=bins+this.ShiftFactor;
        end

    end
end


