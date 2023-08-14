function[totalTime,Tu,Tuc,Ts,Tg,Tgsub,Te,Tt]=utilGetTimingInfo(model,showFigure)


    PerfTools.Tracer.enable('Performance Advisor Stats',true);
    PerfTools.Tracer.clearRawData;


    try
        try
            mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(model);
        catch
            mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        end

        tstart=tic;

        if~isfield(mdladvObj.UserData,'localTimeOut')
            evalc(['simOut = sim(model,','''LoggingToFile'',','''off''',')']);
        else
            timeOutVal=mdladvObj.UserData.localTimeOut;
            evalc(['simOut = sim(model,','''LoggingToFile'',','''off'',','''timeOut'',','timeOutVal)']);

            if strcmpi(simOut.getSimulationMetadata.ExecutionInfo.StopEvent,'Timeout')
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

        totalTime=toc(tstart);

    catch me

        PerfTools.Tracer.clearRawData;
        PerfTools.Tracer.enable('Performance Advisor Stats',false);
        if~isempty(strfind(me.identifier,'SimAborted'))&&mdladvObj.GlobalTimeOut
            msgId='perfAdvIId:GlobalTimeOut';
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
            me=MException(msgId,msg);
        end
        throw(me);
    end

    [T,mode]=slprivate('getSimulationTimingInfo',model);

    Tu=T.UpdateDiagramTime;
    Tuc=T.UpToDateCheck;

    Ts=T.SimSetUp;
    Tg=T.TopGenerateAndCompileCode;

    Tgsub=T.SubGenerateAndCompileCode;

    Te=T.Execution;
    Tt=T.Terminate;

    if showFigure
        barh([Tu,Tuc,Ts,Tg,Tgsub,Te,Tt;0,0,0,0,0,0,0],'stack');
        title('Simulation Timing Information');

        Tu_s=sprintf('Update diagram: %7.3f%s',Tu,'(s)');
        Tuc_s=sprintf('Model References Update diagram: %7.3f%s',Tuc,'(s)');
        Ts_s=sprintf('Initialization For Simulation: %7.3f%s',Ts,'(s)');
        Tg_s=sprintf('Code Generaton and build for top model: %7.3f%s',Tg,'(s)');
        Tgsub_s=sprintf('Code Generaton and build for all model references: %7.3f%s',Tgsub,'(s)');
        Te_s=sprintf('Simulation: %7.3f%s',Te,'(s)');
        Tt_s=sprintf('Termination: %7.3f%s',Tt,'(s)');

        legend(Tu_s,Tuc_s,Ts_s,Tg_s,Tgsub_s,Te_s,Tt_s);
    end


    PerfTools.Tracer.clearRawData;
    PerfTools.Tracer.enable('Performance Advisor Stats',false);

end
