function slFcnBlock=getSimulinkFunctionBlock(model,fcnName)





    slFcnBlock='';


    slFcnBlocks=find_system(model,...
    'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'blocktype','SubSystem','IsSimulinkFunction','on');

    for slIdx=1:length(slFcnBlocks)
        if codermapping.internal.simulinkfunction.suppressConfigureFunctionInterface(...
            get_param(slFcnBlocks{slIdx},'Handle'))

            continue;
        end
        if strcmp(coder.mapping.internal.SimulinkFunctionMapping.getSlFunctionName(...
            slFcnBlocks{slIdx}),fcnName)
            slFcnBlock=slFcnBlocks{slIdx};
            return;
        end
    end
end
