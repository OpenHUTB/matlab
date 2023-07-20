function success=validateAddExistingProject(h,continueOnWarn)




    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;


    if isempty(userParam.existingPath)||~ischar(userParam.existingPath)
        error(message('EDALink:WorkflowManager:validateAddExistingProject:existingprojectpath'));
    end


    if~exist(userParam.existingPath,'file')
        error(message('EDALink:WorkflowManager:validateAddExistingProject:projectnotfound',userParam.existingPath));
    end



    projParts=h.getProjectParts(userParam.existingPath);
    validExt=tdkParam.projectExt;
    if~strcmpi(projParts.ext,validExt)
        error(message('EDALink:WorkflowManager:validateAddExistingProject:invalidprojectpath',userParam.existingPath));
    end

    if h.mWorkflowInfo.control.CheckProjDuringRun
        success=1;
    else
        if nargin<2
            continueOnWarn=false;
        end
        success=h.checkOpenedProject(continueOnWarn);
    end

