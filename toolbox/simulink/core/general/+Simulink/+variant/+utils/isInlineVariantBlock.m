function flag=isInlineVariantBlock(blockH)






    flag=false;
    if isempty(blockH)
        return;
    end
    blockType=get_param(blockH,'BlockType');

    flag=strcmp(blockType,'VariantSource')||...
    strcmp(blockType,'VariantSink')||...
    strcmp(blockType,'VariantPMConnector')||...
    Simulink.variant.utils.isSingleChoiceVariantInfoBlock(blockH);
end