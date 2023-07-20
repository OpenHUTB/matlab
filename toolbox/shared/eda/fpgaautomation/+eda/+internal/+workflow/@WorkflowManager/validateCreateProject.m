function success=validateCreateProject(h,continueOnWarn)





    vstruct.name=true;
    vstruct.folder=true;
    vstruct.userfiles=true;
    vstruct.processprop=true;

    h.validateNewProjectParam(vstruct);

    if h.mWorkflowInfo.control.CheckProjDuringRun
        success=1;
    else
        if nargin<2
            continueOnWarn=false;
        end
        success=h.checkProjectOverwrite(continueOnWarn);
    end

