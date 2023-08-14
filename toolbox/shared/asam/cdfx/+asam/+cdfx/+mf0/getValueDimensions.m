function dimensions=getValueDimensions(valueContElement,numDims,valueType,hasVG)




    getFunction=""+valueType;
    dimensions=zeros(1,numDims);


    if~isempty(valueContElement.SW_ARRAYSIZE)
        swArraySize=valueContElement.SW_ARRAYSIZE;
        numDims=size(swArraySize.V);
        dims=zeros(1,numDims);
        for idx=1:numDims
            switch valueType
            case "V"
                dims(idx)=str2double(swArraySize.V(idx).elementValue);
            case "VT"
                dims(idx)=str2double(swArraySize.VT(idx).elementValue);
            end
        end

    elseif hasVG

    else
        if numDims==1
            valArray=eval("valueContElement.SW_VALUES_PHYS."+getFunction);
            for idx=1:numDims
                [~,dimensions(idx)]=size(valArray);
            end
        end
    end
end

