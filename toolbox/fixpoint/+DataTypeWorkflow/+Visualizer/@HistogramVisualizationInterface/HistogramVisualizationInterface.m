classdef HistogramVisualizationInterface<handle









    properties(Constant)
        BINS_LOWER_BOUND=-128
        BINS_UPPER_BOUND=127
        ZERO=129
    end



    properties
HistogramData


        HasOverflows=false;
        HasUnderflows=false;
        ZeroOvNum=0;
        ZeroUnNum=0;
        ZeroInNum=0;
        HasActualOverflows=false;
Range
ContainerType
RepresentableBins
EpsBin
MaxAbsRangeBin
OverflowBins
UnderflowBins
    end
    methods
        function obj=HistogramVisualizationInterface(rangeObject,histogramData)



            obj.Range=rangeObject;

            if~isempty(histogramData)&&~isempty(histogramData.BinData)
                histogramBinData=histogramData.BinData;



                histogramBinData=fxpHistogram.HistogramUtil.consolidateOutlierBinData(histogramBinData);


                obj.HistogramData=fxpHistogram.HistogramUtil.getCombinedHistograms(histogramBinData);
            end
        end
        addContainerInfo(this,containerType);
        isUnderflowFlag=hasUnderflows(this);
    end
    methods(Static)


        minOverflowBin=findMinOverflowBin(histogramBins,overflowBins);



        maxUnderflowBins=findMaxUnderflowBin(histogramBins,underflowBins);
    end
end
