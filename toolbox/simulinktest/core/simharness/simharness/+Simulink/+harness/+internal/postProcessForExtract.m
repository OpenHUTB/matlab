function strPorts=postProcessForExtract(modelH,subsysH,harnessH,tsInfo)





    featureOn=slsvTestingHook('UnifiedHarnessBackendMode')>0;
    assert(featureOn,'UnifiedHarnessBackendMode feature should be on when calling postProcessForExtract');

    harnessName=get_param(harnessH,'Name');
    Simulink.harness.internal.clearContTsSetting(modelH,...
    harnessName,subsysH);

    if strcmp(get_param(harnessH,'SignalResolutionControl'),...
        'TryResolveAllWithWarning')
        set_param(harnessH,'SignalResolutionControl','TryResolveAll');
    end

    if~strcmp(get_param(harnessH,'FrameProcessingCompatibilityMsg'),'none')
        set_param(harnessH,'FrameProcessingCompatibilityMsg','none')
    end

    TLCOptions=get_param(harnessH,'TLCOptions');

    machineID=sf('find','all','machine.name',harnessName);
    if~isempty(machineID)&&machineID>0
        TLCOptions=strcat(TLCOptions,' -aAlwaysIncludeCustomSrc=1');
    end

    set_param(harnessH,'TLCOptions',TLCOptions);

    bIsVariableStepSolver=strcmp(get_param(modelH,'SolverType'),'Variable-step');











    if~bIsVariableStepSolver
        sampleTimeConstraint=get_param(modelH,'SampleTimeConstraint');
        trigTs=[-1,-1];
        sysBlkTs=get_param(subsysH,'CompiledSampleTime');
        sysBlkTsIsTriggered=false;
        if(size(sysBlkTs)==size(trigTs))
            sysBlkTsIsTriggered=all(sysBlkTs==trigTs);
        end
        if(strcmp(sampleTimeConstraint,'STIndependent')||sysBlkTsIsTriggered)
            set_param(harnessH,'SampleTimeConstraint','STIndependent');
        end
    end

    if iscell(tsInfo.blkSampleTime)
        if((length(tsInfo.blkSampleTime)==2)&&...
            (isequal(tsInfo.blkSampleTime{2},[inf,0])))
            tsInfo.blkSampleTime=tsInfo.blkSampleTime{1};
        end
    end


    if strcmp(get_param(harnessH,'AutosarCompliant'),'on')&&...
        ~iscell(tsInfo.blkSampleTime)&&...
        (tsInfo.blkSampleTime(1)~=-1)&&...
        (tsInfo.blkSampleTime(1)~=Inf)
        set_param(harnessH,'FixedStep',num2str(tsInfo.blkSampleTime(1)));
    elseif(tsInfo.bUseFundStepSize&&~bIsVariableStepSolver)
        tsStr=sprintf('%.17g',tsInfo.bFundStepSize);
        set_param(harnessH,'FixedStep',tsStr);
    elseif tsInfo.bSetFixedStepAuto
        set_param(harnessH,'FixedStep','auto');
    end

    set_param(harnessH,'DataTypeOverride',tsInfo.actualDataTypeOverride);


    set_param(harnessH,'CheckMdlBeforeBuild','Off');

    harnessObj=get_param(harnessH,'Object');
    cs=harnessObj.getActiveConfigSet();
    cs.setPropEnabled('Name',true)





    extractedCUT=find_system(harnessH,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
    extractedCUT_BlockType=get_param(extractedCUT,'BlockType');
    if~strcmp(extractedCUT_BlockType,'ModelReference')
        if~strcmp(get_param(extractedCUT,'LinkStatus'),'resolved')&&...
            strcmp(get_param(extractedCUT,'IsSubsystemVirtual'),'off')
            set_param(extractedCUT,'TreatAsAtomicUnit','on');
        end
    end


    inportBlocks=find_system(harnessH,'SearchDepth',1,'BlockType','Inport');
    n=length(inportBlocks);
    for i=1:n
        set_param(inportBlocks(i),'Interpolate','off');
    end


    var_name_str=get_param(modelH,'TunableVars');
    var_stor_class=get_param(modelH,'TunableVarsStorageClass');
    var_qual=get_param(modelH,'TunableVarsTypeQualifier');

    set_param(harnessH,...
    'TunableVars',var_name_str,...
    'TunableVarsStorageClass',var_stor_class,...
    'TunableVarsTypeQualifier',var_qual);


    cutH=Simulink.ID.getHandle([harnessName,':1']);
    outSaveName=get_param(harnessH,'OutputSaveName');
    strPorts=coder.internal.IOUtils.GetSubsystemIOPorts(cutH);
    idx=strfind(outSaveName,',');
    if~isempty(idx)&&((length(idx)+1)>strPorts.numOfOutports)
        outSaveName=outSaveName(1:idx(strPorts.numOfOutports)-1);
        set_param(harnessH,'OutputSaveName',outSaveName);
    end

    if tsInfo.extractMode==2




        dsmInfo=coder.internal.DataStoreUtils.getNeededDSMInfo(cutH);
        strPorts.numOfDataStoreBlks=length(dsmInfo);
        for i=1:strPorts.numOfDataStoreBlks
            strPorts.dataStoreBlks(i)=dsmInfo(i).Handle;
            strPorts.DSMemPrm{i}=coder.internal.DataStoreUtils.convDSMInfoToPortPrm(dsmInfo(i));
        end
    end


    CallbacksParameters={'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn','PauseFcn','ContinueFcn',...
    'StopFcn','PreSaveFcn','PostSaveFcn'};
    for i=1:length(CallbacksParameters)
        set_param(harnessH,CallbacksParameters{i},get_param(modelH,CallbacksParameters{i}));
    end






    parentH=get_param(subsysH,'Parent');
    coder.internal.Utilities.LocalCopyWSData(get_param(parentH,'Object'),...
    get_param(harnessH,'ModelWorkspace'));

end


