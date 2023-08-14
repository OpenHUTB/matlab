function checkRadiusVsNumElements(obj,R)

    if~isempty(obj.NumElements)
        isElementsPerRingIntegerMultiple=mod(obj.NumElements,numel(R))==0;
        if~isElementsPerRingIntegerMultiple
            error(message('antenna:antennaerrors:ElementsPerRingIntegerMultiple'));
        end
    end