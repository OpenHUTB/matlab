

function[canShow,displayText,dataType]=getDisplayValue(runtimeValue)
    [canShowX,displayTextX,dataTypeX]=getDisplayValueHelper(runtimeValue);
    canShow=canShowX;
    displayText=displayTextX;
    dataType=dataTypeX;
    if(isa(runtimeValue,'Simulink.Parameter')&&isscalar(runtimeValue))
        [canShowX,displayTextX,~]=getDisplayValueHelper(runtimeValue.Value);
        canShow=canShowX;
        displayText=displayTextX;
        if(~canShow)
            displayText='';
        end
    end
end

function[canShow,displayText,dataType]=getDisplayValueHelper(runtimeValue)
    try
        canShow=getCanShow(runtimeValue);
        dataType=getDataType(runtimeValue);
        if canShow&&issparse(runtimeValue)
            runtimeValue=full(runtimeValue);
        end

        displayText=getDisplayText(runtimeValue,dataType,canShow);
    catch
        canShow=false;
        displayText='';
        dataType='';
    end
end

function dataType=getDataType(runtimeValue)
    dims=size(runtimeValue);
    numDim=length(dims);

    valueType=class(runtimeValue);
    if(numDim==2)
        dataType=sprintf('%dx%d %s',dims(1),dims(2),valueType);
    elseif(numDim==3)
        dataType=sprintf('%dx%dx%d %s',dims(1),dims(2),dims(3),valueType);
    else
        dataType=sprintf('%d-D %s',numDim,valueType);
    end
end

function canShow=getCanShow(runtimeValue)
    if ischar(runtimeValue)
        canShow=true;
    else
        MAX_SIZE=10;
        canShow=numel(runtimeValue)<=MAX_SIZE&&ismatrix(runtimeValue)&&...
        (isnumeric(runtimeValue)||islogical(runtimeValue)||issparse(runtimeValue));
    end
end

function displayText=getDisplayText(runtimeValue,dataType,canShow)
    if canShow
        if ischar(runtimeValue)
            displayText=runtimeValue;
        else
            displayText=mat2str(runtimeValue);
        end
    else
        displayText=dataType;
    end
end
