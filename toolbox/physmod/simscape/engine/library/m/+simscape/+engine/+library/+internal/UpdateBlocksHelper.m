function UpdateBlocksHelper(h)






    if h.CheckFlags.BlockReplace
        ReplaceInfo=getReplaceInfo();
        replaceBlocks(h,ReplaceInfo);
    end

end

function ReplaceInfo=getReplaceInfo

    ReplaceInfo={...
    {'MaskType','Simulink-PS Converter'},@UpdateConverterToSlUnit;...
    {'MaskType','PS-Simulink Converter'},@UpdateConverterToSlUnit;...
    {'BlockType','SimscapeBlock'},@UpdateParamUnitsToSlUnits;...
    {'BlockType','SimscapeComponentBlock'},@UpdateParamUnitsToSlUnits;...
    };

    ReplaceInfo=cell2struct(ReplaceInfo,{'BlockDesc','ReplaceFcn'},2);

end