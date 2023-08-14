function updateParentGUI(parentDlg)



    try
        if isa(parentDlg,'ModelAdvisor.Task')

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
        elseif isa(parentDlg,'DAStudio.Dialog')
            parentDlg.refresh;
        end

    catch ME %#ok<NASGU>



    end
