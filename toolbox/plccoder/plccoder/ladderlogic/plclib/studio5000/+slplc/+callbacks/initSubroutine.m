function initSubroutine(subroutineBlock)




    if slplc.utils.isRunningModelGeneration(subroutineBlock)
        return
    end


    slplc.utils.modelSanityChecker(subroutineBlock);


    if plcfeature('PLCLadderBlockHierarchyCheck')
        slplc.utils.blockHeirarchyCheck(subroutineBlock);
    end


    parentPOUBlk=slplc.utils.getParentPOU(subroutineBlock);
    if~isempty(parentPOUBlk)
        pouType=slplc.utils.getParam(parentPOUBlk,'PLCPOUType');
        if~isempty(pouType)&&strcmpi(pouType,'Function Block')
            error('slplc:subroutineInFunctionBlock',...
            'Function Block (AOI) POU blocks cannot contain Subroutine blocks. Please remove %s from Function Block (AOI) block %s.',...
            subroutineBlock,parentPOUBlk);
        end
    end

    slplc.utils.initRoutines(subroutineBlock);
end


