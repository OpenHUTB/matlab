function[min,max]=gatherDesignMinMax(~,dataObjectWrapper,~)







    min=dataObjectWrapper.Object.Min;
    max=dataObjectWrapper.Object.Max;

    if min==-inf
        min=[];
    end

    if max==inf
        max=[];
    end
end