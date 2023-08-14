function outData=createMergedData(templateResult,mergedResult)




    outData.Object=templateResult.UniqueIdentifier.getObject;
    outData.ElementName=templateResult.getElementName;
    outData.CompiledDT=templateResult.getCompiledDT;
    outData.isScaledDouble=templateResult.isScaledDoubleType;
    outData.MinValue=templateResult.SimMin;
    outData.MaxValue=templateResult.SimMax;
    outData.DerivedMin=templateResult.DerivedMin;
    outData.DerivedMax=templateResult.DerivedMax;
    outData.OverflowOccurred=templateResult.getOverflowWrap;
    outData.SaturationOccurred=templateResult.getOverflowSaturation;
    outData.DivisionByZeroOccurred=templateResult.getDivideByZero;
    outData.WholeNumber=(templateResult.WholeNumber>0);
    outData.HistogramData=templateResult.HistogramData;
    outData.PrecisionHistogramData=templateResult.PrecisionHistogramData;
    outData.DerivedRangeIntervals=templateResult.DerivedRangeIntervals;
    outData.DerivedRangeState=templateResult.DerivedRangeState;

    outData.DesignMin=templateResult.DesignMin;
    outData.DesignMax=templateResult.DesignMax;



    outData.isStateflow=isa(templateResult.UniqueIdentifier,'fxptds.StateflowIdentifier');
    outData.dataID=[];
    if outData.isStateflow

        outData.dataID=templateResult.UniqueIdentifier.getObject.Id;
    end


    if isempty(mergedResult)
        return;
    end


    if~isempty(mergedResult.SimMin)
        if isempty(outData.MinValue)||(outData.MinValue>mergedResult.SimMin)
            outData.MinValue=mergedResult.SimMin;
        end
    end

    if~isempty(mergedResult.SimMax)
        if isempty(outData.MaxValue)||(outData.MaxValue<mergedResult.SimMax)
            outData.MaxValue=mergedResult.SimMax;
        end
    end

    if~isempty(mergedResult.DerivedMin)
        if isempty(outData.DerivedMin)||(outData.DerivedMin>mergedResult.DerivedMin)
            outData.DerivedMin=mergedResult.DerivedMin;
        end
    end

    if~isempty(mergedResult.DerivedMax)
        if isempty(outData.DerivedMax)||(outData.DerivedMax<mergedResult.DerivedMax)
            outData.DerivedMax=mergedResult.DerivedMax;
        end
    end

    if~isempty(mergedResult.getOverflowWrap)
        outData.OverflowOccurred=mergeOverflows(outData.OverflowOccurred,mergedResult.getOverflowWrap);
    end

    if~isempty(mergedResult.getOverflowSaturation)
        outData.SaturationOccurred=mergeOverflows(outData.SaturationOccurred,mergedResult.getOverflowSaturation);
    end

    if~isempty(mergedResult.getDivideByZero)
        outData.DivisionByZeroOccurred=mergeOverflows(outData.DivisionByZeroOccurred,mergedResult.getDivideByZero);
    end

    if~isempty(mergedResult.WholeNumber)
        if~isempty(outData.WholeNumber)
            outData.WholeNumber=outData.WholeNumber&&(mergedResult.WholeNumber>0);
        else
            outData.WholeNumber=(mergedResult.WholeNumber>0);
        end
    end

    outData.HistogramData=fxptds.HistogramUtil.mergeHistogramData(outData.HistogramData,mergedResult.HistogramData);

    outData.PrecisionHistogramData=fxptds.HistogramUtil.mergeHistogramData(outData.PrecisionHistogramData,mergedResult.PrecisionHistogramData);


    if~isempty(mergedResult.DerivedRangeIntervals)
        outData.DerivedRangeIntervals=SimulinkFixedPoint.AutoscalerUtils.mergeRangeIntervals(...
        [templateResult.DerivedRangeIntervals;mergedResult.DerivedRangeIntervals]);
    end

end

function overflows=mergeOverflows(outDataOverflows,mergedResultOverflows)

    if isempty(outDataOverflows)
        overflows=mergedResultOverflows;
    else
        overflows=outDataOverflows+mergedResultOverflows;
    end
end