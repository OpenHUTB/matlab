function updateBoardList(inHandle)

    persistent dlgHandle;
    if nargin==1

        dlgHandle=inHandle;
        return;
    else

        hmgr=eda.internal.boardmanager.BoardManager.getInstance;
        hmgr.reset;

        if exist(fullfile(matlabroot,'toolbox','hdlcoder','hdlcoder','makehdl.m'),'file')

            getHDLToolInfo('reloadPlatformList');
        end


        if isa(dlgHandle,'ModelAdvisor.Task')

            taskobj=parentDlg;
            mdladvObj=taskobj.MAObj;
            system=mdladvObj.System;
            hModel=bdroot(system);
            hDriver=get_param(hModel,'HDLCoder');
            hDI=hDriver.DownstreamIntegrationDriver;
            hDI.hAvailableBoardList.buildCustomBoardList;
            targetInputParams=mdladvObj.getInputParameters(taskobj.MAC);
            boardOption=targetInputParams{2};
            boardOption.Entries=hDI.set('Board');

            taskobj.resetgui;
        elseif isa(dlgHandle,'DAStudio.Dialog')
            dlgHandle.refresh;
        end

    end

