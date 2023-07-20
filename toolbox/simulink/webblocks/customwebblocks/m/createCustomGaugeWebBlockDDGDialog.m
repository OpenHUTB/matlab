function obj=createCustomGaugeWebBlockDDGDialog(h,className)
    blockType=get_param(h,'BlockType');
    if strcmp(blockType,'CustomWebBlock')
        obj=customwebblocksdlgs.CustomWebBlock(h);
    else
        obj=customwebblocksdlgs.CustomTuningWebBlock(h);
    end
end