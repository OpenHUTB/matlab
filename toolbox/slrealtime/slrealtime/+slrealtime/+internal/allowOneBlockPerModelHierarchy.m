function allowOneBlockPerModelHierarchy(topModel,blockMaskTypes,blockDisplayTypes)





    if(strcmp(get_param(topModel,'BlockDiagramType'),'Library'))
        return;
    end

    assert(numel(blockMaskTypes)==numel(blockDisplayTypes));

    open_models=find_system('Type','block_diagram');
    models=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.codeCompileVariants,'KeepModelsLoaded',true,'IncludeCommented',false);
    models_to_close=setdiff(models,open_models);
    c=onCleanup(@()close_system(models_to_close,0));

    findOpts=Simulink.FindOptions(...
    'CaseSensitive',false,...
    'FollowLinks',true,...
    'IncludeCommented',false,...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.codeCompileVariants,...
    'SearchDepth',-1);

    for nType=1:numel(blockMaskTypes)
        count=0;
        for nModel=1:numel(models)
            blocks=Simulink.findBlocks(models{nModel},'MaskType',blockMaskTypes{nType},findOpts);
            count=count+numel(blocks);
            if count>1
                slrealtime.internal.throw.Error('slrealtime:utils:TooManyBlocksOfType',blockDisplayTypes{nType});
            end
        end
    end
end
