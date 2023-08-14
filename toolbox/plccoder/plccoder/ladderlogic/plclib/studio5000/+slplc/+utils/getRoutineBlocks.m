function routineBlocks=getRoutineBlocks(organizationBlock,varargin)




    if~isempty(varargin)
        optionStr=varargin{1};
    else
        optionStr='withValidation';
    end

    if strcmpi(optionStr,'withoutValidation')
        routineBlocks{1}=slplc.utils.getInternalBlockPath(organizationBlock,'Logic');
        if strcmpi(slplc.utils.getParam(organizationBlock,'PLCPOUType'),'function block')
            routineBlocks{end+1}=slplc.utils.getInternalBlockPath(organizationBlock,'EnableInFalse');
            routineBlocks{end+1}=slplc.utils.getInternalBlockPath(organizationBlock,'Prescan');
        end
    else
        routineBlocks={};
        routineBlocks=addToRoutineBlocks(routineBlocks,slplc.utils.getInternalBlockPath(organizationBlock,'Logic'));
        routineBlocks=addToRoutineBlocks(routineBlocks,slplc.utils.getInternalBlockPath(organizationBlock,'EnableInFalse'));
        routineBlocks=addToRoutineBlocks(routineBlocks,slplc.utils.getInternalBlockPath(organizationBlock,'Prescan'));
    end

end

function routineBlocks=addToRoutineBlocks(routineBlocks,routineBlk)
    if getSimulinkBlockHandle(routineBlk)<=0
        return
    end

    if strcmpi(get_param(routineBlk,'Commented'),'off')
        blocksWithOperand=plc_find_system(routineBlk,...
        'SearchDepth',1,...
        'LookUnderMasks','all',...
        'FollowLinks','on',...
        'regexp','on',...
        'PLCPOUType','^\w');

        if~isempty(blocksWithOperand)
            routineBlocks{end+1}=routineBlk;
        end
    end

end
