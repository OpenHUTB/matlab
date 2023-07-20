function[min,max]=gatherDesignMinMax(h,blkObj,pathItem)%#ok<INUSL>






    min=[];
    max=[];

    if~isequal(pathItem,'1')
        DAStudio.error('SimulinkFixedPoint:autoscaling:invalidSFData');
    end

    parsedInfo=sf('DataParsedInfo',blkObj.Id);


    if~isempty(parsedInfo)
        min=double(parsedInfo.range.minimum);
        max=double(parsedInfo.range.maximum);

        if isinf(min)||isnan(min)
            min=[];
        end

        if isinf(max)||isnan(max)
            max=[];
        end
    end




