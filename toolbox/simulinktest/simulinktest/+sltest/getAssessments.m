



function assessments=getAssessments(mdlName)
    if nargin>0
        mdlName=convertStringsToChars(mdlName);
    end

    try
        [hasLicense,~]=builtin('license','checkout','Simulink_Test');
        if~hasLicense
            error(message('Stateflow:reactive:LicenseNotAvailable'));
        end

        if~isvarname(mdlName)
            error(message('Stateflow:reactive:GetAssessmentInvalidArgument'));
        end

        Simulink.sdi.internal.flushStreamingBackend();
        eng=Simulink.sdi.Instance.engine();
        mdlHandle=get_param(mdlName,'Handle');
        runID=eng.getCurrentStreamingRunIDByHandle(mdlHandle);
        if runID<1
            error(message('Stateflow:reactive:GetAssessmentNoAssessments',mdlName));
        end

        if~stm.internal.hasVerifySignal(runID)
            error(message('Stateflow:reactive:GetAssessmentNoAssessments',mdlName));
        end

        dataset=Simulink.sdi.DatasetRef(runID,'slt_verify').fullExport();
        dataset.Name='';

        untested=[];
        pass=[];
        fail=[];

        for index=1:dataset.numElements
            assessment=dataset{index};

            switch assessment.Result
            case slTestResult.Untested
                untested(end+1)=index;
            case slTestResult.Pass
                pass(end+1)=index;
            case slTestResult.Fail
                fail(end+1)=index;
            otherwise
                assert(false,'unknown result %s',assessment.Result);
            end
        end

        assessments=sltest.AssessmentSet.create_(dataset,untested,pass,fail);
    catch ME
        ME.throwAsCaller();
    end
end
