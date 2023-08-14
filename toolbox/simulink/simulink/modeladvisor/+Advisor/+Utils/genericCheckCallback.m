function genericCheckCallback(system,checkObj,xlatePrefix,hCheckAlgo)














    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    FailingObjs=hCheckAlgo(system);

    if isempty(FailingObjs)
        mdladvObj.setCheckResultStatus(true);
        checkObj.setResultDetails(Advisor.Utils.createResultDetailObjs('',...
        'IsViolation',false,...
        'Description',DAStudio.message([xlatePrefix,'_tip']),...
        'Status',DAStudio.message([xlatePrefix,'_pass'])));
        mdladvObj.setActionEnable(false);
    else
        violationFlag=false;
        mdladvObj.setActionEnable(true);

        if isa(FailingObjs,'ModelAdvisor.ResultDetail')
            arrayViolationType=ModelAdvisor.CheckStatus.empty;
            for i=1:length(FailingObjs)
                if isempty(FailingObjs(i).Description)
                    FailingObjs(i).Description=DAStudio.message([xlatePrefix,'_tip']);
                elseif strcmp(FailingObjs(i).Description,'IGNORE')
                    FailingObjs(i).Description='';
                end
                if isempty(FailingObjs(i).Status)
                    FailingObjs(i).Status=DAStudio.message([xlatePrefix,'_warn']);
                end
                if isempty(FailingObjs(i).RecAction)
                    FailingObjs(i).RecAction=DAStudio.message([xlatePrefix,'_rec_action']);
                elseif strcmp(FailingObjs(i).RecAction,'IGNORE')
                    FailingObjs(i).RecAction='';
                end

                arrayViolationType(end+1)=FailingObjs(i).getViolationStatus();
                violationFlag=violationFlag||FailingObjs(i).IsViolation;

            end

            check_state=ModelAdvisor.CheckStatusUtil.getParentStatus(arrayViolationType);
            mdladvObj.setCheckResultStatus(char(check_state));

            checkObj.setResultDetails(FailingObjs);
        else

            mdladvObj.setCheckResultStatus(false);
            checkObj.setResultDetails(Advisor.Utils.createResultDetailObjs(FailingObjs,...
            'Description',DAStudio.message([xlatePrefix,'_tip']),...
            'Status',DAStudio.message([xlatePrefix,'_warn']),...
            'RecAction',DAStudio.message([xlatePrefix,'_rec_action'])));
        end
    end
end
