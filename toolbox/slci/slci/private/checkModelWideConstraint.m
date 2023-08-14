function ftObjs=checkModelWideConstraint(constraintEnum,system)


    ftObjs={};
    modelObj=getSLCIModelObj();
    constraint=modelObj.getConstraint(constraintEnum);
    [failures,preReqConstraintFailure]=constraint{1}.checkCompatibility;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    failures=applyMAExclusions(mdladvObj,failures,preReqConstraintFailure);
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.UserData.Sid=constraint{1}.getSID;
    ft.UserData.ID=constraint{1}.getID;
    ft.setSubBar(false);
    ftObjs{end+1}=ft;
    if isempty(failures)
        [subTitle,Information,passText,~]=constraint{1}.getMAStrings(true);
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(passText);
        mdladvObj.setCheckResultStatus(true);
    else
        [subTitle,Information,warnText,RecAction]=constraint{1}.getMAStrings(false,failures);
        if preReqConstraintFailure
            warnText=DAStudio.message('Slci:compatibility:PrereqConstraintsWarn');
            RecAction='';
            objects=[];
            for i=1:numel(failures)
                ftPreReq=ModelAdvisor.FormatTemplate('ListTemplate');
                ftPreReq.UserData.Sid=constraint{1}.getSID;
                ftPreReq.UserData.ID=constraint{1}.getID;
                ftPreReq.setSubBar(false);
                [~,~,tempWarnText,tempRecAction]=failures(i).getMAStrings();
                objects=failures(i).getObjectsInvolved();
                ftPreReq.setSubResultStatusText(tempWarnText);
                ftPreReq.setRecAction(tempRecAction);
                ftPreReq.setListObj(objects);
                ft.setSubResultStatusText(warnText);
                ftObjs{end+1}=ftPreReq;
            end
        else
            objects=failures.getObjectsInvolved();
            ft.setSubResultStatusText(warnText);
            ft.setRecAction(RecAction);
            ft.setListObj(objects);

            ft.UserData.Constraint=constraint{1};
        end
        ft.setSubResultStatus('Warn');
        mdladvObj.setCheckResultStatus(false);
    end
    ft.setSubTitle(subTitle);
    ft.setInformation(Information);
    ftObjs{1}=ft;
end

function failures=applyMAExclusions(mdladvObj,failures,preReqConstraintFailure)
    if isempty(failures)
        return;
    end
    objs=failures.getObjectsInvolved;
    if isempty(objs)
        return;
    end
    if~preReqConstraintFailure
        objs=mdladvObj.filterResultWithExclusion(objs);
        if~isempty(objs)
            failures.setObjectsInvolved(objs);
        else
            failures=[];
        end
    end
end

