



function[sldvData,fileNames,goalIdToObjectiveIdMap]=generateData(obj,settings,fileNames)
    objectiveToGoalMap=[];
    tcIdxToSimoutMap=[];
    testComp=obj.mTestComp;
    analyzedModelH=testComp.analysisInfo.analyzedModelH;

    if testComp.recordDvirSim
        sldvData=Sldv.DataUtils.genDvirSimOutData(analyzedModelH,testComp);
        goalIdToObjectiveIdMap=containers.Map;
    else
        [sldvData,objectiveToGoalMap,goalIdToObjectiveIdMap,tcIdxToSimoutMap,obj.mGoalToLinkinfoMap]=...
        Sldv.DataUtils.save_data(analyzedModelH,testComp,obj.mGoalToLinkinfoMap);
    end







    subsystemBlockH=[];
    if~isempty(testComp.analysisInfo.analyzedSubsystemH)
        subsystemBlockH=testComp.analysisInfo.analyzedSubsystemH;
    end


    designModelH=testComp.analysisInfo.designModelH;
    [sldvData.ModelInformation.Checksum,errorMsg]=sldvprivate('sldvGetBDReportChecksum',designModelH,subsystemBlockH);
    if~isempty(errorMsg)
        sldvData.ModelInformation.Checksum=getString(message('Sldv:RptGen:ReportChecksumComputationFailure'));
    end

    if~sldvprivate('util_check_timer')&&sldvprivate('util_check_timer',sldvData)
        if strcmp(sldvData.AnalysisInformation.Status,'Exceeded time limit')


            sldvshareprivate('avtcgirunsupcollect','push',analyzedModelH,'sldv_warning',...
            getString(message('Sldv:util_check_timer:ApplyTimerOptim')),...
            'Sldv:util_check_timer:ApplyTimerOptim');



            sldvData.AnalysisInformation.TimerOptimizations=[];
        else


            sldvData.AnalysisInformation.TimerOptimizations=[];
        end
    end



    if sldvprivate('util_suggest_testgenAdvisor',testComp)
        suggestion=getString(message('Sldv:ComponentAdvisor:TryTestgenAdvisor'));
        sldvshareprivate('avtcgirunsupcollect','push',analyzedModelH,...
        'sldv_warning',suggestion,'Sldv:ComponentAdvisor:TryTestgenAdvisor');
    end

    if isequal(settings.RandomizeNoEffectData,'on')
        if slavteng('feature','ReportApproximation')





            if Sldv.DataUtils.modelHasFixedPntInput(sldvData,analyzedModelH)&&exist('fi','file')~=2
                warnmsg=getString(message('Sldv:shared:DataUtils:RandomizationNotDone'));
                obj.logAll(sprintf('%s\n',warnmsg,obj.activity()));
            end
        else

            [sldvData,warnmsg]=Sldv.DataUtils.randomize(sldvData,5,analyzedModelH);
            if~isempty(warnmsg)
                obj.logAll(sprintf('%s\n',warnmsg,obj.activity()));
            end
        end
    end



    if slavteng('feature','ReportApproximation')&&~slavteng('feature','ReportApproximationIncr')
        if~isempty(objectiveToGoalMap)
            try
                validator=sldvprivate('getValidator',sldvData,...
                testComp.analysisInfo.extractedModelH,...
                objectiveToGoalMap,testComp);
                if~isempty(validator)
                    sldvData=validator.validate();
                end
            catch Mex




                warning('Sldv:Validator:error',...
                ['Error while doing testcase/counterexample validation: ',Mex.message]);
            end
        end
    end

    if isequal(settings.SaveExpectedOutput,'on')
        try
            if slavteng('feature','ReportApproximation')&&strcmp(settings.Mode,'TestGeneration')
                sldvData=Sldv.DataUtils.recordExpectedOutput(sldvData,...
                testComp.analysisInfo.extractedModelH,...
                testComp,tcIdxToSimoutMap);
            else
                sldvData=Sldv.DataUtils.recordExpectedOutput(sldvData,...
                testComp.analysisInfo.extractedModelH,...
                testComp);
            end
        catch Mex
            warnmsg=[Mex.message,'.'];
            for i=1:length(Mex.cause)
                warnmsg=[warnmsg,'\n',Mex.cause{i}.message];%#ok<AGROW>
            end
            obj.logAll(sprintf('%s\n',warnmsg,obj.activity()));
        end
    end

end
