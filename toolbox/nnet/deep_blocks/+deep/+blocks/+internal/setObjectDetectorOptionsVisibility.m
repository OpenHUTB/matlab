function setObjectDetectorOptionsVisibility(block)
    detectorToLoad=deep.blocks.internal.getSelectedNetwork(block);

    try
        detectorInfo=deep.blocks.internal.getDetectorInfo(block,detectorToLoad);
    catch
        detectorInfo=[];
    end

    validNetwork=~isempty(detectorInfo);

    if validNetwork
        mask=Simulink.Mask.get(block);
        threshold=mask.getParameter('Threshold');
        numStrongestRegions=mask.getParameter('NumStrongestRegions');
        useMinSize=mask.getParameter('UseMinSize');
        useMaxSize=mask.getParameter('UseMaxSize');
        setParamVisibility(threshold,detectorInfo.ThresholdSupported);
        setParamVisibility(numStrongestRegions,detectorInfo.NumStrongestRegionsSupported);
        setParamVisibility(useMinSize,detectorInfo.MinSizeSupported);
        setParamVisibility(useMaxSize,detectorInfo.MaxSizeSupported);
        deep.blocks.internal.setEnabledParameterVisibility(block,'UseMinSize','MinSize');
        deep.blocks.internal.setEnabledParameterVisibility(block,'UseMaxSize','MaxSize');
    end

end


function setParamVisibility(parameter,enable)
    if enable
        parameter.Visible='on';
        parameter.Enabled='on';
    else
        parameter.Visible='off';
        parameter.Enabled='off';
    end
end

