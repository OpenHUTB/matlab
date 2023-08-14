function[numBlocksDeleted,sopts]=flattenHierarchy(mdlName,FullPath,sopts,conditionFunction,numBlocksDeleted)

    allBlocks=Simulink.SimplifyModel.getBlocksList(FullPath,sopts.excludeBlocks);

    for i=1:length(allBlocks)
        blockName=allBlocks{i};
        reductionOK=true;


        if strcmpi(get_param(blockName,'LinkStatus'),'resolved')||strcmpi(get_param(blockName,'LinkStatus'),'disabled')
            if~sopts.BreakLibraryLinks
                continue;
            end

            try
                set_param(blockName,'LinkStatus','none');
            catch ME
                disp(ME.message);
                continue;
            end
            [reductionOK,~,sopts]=Simulink.SimplifyModel.checkCondition(mdlName,conditionFunction,sopts,{blockName},numBlocksDeleted,'Removed Library Link for ');
        end

        if reductionOK
            [simplifiable,subsystemOrMdl]=Simulink.SimplifyModel.canBeSimplified(blockName,sopts);
            if~simplifiable
                continue;
            end


            [numBlocksDeleted,sopts]=Simulink.SimplifyModel.flattenHierarchy(mdlName,subsystemOrMdl,sopts,conditionFunction,numBlocksDeleted);



            Simulink.SimplifyModel.undoCreateSubsystem(blockName);
            [~,numBlocksDeleted,sopts]=Simulink.SimplifyModel.checkCondition(mdlName,conditionFunction,sopts,{blockName},numBlocksDeleted,'Bring contents to Top level for ');
        end
    end
