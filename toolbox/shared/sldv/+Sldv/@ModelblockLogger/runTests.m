function runTests(obj)




    [sldvData,sampleTimeInformation]=obj.generateDataForLogging;
    obj.turnOffAndStoreWarningStatus;
    obj.initForSim;
    obj.checkRefModelSampleTimes(sampleTimeInformation);
    obj.checkForComplexType(Sldv.DataUtils.convertLoggedSldvDataToHarnessDataFormat(sldvData,[],false));

    paramNameValStruct=obj.getBaseSimStruct;
    paramNameValStruct.SFSimEnableDebug='off';
    paramNameValStruct.RecordCoverage='off';
    paramNameValStruct.CovModelRefEnable='off';
    paramNameValStruct.CovExternalEMLEnable='off';
    paramNameValStruct.CovSFcnEnable='off';
    if obj.intervalStartTime~=0
        simHandler=Coverage.SimulationHandler(obj.TopLevelModelH);
        simHandler.configureModelParameters(paramNameValStruct);
        simHandler.setPauseTime(obj.intervalStartTime);
        simHandler.setStopTime(obj.intervalStopTime);
        simHandler.initializeStepper;
        simHandler.run;
        obj.SimState=simHandler.getSimState;
        simHandler.run
        simOut=simHandler.getSimOut;
        delete(simHandler);
    else
        modelToSim=get_param(obj.TopLevelModelH,'Name');%#ok<NASGU>
        paramNameValStruct.StopTime=num2str(obj.intervalStopTime);
        [~,simOut]=evalc('sim(modelToSim,paramNameValStruct);');
    end
    sigLogs=simOut.find(paramNameValStruct.SignalLoggingName);
    dsmLogs=simOut.find(paramNameValStruct.DSMLoggingName);
    sldvData.TestCases.dataValues=...
    obj.deriveFunctionalTestCase(...
    sigLogs,...
    dsmLogs,...
    1);
    if checkAllSignalEmpty(sldvData)
        error('Sldv:SubsystemLogger:NoSignalLogged',...
        getString(message('Sldv:SubsystemLogger:NoLoggedSignalIs')));
    end
    obj.convertLoggedDataToCellFormat(sldvData);
end

function tf=checkAllSignalEmpty(sldvData)
    simData=Sldv.DataUtils.getSimData(sldvData);
    tf=true;
    for idx=1:length(simData)
        for jdx=1:simData(idx).dataValues.getLength
            logData=simData(idx).dataValues.getElement(jdx);
            if isa(logData,'timeseries')&&~isempty(logData.Time)
                tf=false;
            elseif isstruct(logData)
                fn=fieldnames(logData);
                if~isempty(fn)
                    ts=logData.(fn{1});
                    tf=~(isa(ts,'timeseries')&&~isempty(ts.Time));
                end
            end
        end
    end
end
