function variantBlocks=getVariantBlocks(modelName)





    vsrcCell=find_system(modelName,'MatchFilter',@Simulink.match.allVariants,'BlockType','VariantSource');
    vsinkCell=find_system(modelName,'MatchFilter',@Simulink.match.allVariants,'BlockType','VariantSink');
    vSLFuncCell=find_system(modelName,'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','TriggerPort','Variant','on');
    vIRTsCell=find_system(modelName,'MatchFilter',@Simulink.match.allVariants,...
    'BlockType','EventListener','Variant','on');
    variantBlocks=[vsrcCell;vsinkCell;vSLFuncCell;vIRTsCell];
end
