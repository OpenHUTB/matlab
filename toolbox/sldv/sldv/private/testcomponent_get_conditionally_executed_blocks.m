function testcomponent_get_conditionally_executed_blocks(aTestComp)




    assert(Sldv.xform.MdlInfo.isMdlCompiled(aTestComp.analysisInfo.analyzedModelH));

    conditionallyExecutedBlocks=[];





    sess=slfeature('EngineInterface',Simulink.EngineInterfaceVal.byFiat);
    clean=onCleanup(@()slfeature('EngineInterface',sess));
    try
        mdlU=get_param(aTestComp.analysisInfo.analyzedModelH,'Object');
        cecTree=mdlU.getCondExecTree;
        for i=1:numel(cecTree)
            currNode=cecTree(i);
            if~strcmp(currNode.cecType,'CondInput')
                continue;
            end
            for j=1:numel(currNode.blocksMovedToCECInputSide)
                conditionallyExecutedBlocks{end+1}=Simulink.ID.getSID(currNode.blocksMovedToCECInputSide(j));
            end
        end
    catch



    end

    aTestComp.conditionallyExecutedBlocks=conditionallyExecutedBlocks;
end
