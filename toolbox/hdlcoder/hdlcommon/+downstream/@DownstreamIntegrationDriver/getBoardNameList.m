function boardNameList=getBoardNameList(obj)




    if obj.isGenericWorkflow||obj.isHLSWorkflow
        boardNameList={''};
    elseif obj.isFILWorkflow
        if~isempty(which('eda.internal.boardmanager.BoardManager'))
            hBoardMgr=eda.internal.boardmanager.BoardManager.getInstance;
            boardNameList=hBoardMgr.getFILBoardNamesByVendor('All');
        else

            boards=filBoardList;
            boardNameList=cellfun(@(x)x.Name,boards,'UniformOutput',false);
        end
        boardNameList=[{obj.EmptyBoardStr},boardNameList,{obj.GetMoreBoardStr},{obj.AddNewBoardStr}];
    elseif obj.isUSRPWorkflow

        boards=usrpBoardList;
        boardNameList=cellfun(@(x)x.Name,boards,'UniformOutput',false);
        boardNameList=[obj.EmptyBoardStr,boardNameList];

    elseif obj.isSDRWorkflow
        boardNameList=sdr.internal.hdlwa.driverGetBoardNameList(obj.EmptyBoardStr);

    elseif obj.isDLWorkflow
        boardNameList=[{obj.EmptyBoardStr},obj.hIP.getIPPlatformNameList,{obj.GetMoreStr}];
    elseif obj.isIPWorkflow&&~obj.isDLWorkflow
        boardNameList=[{obj.EmptyBoardStr},obj.hIP.getIPPlatformNameList,{obj.GetMoreStr}];
    elseif obj.isTurnkeyWorkflow
        availableList=obj.hAvailableBoardList.getBoardNameList(obj.isMLHDLC);
        boardNameList=[{obj.EmptyBoardStr},availableList,{obj.GetMoreBoardStr},{obj.AddNewBoardStr}];
    elseif obj.isSLRTWorkflow
        availableList=obj.hAvailableBoardList.getBoardNameList;
        boardNameList=[obj.EmptyBoardStr,availableList,{obj.GetMoreStr}];
    else
        currentWorkflow=obj.get('Workflow');
        if obj.hWorkflowList.isInWorkflowList(currentWorkflow)

            hWorkflow=obj.hWorkflowList.getWorkflow(currentWorkflow);
            boardNameList=hWorkflow.getBoardNameList(obj);

        elseif obj.isPluginWorkflow






            boardNameList=[{obj.EmptyBoardStr},obj.pim.driverGetBoardNameList()];
        else

            availableList=obj.hAvailableBoardList.getBoardNameList;
            boardNameList=[obj.EmptyBoardStr,availableList];
        end
    end

end


