function variantInfoBlksStruct=getVariantInfoBlocksWithAACOff(modelName)








    isGPCOnlyBlk=false;

    blockOption={'LabelModeActiveChoice','','BlockType','ModelReference'};
    refModelBlocks=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk);


    blockOption={'LabelModeActiveChoice','','BlockType','SubSystem','Variant','on'};
    variantSSBlocks=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk);


    blockOption={'LabelModeActiveChoice','','BlockType','VariantSource'};
    variantSources=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk);


    blockOption={'LabelModeActiveChoice','','BlockType','VariantSink'};
    variantSinks=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk);

    isGPCOnlyBlk=true;
    blockOption={'BlockType','TriggerPort','Variant','on'};
    variantTriggerPorts=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk);

    blockOption={'BlockType','EventListener','Variant','on'};
    variantEventListeners=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk);

    variantInfoBlksStruct.variantSSBlocks=variantSSBlocks';
    variantInfoBlksStruct.variantSources=variantSources';
    variantInfoBlksStruct.variantSinks=variantSinks';
    variantInfoBlksStruct.refModelBlocks=refModelBlocks';
    variantInfoBlksStruct.variantTriggerPorts=variantTriggerPorts';
    variantInfoBlksStruct.variantEventListeners=variantEventListeners';
    variantInfoBlksStruct.modelName=modelName;
end

function variantBlocks=getVariantBlocksWithAACOff(modelName,blockOption,isGPCOnlyBlk)
    findOptions={...
    'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','off',...
    };

    findOptions=horzcat(findOptions,blockOption);
    if~isGPCOnlyBlk
        AACOffOption={...
        'VariantActivationTime','update diagram'};
        findOptions=horzcat(findOptions,AACOffOption);
    else
        GPCOffOption={'GeneratePreprocessorConditionals','off'};
        findOptions=horzcat(findOptions,GPCOffOption);
    end
    variantBlocks=find_system(modelName,findOptions{:});
end
