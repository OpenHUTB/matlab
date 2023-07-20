function success=checkOpenedProject(h,continueOnWarn)






    success=1;

    userParam=h.mWorkflowInfo.userParam;

    if h.isIseRunning
        projParts=h.getProjectParts(userParam.existingPath);

        disp(' ');
        warning(message('EDALink:WorkflowManager:checkOpenedProject:iserunning',projParts.file));


        if~continueOnWarn
            msg=[char(10),'Make sure "',projParts.file,'" is closed. Continue? [y]/n '];
            if strcmpi(input(msg,'s'),'n')
                success=0;
                disp(' ');
                dispFpgaMsg('ISE project not modified.');
                disp(' ');
                return;
            end
        end
    end
