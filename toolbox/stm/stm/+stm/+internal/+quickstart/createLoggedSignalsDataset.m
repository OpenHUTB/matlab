function nSigs=createLoggedSignalsDataset(model,harnessName,filePath,sheet)











    [modelToUse,deactivateHarness,currHarness,oldHarness,~,wasHarnessOpen]=stm.internal.util.resolveHarness(model,harnessName);

    if nargin>0
        modelToUse=convertStringsToChars(modelToUse);
    end


    simOvr=struct('StartTime','0',...
    'StopTime','0',...
    'SaveFormat','Dataset',...
    'SimulationMode','normal',...
    'FastRestart','off',...
    'SignalLogging','on',...
    'SignalLoggingName','sigOut',...
    'CovEnable','off'...
    );

    modelH=get_param(modelToUse,'handle');


    preserve_dirty=Simulink.PreserveDirtyFlag(modelH,'blockDiagram');

    origAutoSaveOptions=get_param(0,'AutoSaveOptions');
    oc1=onCleanup(@()set_param(0,'AutoSaveOptions',origAutoSaveOptions));


    s.SaveOnModelUpdate=0;
    set_param(0,'AutoSaveOptions',s);

    if~Simulink.iospecification.InportProperty.checkModelName(modelToUse)
        errMsg=MException('sl_sta:editor:modelNotOpen',...
        DAStudio.message('sl_sta:editor:modelNotOpen',modelToUse));
        throw(errMsg);

    end



    UNITS_WARN_STATE_PREV=warning('OFF','Simulink:Unit:UndefinedUnitUsage');
    warnMaxStepSize=warning('off','Simulink:Engine:UsingDefaultMaxStepSize');
    warnFixedStepSize=warning('off','Simulink:SampleTime:FixedStepSizeHeuristicWarn');
    warnTermDefer=warning('off','Simulink:Engine:SFcnAPITerminationDeferred');
    warnCompiled=warning('off','Simulink:Engine:ModelAlreadyCompiled');
    ocw1=onCleanup(@()warning(UNITS_WARN_STATE_PREV.state,'Simulink:Unit:UndefinedUnitUsage'));
    ocw2=onCleanup(@()warning(warnMaxStepSize.state,'Simulink:Engine:UsingDefaultMaxStepSize'));
    ocw3=onCleanup(@()warning(warnFixedStepSize.state,'Simulink:SampleTime:FixedStepSizeHeuristicWarn'));
    ocw4=onCleanup(@()warning(warnTermDefer.state,'Simulink:Engine:SFcnAPITerminationDeferred'));
    ocw5=onCleanup(@()warning(warnCompiled.state,'Simulink:Engine:ModelAlreadyCompiled'));

    simOvr=setupModel(modelH,simOvr);


    resetSUT={@setupModel,modelH,simOvr};
    unloadSUT={@cleanupHarness,currHarness,oldHarness,deactivateHarness,wasHarnessOpen};


    onClnp=onCleanup(@()cellfun(@(c)feval(c{:}),{resetSUT,unloadSUT},...
    'UniformOutput',false));


    simOut=sim(modelToUse,'OutputSaveName','out');

    clear preserve_dirty;

    if~isempty(simOut.ErrorMessage)
        throw(simOut.ErrorMessage);
    end


    ds=Simulink.SimulationData.Dataset;

    if simOut.isprop('sigOut')&&~isempty(simOut.get('sigOut'))
        ds=ds.concat(simOut.get('sigOut'));
    end
    if simOut.isprop('out')&&~isempty(simOut.get('out'))
        ds=ds.concat(simOut.get('out'));
    end


    if isempty(ds)
        nSigs=0;
    else
        nSigs=ds.numElements;
        if(nargin>=3)
            [~,~,ext]=fileparts(filePath);
            if strcmpi(ext,'.mat')
                save(filePath,'ds');
            else

                xls.internal.util.writeDatasetToSheet(ds,filePath,sheet,'',xls.internal.SourceTypes.Output);
            end
        end
    end

end

function simOvrNew=setupModel(modelH,simOvr)
    simOvrNew=[];
    propNames=fieldnames(simOvr);
    for idx=1:length(propNames)

        currVal=get_param(modelH,propNames{idx});


        set_param(modelH,propNames{idx},simOvr.(propNames{idx}));


        simOvrNew.(propNames{idx})=currVal;
    end
end

function cleanupHarness(currHarness,oldHarness,deactivateHarness,wasHarnessOpen)

    if~isempty(currHarness)
        close_system(currHarness.name,0);

        if(deactivateHarness)
            stm.internal.util.loadHarness(oldHarness.ownerFullPath,oldHarness.name,wasHarnessOpen);
        end
    end
end
