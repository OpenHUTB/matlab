function addContainerInfo(obj,containerType)






    obj.ContainerType=containerType;


    obj.EpsBin=fxpHistogram.HistogramUtil.getEpsBin(containerType);



    obj.MaxAbsRangeBin=fxpHistogram.HistogramUtil.getMaxAbsRangeBin(containerType,obj.Range);



    obj.EpsBin=int32(fxpHistogram.HistogramUtil.consolidateOutlierBins(obj.EpsBin));
    obj.MaxAbsRangeBin=int32(fxpHistogram.HistogramUtil.consolidateOutlierBins(obj.MaxAbsRangeBin));


    if~isempty(obj.HistogramData)
        histogramBinData=obj.HistogramData;



        histogramBins=histogramBinData(:,1);
        obj.OverflowBins=fxpHistogram.HistogramUtil.getOverflowBins(containerType,histogramBins,obj.Range);
        obj.OverflowBins=int32(fxpHistogram.HistogramUtil.consolidateOutlierBins(obj.OverflowBins));

        obj.UnderflowBins=fxpHistogram.HistogramUtil.getUnderflowBins(containerType,histogramBins,obj.Range);
        obj.UnderflowBins=int32(fxpHistogram.HistogramUtil.consolidateOutlierBins(obj.UnderflowBins));

        representableBins=containerType.getRepresentableBins();
        obj.RepresentableBins=int32(representableBins(representableBins>=obj.BINS_LOWER_BOUND&representableBins<=obj.BINS_UPPER_BOUND));

    else
        obj.OverflowBins=[];
        obj.UnderflowBins=[];
    end
    if~isempty(obj.OverflowBins)
        obj.HasOverflows=true;
    end
    if~isempty(obj.UnderflowBins)
        obj.HasUnderflows=true;
    end
end