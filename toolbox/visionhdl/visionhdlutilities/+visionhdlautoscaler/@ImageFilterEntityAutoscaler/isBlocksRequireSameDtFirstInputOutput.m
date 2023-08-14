function isFirstInOut=isBlocksRequireSameDtFirstInputOutput(~,blk)





    searchPairSets={...
    {'BlockType','MATLABSystem','MaskType','Image Filter','OutputDataTypeStr','Inherit: Same as first input'},...
    {'BlockType','Image Filter','OutDataTypeStr','Inherit: Same as first input'},...
    {'BlockType','visionhdl.ImageFilter','OutDataTypeStr','Inherit: Same as first input'},...
    };

    isFirstInOut=SimulinkFixedPoint.EntityAutoscalerUtils.searchPairs2Blk(blk,searchPairSets);

end


