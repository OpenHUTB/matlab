function success=validateUpdateProject(h,continueOnWarn)





    success=1;

    userParam=h.mWorkflowInfo.userParam;
    tdkParam=h.mWorkflowInfo.tdkParam;

    printPath=strrep(userParam.assocProjPath,'\','\\');
    printPath=strrep(printPath,'%','%%');


    if~exist(userParam.assocProjPath,'file')
        error(message('EDALink:validateUpdateProject:projectnotfound',printPath));
    end




    projParts=h.getProjectParts(userParam.assocProjPath);
    assocInfo=h.readAssocInfo(projParts.loc,projParts.name);



    warnMsg=[];
    currentMdl=get_param(tdkParam.model,'FileName');

    if isempty(assocInfo.model)
        warnMsg.id='associnfonotfound';
        warnMsg.msg='Unable to verify project association with current model.';
    elseif~strcmpi(assocInfo.model,currentMdl)
        warnMsg.id='assocothermodel';
        warnMsg.msg=['Project "',printPath,'" is associated with another model.'];
    end

    if~isempty(warnMsg)
        disp(' ');
        warning(message('EDALink:validateUpdateProject:ProjectNotUpdatedProperly',warnMsg.msg));


        if~continueOnWarn
            msg=[char(10),'Continue project update? [y]/n '];
            if strcmpi(input(msg,'s'),'n')
                success=0;
                disp(' ');
                dispFpgaMsg('ISE project not updated.');
                return;
            end
        end
    end

    if h.isIseRunning
        disp(' ');
        warning(message('EDALink:validateUpdateProject:iserunning',projParts.file));


        if~continueOnWarn
            msg=[char(10),'Make sure "',projParts.file,'" is closed. Continue? [y]/n '];
            if strcmpi(input(msg,'s'),'n')
                success=0;
                disp(' ');
                dispFpgaMsg('ISE project not updated.');
                return;
            end
        end
    end
