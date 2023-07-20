function initBoard(obj,boardName)







    hOption=obj.getOption('Board');
    hOption.Value=boardName;


    currentWorkflow=obj.get('Workflow');
    if strcmp(boardName,obj.EmptyBoardStr)

    elseif strcmpi(boardName,obj.GetMoreStr)

    elseif strcmp(boardName,obj.AddNewBoardStr)||strcmp(boardName,obj.GetMoreBoardStr)

        hOption.Value=oldBoardName;
    elseif obj.isTurnkeyWorkflow
        loadTurnkeyBoard(obj,boardName);
    elseif obj.isSLRTWorkflow
        loadSLRTBoard(obj,boardName);
    elseif obj.isFILWorkflow
        loadFILBoard(obj,boardName);
    elseif obj.isUSRPWorkflow
        loadUSRPBoard(obj,boardName);
    elseif obj.isIPWorkflow
        loadIPPlatform(obj,boardName);

    elseif obj.isSDRWorkflow


        isInToolList=obj.isToolInBoardRequiredToolList(obj.get('Tool'),boardName);
        availToolList=obj.getAvailableToolForBoard(boardName);
        sdr.internal.hdlwa.driverSetBoardName(obj,boardName,isInToolList,availToolList);

    elseif obj.hWorkflowList.isInWorkflowList(currentWorkflow)

        hWorkflow=obj.hWorkflowList.getWorkflow(currentWorkflow);
        hWorkflow.loadBoard(obj,boardName);

    elseif obj.isPluginWorkflow
        obj.pim.driverSetBoardName(boardName,obj);
    end

end
