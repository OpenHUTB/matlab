function callerBlock=getFunctionCallerBlock(model,fcnName)





    callerBlock='';
    fcnCallerBlocks=find_system(model,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'blocktype','FunctionCaller');
    for callIdx=1:length(fcnCallerBlocks)

        [isPublic,~,~,~]=...
        coder.mapping.internal.isPublicSimulinkFunction(fcnCallerBlocks{callIdx});

        if~isPublic&&codermapping.internal.simulinkfunction.suppressConfigureFunctionInterface(...
            get_param(fcnCallerBlocks{callIdx},'Handle'))

            continue;
        end

        if strcmp(coder.mapping.internal.SimulinkFunctionMapping.getSlFunctionName(...
            fcnCallerBlocks{callIdx}),fcnName)
            callerBlock=fcnCallerBlocks{callIdx};
            return;
        end
    end
end
