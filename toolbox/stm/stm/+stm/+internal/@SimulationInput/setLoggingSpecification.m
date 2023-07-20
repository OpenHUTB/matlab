function setLoggingSpecification(this,loggedSignals)




    if isa(this.RunTestCfg.SimulationInput,'sltest.harness.SimulationInput')
        modelToRun=this.RunTestCfg.SimulationInput.HarnessName;
    else
        modelToRun=this.RunTestCfg.SimulationInput.ModelName;
    end

    loggingSpec=this.RunTestCfg.SimulationInput.LoggingSpecification;
    if isempty(loggingSpec)
        loggingSpec=Simulink.Simulation.LoggingSpecification;
    end

    sigInfo={};
    for i=1:numel(loggedSignals)
        if~isempty(loggedSignals(i).HierarchicalPath)
            blockPath=getBlockPathFromHierarchicalPath(loggedSignals(i).HierarchicalPath);
        else
            blockPath=Simulink.BlockPath(loggedSignals(i).BlockPath);
        end
        outputPortIndex=loggedSignals(i).PortIndex;

        topPath=blockPath.getBlock(1);
        locBlockPath=loggedSignals(i).BlockPath;

        if loggedSignals(i).id==-1&&getSimulinkBlockHandle(topPath)==-1


        elseif strcmp(bdroot(topPath),modelToRun)



            sigInfo{i}=Simulink.SimulationData.SignalLoggingInfo(locBlockPath,outputPortIndex);
        else
            ls=sltest.testmanager.LoggedSignal(loggedSignals(i).id);
            errMsg=stm.internal.MRT.share.getString('stm:OutputView:SignalNotFoundInModel',...
            loggedSignals(i).Name,ls.LoggedSignalSet.Name,loggedSignals(i).BlockPath,modelToRun);
            this.RunTestCfg.addMessages({errMsg},{true});
        end
    end




    allModels=find_mdlrefs(modelToRun,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'KeepModelsLoaded',true);
    sigInfo=[sigInfo{:}];
    if this.SimIn.SignalLogging
        sigInfo=[sigInfo,getUniqueSignalInfoList(this.SimWatcher.cleanupTestCase,string(allModels))];
    end

    if~isempty(sigInfo)
        loggingSpec.addSignalsToLog(sigInfo);
    end

    this.RunTestCfg.SimulationInput.LoggingSpecification=loggingSpec;
end

function sigInfo=getUniqueSignalInfoList(cleanupTestCase,modelsToRun)





    sigInfo=[];
    instSignals=get_param(modelsToRun,'InstrumentedSignals');
    if numel(instSignals)<=1
        instSignals={instSignals};
    end

    instSignals=instSignals(~cellfun(@isempty,instSignals));
    instSignals=[instSignals{:}];
    if~isempty(instSignals)
        instSignals.applyRebindingRules;
    end

    sigSpec=arrayfun(@convertToSigSpec,instSignals,'Uniform',false);
    sigSpec=[sigSpec{:}];
    if isempty(sigSpec)
        return;
    end
    mask=[sigSpec.OutputPortIndex]>0;
    sigInfo=arrayfun(@getSignalLoggingInfo,sigSpec(mask));
    sfInfo=getStateflowData(sigSpec(~mask));
    sigInfo=[sigInfo,sfInfo];

    if isfield(cleanupTestCase,'FastRestartLoggedSignals')
        sigInfo=stm.internal.SimulationInput.getFastRestartLoggedSignals(...
        sigInfo,cleanupTestCase.FastRestartLoggedSignals);
    end
end

function blockPath=getBlockPathFromHierarchicalPath(hierarchicalPath)
    blockPath=Simulink.BlockPath(split(hierarchicalPath,'|'));
end

function sigSpecs=convertToSigSpec(instSignal)
    sigSpecs=arrayfun(@(x)instSignal.get(x),1:instSignal.Count);
    if~isempty(sigSpecs)
        blockPath=string(arrayfun(@(x)sigSpecs(x).getAlignedBlockPath(),1:length(sigSpecs),'UniformOutput',false));
        sigSpecs=sigSpecs(blockPath.strlength>0);
        validBlockPaths=arrayfun(@(x)validateBlockPath(x.BlockPath),sigSpecs);
        sigSpecs=sigSpecs(validBlockPaths);
    end
end

function info=getSignalLoggingInfo(sdiSigInfo)
    info=Simulink.SimulationData.SignalLoggingInfo(...
    sdiSigInfo.getAlignedBlockPath(),sdiSigInfo.OutputPortIndex);
end

function sfInfo=getStateflowData(sigSpec)

    import Simulink.SimulationData.ModelLoggingInfo.getDefaultChartSignals;
    sfInfo=[];
    blockPath=string(arrayfun(@convertToCell,[sigSpec.BlockPath]));
    sfInfo=arrayfun(@(str)getDefaultChartSignals([],str,false,sfInfo,[]),...
    unique(blockPath),'Uniform',false);
    sfInfo=[sfInfo{:}];
end

function isValidBlockPath=validateBlockPath(blockPath)
    isValidBlockPath=true;
    try
        validate(blockPath);
    catch me
        isValidBlockPath=false;
        if~(isequal(me.identifier,...
            'SimulationData:Objects:InvalidBlockPathInvalidBlock')||...
            isequal(me.identifier,...
            'SimulationData:Objects:BPathInvalidStateflowSubPath'))
            rethrow(me);
        end
    end
end
