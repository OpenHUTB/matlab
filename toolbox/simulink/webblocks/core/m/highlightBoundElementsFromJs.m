function highlightBoundElementsFromJs(modelHandle,blockHandle)
    if(~isnumeric(modelHandle))
        modelHandle=str2double(modelHandle);
    end
    if(~isnumeric(blockHandle))
        blockHandle=str2double(blockHandle);
    end
    Simulink.HMI.highlightBoundElements(modelHandle,blockHandle);
end
