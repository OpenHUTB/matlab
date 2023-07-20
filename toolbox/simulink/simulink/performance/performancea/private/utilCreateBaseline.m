
function baseline=utilCreateBaseline(mdladvObj,check,model)



    baseline=utilCreateEmptyBaseline();

    sdiEngine=mdladvObj.UserData.Progress.sdiEngine;

    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;


    stateOutputSaveFormat=strcmp(get_param(model,'SaveFormat'),'StructureWithTime');
    saveState=strcmp(get_param(model,'SaveState'),'on');
    saveOutput=strcmp(get_param(model,'SaveOutput'),'on');
    ok1=stateOutputSaveFormat&&(saveState||saveOutput);


    sigLog=strcmp(get_param(model,'SignalLogging'),'on');
    ok2=sigLog;


    ok3=false;


    blockList=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ToWorkspace');
    if~isempty(blockList)
        for i=1:length(blockList)
            saveformat=get_param(blockList{i},'saveformat');
            ok3=strcmp(saveformat,'Structure With Time')||strcmp(saveformat,'Timeseries');
            if ok3,break;end
        end
    end

    if~(ok1||ok2||ok3)
        text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DataLoggingFailed');
        text=ModelAdvisor.Text(text);
        link=utilCreateConfigSetHref(model,'SignalLogging');
        text.setHyperlink(link);
        ME=MException('SimulinkPerformanceAdvisor:advisor:DataLoggingFailed',text.emitHTML);
        throw(ME);
    end




    originalOutputTimesStr=get_param(model,'OutputTimes');


    cond1=strcmp(check.getID,'com.mathworks.Simulink.PerformanceAdvisor.CreateBaseline');

    if(~cond1)
        [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,check);
    end



    if(cond1||validateTime||validateAccuracy)




        configForOutputTimes(model)



        simMode=get_param(model,'SimulationMode');
        try
            if strcmp(simMode,'accelerator')
                evalc([model,'([],[],[],''compileForAccel'')']);
            else
                evalc([model,'([],[],[],''compile'')']);
            end
        catch ME
            restoreOutputTimes(configSet,originalOutputTimesStr);
            throw(ME);
        end










        if cond1
            try
                utilCheckCollectCompInfo(model);
            catch ME
                evalc([model,'([],[],[],''term'')']);
                throw(ME);
            end
        end


        try
            evalc([model,'([],[],[],''term'')']);
        catch ME
            restoreOutputTimes(configSet,originalOutputTimesStr);
            throw(ME);
        end



        oldStopTime=get_param(model,'StopTime');


        stopTime=utilGetBaselineStopTime(mdladvObj,model);
        configSet.set_param('StopTime',num2str(stopTime));
        configSet.set_param('ReturnWorkspaceOutputs','on');




        configForOutputTimes(model)


        PerfTools.Tracer.enable('Performance Advisor Stats',true);
        PerfTools.Tracer.clearRawData;
        oc1=onCleanup(@()PerfTools.Tracer.clearRawData);
        oc2=onCleanup(@()PerfTools.Tracer.enable('Performance Advisor Stats',false));


        tstart=tic;
        try


            if mdladvObj.UserCancel
                msgId='perfAdvId:UserCancel';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UserCancelException');
                Exception=MException(msgId,msg);
                throwAsCaller(Exception);
            end


            if~mdladvObj.GlobalTimeOut


                if(cond1||~isfield(mdladvObj.UserData,'localTimeOut'))
                    evalc(['simOut = sim(model,','''LoggingToFile'',','''off''',')']);
                else
                    timeOutVal=mdladvObj.UserData.localTimeOut;%#ok<NASGU>
                    evalc(['simOut = sim(model,','''LoggingToFile'',','''off'',','''timeOut'',','timeOutVal)']);

                    if strcmpi(simOut.getSimulationMetadata.ExecutionInfo.StopEvent,'TimeOut')
                        msgId='perfAdvId:LocalTimeOut';
                        actualStopTime=simOut.getSimulationMetadata.ModelInfo.StopTime;
                        targetStopTime=utilGetBaselineStopTime(mdladvObj,model);
                        speedReduction=100*(targetStopTime/actualStopTime-1);
                        msg=[DAStudio.message('SimulinkPerformanceAdvisor:advisor:LocalTimeOutException'),...
                        ' ',sprintf('%1.2f',speedReduction),'%%. ',...
                        DAStudio.message('SimulinkPerformanceAdvisor:advisor:RevertChange')];
                        timeOutException=MException(msgId,msg);
                        throwAsCaller(timeOutException);
                    end
                end
            end

        catch ME
            restoreOutputTimes(configSet,originalOutputTimesStr);
            configSet.set_param('StopTime',oldStopTime);



            if~isempty(strfind(ME.identifier,'SimAborted'))&&mdladvObj.GlobalTimeOut
                msgId='perfAdvIId:GlobalTimeOut';
                msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
                ME=MException(msgId,msg);
            end
            throw(ME);
        end


        if mdladvObj.GlobalTimeOut
            msgId='perfAdvIId:GlobalTimeOut';
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
            Exception=MException(msgId,msg);
            throwAsCaller(Exception);
        end

        baselineTime=toc(tstart);


        if cond1
            mdladvObj.UserData.localTimeOut=ceil(1.1*baselineTime);
        end

        baseline.time.total=baselineTime;
        baseline.time.displayTime=datestr(datenum(0,0,0,0,0,baselineTime),'HH:MM:SS.FFF');
        [baseline.time.timeBreakdown]=slprivate('getSimulationTimingInfo',model);


        configSet.set_param('StopTime',oldStopTime);
    end



    if(cond1||validateAccuracy)


        hasRunID=isfield(check.ResultData,'runID');

        if(hasRunID&&~cond1)
            if((~isempty(check.ResultData.runID)&&check.ResultData.runID~=0)&&...
                sdiEngine.isValidRunID(check.ResultData.runID))
                sdiEngine.deleteRun(check.ResultData.runID);
                mdladvObj.UserData.Progress.sdiRunIDs(mdladvObj.UserData.Progress.sdiRunIDs==check.ResultData.runID)=[];
            end
        end



        configForOutputTimes(model)

        evalc('runID = Simulink.sdi.createRunOrAddToStreamedRun(model, check.getID,{''simOut''},{simOut})');

        if(isempty(runID)||(runID<1))
            encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
            encodedModelName=[encodedModelName{:}];
            restoreOutputTimes(configSet,originalOutputTimesStr);
            text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NoDataLogged',encodedModelName);
            ME=MException('SimulinkPerformanceAdvisor:advisor:NoDataLogged',text);
            throw(ME)
        end

        absTol=Simulink.SDIInterface.calculateDefaultAbsoluteTolerance(model);
        relTol=Simulink.SDIInterface.calculateDefaultRelativeTolerance(model);
        sdiEngine.safeTransaction(@helperCreateBaseLine,runID,sdiEngine,relTol,absTol,cond1);
        check.ResultData.runID=runID;
        baseline.time.runID=runID;
        mdladvObj.UserData.Progress.sdiRunIDs=[mdladvObj.UserData.Progress.sdiRunIDs,runID];
    else
        Simulink.sdi.internal.removeLastStreamedRun(model);
    end


    restoreOutputTimes(configSet,originalOutputTimesStr);

end

function helperCreateBaseLine(runID,sdiEngine,relTol,absTol,cond1)
    sdiEngine.setSyncMethodByRun(runID,'union');
    sdiEngine.setInterpMethodByRun(runID,'linear');



    if cond1
        sdiEngine.setAbsTolByRun(runID,absTol);
        sdiEngine.setRelTolByRun(runID,relTol);
    end
end

function configForOutputTimes(model)


    cfs=utilGetActiveConfigSet(model);
    configSet=cfs.configSet;

    outputOptionStr=get_param(model,'OutputOption');
    outputTimesStr=get_param(model,'OutputTimes');

    if~strcmp(outputOptionStr,'SpecifiedOutputTimes')||strcmp(outputTimesStr,'[]')
        return;
    end


    startTimeStr=get_param(model,'StartTime');
    stopTimeStr=get_param(model,'StopTime');
    startTimeVal=evalinGlobalScope(model,startTimeStr);
    stopTimeVal=evalinGlobalScope(model,stopTimeStr);


    try
        outputTimesVal=evalinGlobalScope(model,outputTimesStr);
        if~isempty(outputTimesVal)
            indices=outputTimesVal>=startTimeVal&outputTimesVal<=stopTimeVal;
            outputTimesVal=outputTimesVal(indices);
            if isempty(outputTimesVal)
                outputTimesVal=startTimeVal:stopTimeVal;
            end
        end
    catch
        outputTimesVal=startTimeVal:stopTimeVal;
    end

    configSet.set_param('OutputTimes',strcat('[',num2str(outputTimesVal),']'));
end

function restoreOutputTimes(configSet,outputTimeStr)
    SolverTypeStr=configSet.get_param('SolverType');
    if~strcmp(SolverTypeStr,'Fixed-step')
        outputOptionStr=configSet.get_param('OutputOption');
        if strcmp(outputOptionStr,'SpecifiedOutputTimes')
            outputTimesStr=configSet.get_param('OutputTimes');
            if~strcmp(outputTimesStr,'[]')
                configSet.set_param('OutputTimes',outputTimeStr);
            end
        end
    end
end


