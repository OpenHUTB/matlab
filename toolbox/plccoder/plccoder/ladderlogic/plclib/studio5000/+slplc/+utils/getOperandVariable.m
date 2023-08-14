function varInfo=getOperandVariable(scopedPOUBlock)




    pouType=slplc.utils.getParam(scopedPOUBlock,'PLCPOUType');
    if strcmpi(pouType,'function block')
        varInfo=slplc.utils.createVarInfo('EnableIn','BOOL','true',false,'read');
        varInfo(2)=slplc.utils.createVarInfo('EnableOut','BOOL','false',false,'write');
    else
        varInfo=[];
    end

    routineBlocks=slplc.utils.getRoutineBlocks(scopedPOUBlock);
    for routineCount=1:numel(routineBlocks)
        routineBlk=routineBlocks{routineCount};
        varInfo=slplc.utils.getRoutineOperandVariable(routineBlk,varInfo);
    end

end


