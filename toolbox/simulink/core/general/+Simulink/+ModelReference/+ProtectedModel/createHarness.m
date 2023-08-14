function harnessHandle=createHarness(protectedModelName,varargin)





    creatorObj={};



    [protectedModelName,protectedModelFile]=ProtectedModelFileCheck(protectedModelName);


    if length(protectedModelName)>47
        harnessModel=[protectedModelName(1:47),'_harness'];
    else
        harnessModel=[protectedModelName,'_harness'];
    end
    dataConnection=Simulink.data.BaseWorkspace;
    harnessModel=Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(...
    harnessModel,1000,dataConnection,0);

    if nargin==2&&~isempty(varargin{1})
        harnessModel=varargin{1};
    elseif nargin>2
        creatorObj=varargin{2};
    end



    oc1=loc_suppressWarning('Simulink:Harness:ExportDeleteHarnessFromSystemModel');

    oc2=loc_suppressWarning('Simulink:Engine:InputNotConnected');
    oc3=loc_suppressWarning('Simulink:Engine:OutputNotConnected');

    oc4=loc_suppressWarning('Simulink:Engine:MdlFileShadowedByFile');

    oc5=loc_suppressWarning('Simulink:SampleTime:SourceInheritedTS');

    if(isempty(creatorObj))


        [harnessModelName,harnessModelPath]=HarnessModelFileCheck(harnessModel);


        initialDir=pwd;
        tmpBuildFolder=tempname;
        mkdir(tmpBuildFolder);
        cd(tmpBuildFolder);
        addpath(initialDir);
        ocPath=onCleanup(@()loc_handleTempDirAtClosing(tmpBuildFolder,initialDir));
    else
        certificateFeature=slfeature('ProtectedModelValidateCertificatePreferences');
        if certificateFeature>0

            Simulink.ProtectedModel.suppressSignatureVerification(protectedModelFile);
            cleanup=onCleanup(@()Simulink.ProtectedModel.suppressSignatureVerification(protectedModelFile,false));
        end

        harnessModelName=harnessModel;
        if(creatorObj.CreateProject)
            harnessModelPath=creatorObj.tmpBuildFolder;
        else

            harnessModelPath=creatorObj.ZipPath;
        end



    end

    [~,tmpModel,~]=fileparts(tempname);
    load_system(new_system(tmpModel));
    cln=onCleanup(@()close_system(tmpModel,0));

    blkName=createModelrefBlock(tmpModel,protectedModelName,creatorObj);



    setupTempModel(creatorObj,tmpModel,blkName,protectedModelName)



    UpdateDigram(tmpModel,blkName,protectedModelName);


    harnessInfo=Simulink.harness.internal.create(blkName,false,false,'Name',harnessModelName);
    harnessModelFile=fullfile(harnessModelPath,[harnessModelName,'.slx']);
    Simulink.harness.internal.export(blkName,harnessInfo.name,false,'Name',harnessModelFile);


    matFileName=CreateMatFile(creatorObj,protectedModelName,harnessModelPath);

    open_system(harnessModelFile);


    if(~isempty(matFileName))
        command=sprintf('load(''%s'')',matFileName);
        set_param(harnessModelName,'PreLoadfcn',command);
        save_system(harnessModelName);
    end


    harnessHandle=get_param(harnessModelName,'Handle');


    clear oc1 oc2 oc3 oc4 oc5;
    if(isempty(creatorObj))
        clear ocPath
    else
        if(slfeature('ProtectedModelValidateCertificatePreferences')>0)
            delete(cleanup);
        end
    end


end

function setupTempModel(creatorObj,tmpModel,blkName,protectedModelName)


    tmpModel=loc_handleConfigSet(protectedModelName,tmpModel);


    set_param(tmpModel,'UnconnectedInputMsg','none',...
    'UnconnectedOutputMsg','none');


    handleDataDictionaryIfPossible(protectedModelName,tmpModel);


    handleVardimInportsIfPossible(tmpModel,blkName,protectedModelName)


    AddFcnCallPortWithSampleTimeIfPossible(tmpModel,blkName,protectedModelName);


    SetModelArgumentValuesIfPossible(blkName,creatorObj);
end

function handleDataDictionaryIfPossible(modelName,tmpModel)

    if~bdIsLoaded(modelName)
        return;
    end


    DataDicionaryName=get_param(modelName,'DataDictionary');
    set_param(tmpModel,'DataDictionary',DataDicionaryName);
    set_param(tmpModel,'EnableAccessToBaseWorkspace',...
    get_param(modelName,'EnableAccessToBaseWorkspace'));
end

function matFileName=CreateMatFile(creatorObj,modelName,pathstr)

    matFileName='';
    if(isempty(creatorObj)||...
        isempty(creatorObj.GlobalVariables))
        return;
    end

    baseVariableTable=creatorObj.GlobalVariables(strcmp(creatorObj.GlobalVariables.Source,''),:);
    neededVars=baseVariableTable.VariableName;

    allWorkspaceVars=evalin('base','whos');
    WorkspaceVarNames={allWorkspaceVars.name}';
    neededVarsInBW=intersect(neededVars,WorkspaceVarNames);
    if(~isempty(neededVarsInBW))


        matFileName=[modelName,'_BaseWorkspace'];
        dataConnection=Simulink.data.BaseWorkspace;
        matFileName=Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(...
        matFileName,1000,dataConnection,0);
        matFileName=[matFileName,'.mat'];
        matFileFullPath=fullfile(pathstr,matFileName);


        varlist=strjoin(neededVarsInBW,''', ''');
        cmd=sprintf("save('%s', '%s')",matFileFullPath,varlist);
        evalin('base',cmd)
    end

end


function[harnessModelName,harnessModelPath]=HarnessModelFileCheck(harnessModel)

    [pathstr,harnessModelName,ext]=fileparts(harnessModel);
    if(isempty(pathstr))
        pathstr=pwd;
        harnessModel=fullfile(pathstr,harnessModelName);
    end
    harnessModelPath=pathstr;

    if~isempty(ext)&&~strcmpi(ext,'.slx')
        DAStudio.error('Simulink:LoadSave:InvalidFileNameExtension',harnessModel);
    end

    [fileStatus,message,messageID]=fileattrib(pathstr);
    if(fileStatus)
        if~message.UserWrite
            DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',harnessModelName,pathstr);
        end
    else
        DAStudio.error(messageID);
    end


end

function[protectedModelName,protectedModelFile]=ProtectedModelFileCheck(protectedModelFile)

    [path,protectedModelName,ext]=fileparts(protectedModelFile);
    if(isempty(ext)&&isempty(path))
        protectedModelFile=slInternal('getPackageNameForModel',protectedModelName);
    elseif~slInternal('hasProtectedSimulinkExtension',protectedModelFile)
        DAStudio.error('Simulink:protectedModel:unableToFindProtectedModelFile',protectedModelName);
    end

    if isempty(which(protectedModelFile))
        DAStudio.error('RTW:utility:invalidModel',protectedModelName);

    end

end

function cleanupObj=loc_suppressWarning(msgID)
    warnStatus=warning('query',msgID);
    warnState=warnStatus.state;
    cleanupObj=onCleanup(@()warning(warnState,msgID));
    warning('off',msgID);
end

function isSuccessful=UpdateDigram(model,blkName,protectedModelName)
    try
        isSuccessful=false;
        set_param(model,'SimulationCommand','Update');
        isSuccessful=true;

    catch ME
        switch(ME.identifier)
        case 'Simulink:SampleTime:InValidMdlRefInitResetInportBranching'

            set_param(blkName,'ShowModelInitializePort','on');
            set_param(blkName,'ShowModelTerminatePort','on');
            set_param(blkName,'ShowModelResetPorts','on');
            set_param(blkName,'ShowModelReinitializePorts','on');

        case 'Simulink:SampleTime:InValidMdlRefInitInportBranching'
            set_param(blkName,'ShowModelInitializePort','on');
            set_param(blkName,'ShowModelTerminatePort','on');

        case 'Simulink:SampleTime:InValidMdlRefResetInportBranching'
            set_param(blkName,'ShowModelResetPorts','on');
            set_param(blkName,'ShowModelReinitializePorts','on');

        case 'Simulink:modelReference:ConstTsMdlBlkCannotHaveEventPorts'
            set_param(blkName,'ShowModelInitializePort','off');
            set_param(blkName,'ShowModelTerminatePort','off');
            set_param(blkName,'ShowModelResetPorts','off');
            set_param(blkName,'ShowModelReinitializePorts','off');
            set_param(blkName,'ShowModelPeriodicEventPorts','off');

        case 'Simulink:modelReference:ModelBlockWithEventPortCannotHaveVirtualBusInput'
            set_param(blkName,'ShowModelInitializePort','off');
            set_param(blkName,'ShowModelTerminatePort','off');
            set_param(blkName,'ShowModelResetPorts','off');
            set_param(blkName,'ShowModelReinitializePorts','off');
            set_param(blkName,'ShowModelPeriodicEventPorts','off');

        case{'Simulink:modelReference:InvalidContinuousSampForMdlrefOnInput',...
            'Simulink:modelReference:InvalidContinuousSampleTime',...
            'Simulink:modelReference:InvalidContinuousSampForMdlrefOnOutput',...
            'Simulink:Subsystems:NoBlocksWithNonIRTSampleTime',...
            'Simulink:SampleTime:FixedStepSizeHeuristicErr',...
            'Simulink:Engine:NoBlocksInModel'}


            addDiscreteSineWave(model);

        case 'SimulinkPartitioning:Config:ExplicitPartitioningModelNotExportingPartitions'
            set_param_action(blkName,'ScheduleRates','on','ScheduleRatesWith','Schedule Editor');

        case 'Simulink:FcnCall:FcnCallModelRefInvDiagSettings'
            set_param_action(model,'MultiTaskCondExecSysMsg','error');

        case 'Simulink:Logging:InvDataLogOutputMultiSaveName'
            set_param(model,'SaveOutput','off');

        case 'Simulink:SampleTime:TsMismatchForTsDepModelBlk'


            fcn=find_system(model,'SearchDepth',1,'BlockType','S-Function');
            if(~isempty(fcn))
                set_param(fcn{1},'sample_time','-1');
            else
                newException=MException(message('Simulink:protectedModel:NoHarnessOrProject',protectedModelName));
                throwAsCaller(addCause(newException,ME));
            end

        case 'Simulink:FcnCall:FcnCallPortMustBeDrivenByAsyncFcnCaller'
            DAStudio.error('Simulink:protectedModel:NoHarnessForAsyncFcnCall',protectedModelName);

        case 'Simulink:Engine:CannotPropFixedDimsModeForward'
            DAStudio.error('Simulink:protectedModel:NoHarnessForVarSizeSignalInports',protectedModelName);

        otherwise
            newException=MException(message('Simulink:protectedModel:NoHarnessOrProject',protectedModelName));
            throwAsCaller(addCause(newException,ME));
        end
    end
    if~isSuccessful
        UpdateDigram(model,blkName,protectedModelName);
    end
end

function tmpModel=loc_handleConfigSet(protectedModelName,tmpModel)
    import Simulink.ModelReference.ProtectedModel.*;


    target=Simulink.ModelReference.ProtectedModel.getCurrentTarget(protectedModelName);
    if(strcmp(target,'viewonly'))
        DAStudio.error('Simulink:protectedModel:NoHarnessForViewOnlyProtectedModels',protectedModelName);
    end


    [opts,fullName]=Simulink.ModelReference.ProtectedModel.getOptions(protectedModelName);
    if PasswordManager.isEncryptionCategoryEncrypted(protectedModelName,'RTW')
        getPasswordFromDialog(protectedModelName,'','RTW',true,opts);
    elseif PasswordManager.isEncryptionCategoryEncrypted(protectedModelName,'SIM')
        getPasswordFromDialog(protectedModelName,'','SIM',true,opts);

    end



    if strcmp(target,'sim')&&~slInternal('isProtectedModelFromThisSimulinkVersion',fullName)&&...
        ~opts.report&&strcmp(opts.modes,'Normal')
        versionStr=slInternal('getProtectedModelVersion',fullName);
        protectedModelVersion=simulink_version(versionStr);
        if(protectedModelVersion<simulink_version('R2020a'))
            return;
        end
    end



    unitCfg=Simulink.ModelReference.ProtectedModel.getConfigSet(protectedModelName);
    unitCfgCopy=unitCfg.copy;
    unitCfgCopy.name='MdlRefConfig';
    attachConfigSet(tmpModel,unitCfgCopy);
    setActiveConfigSet(tmpModel,'MdlRefConfig');
    detachConfigSet(tmpModel,'Configuration');

end

function out=loc_handleTempDirAtClosing(tmpBuildFolder,initialDir)
    rmpath(initialDir);
    cd(initialDir);
    slprivate('removeDir',tmpBuildFolder);
end

function SetModelArgumentValuesIfPossible(blkName,creatorObj)


    inputIsMdlRefBlock=~isempty(creatorObj)&&~isempty(strfind(creatorObj.Input,'/'));
    if(inputIsMdlRefBlock)
        ip=get_param(creatorObj.Input,'InstanceParameters');
        ih=get_param(blkName,'InstanceParameters');

        for i=1:length(ip)
            ih(i).Value=ip(i).Value;
        end
        set_param(blkName,'InstanceParameters',ih);
    end

end

function blkName=createModelrefBlock(tmpModel,protectedModelName,creatorObj)
    protectedModelFile=slInternal('getPackageNameForModel',protectedModelName);

    inputIsMdlRefBlock=~isempty(creatorObj)&&~isempty(strfind(creatorObj.Input,'/'));
    if(inputIsMdlRefBlock)
        blkName=[tmpModel,'/',get_param(creatorObj.Input,'Name')];
        handle=add_block(creatorObj.Input,blkName,'CopyOption','nolink');
        set_param(handle,'SimulationMode','accel');



        attribute=get_param(blkName,'AttributesFormatString');
        if(~isempty(attribute))
            attribute=strrep(attribute,'%<ModelName>','%<ModelFile>');
            set_param(handle,'AttributesFormatString',attribute);
        end

        set_param(handle,'LinkStatus','none');
        set_param(handle,'ModelName',protectedModelFile);

    else
        blkName=[tmpModel,'/Model'];
        add_block(sprintf('simulink/Ports &\nSubsystems/Model'),blkName);
        set_param(blkName,'ModelName',protectedModelFile);

    end

end

function addDiscreteSineWave(tmpModel)

    out=add_block('built-in/Outport',[tmpModel,'/Out'],'MakeNameUnique','on');
    sinWave=add_block('built-in/Sin',[tmpModel,'/Sine Wave'],'MakeNameUnique','on');
    set_param(sinWave,'SampleTime','1');



    ph=get_param(out,'PortHandles');
    abh=get_param(sinWave,'PortHandles');
    add_line(tmpModel,abh.Outport,ph.Inport);

end

function AddFcnCallPortWithSampleTimeIfPossible(tmpModel,blkName,modelName)


    h=get_param(blkName,'porthandles');
    triggerType=get_param(blkName,'TriggerPortTriggerType');

    if(isempty(h.Trigger)||~strcmp(triggerType,'function-call'))
        return;
    end

    fcn=add_block('simulink/Ports & Subsystems/Function-Call Generator',[tmpModel,'/fcnCall']);


    if~bdIsLoaded(modelName)||...
        strcmp(get_param(tmpModel,'SampleTimeConstraint'),'STIndependent')
        set_param(fcn,'sample_time','-1');
    else
        inports=find_system(modelName,'SearchDepth',1,'BlockType','TriggerPort');
        st=get_param(inports,'SampleTime');
        set_param(fcn,'sample_time',st{1});
    end


    ph=get_param(fcn,'PortHandles');
    add_line(tmpModel,ph.Outport,h.Trigger);
end

function handleVardimInportsIfPossible(tmpModel,blkName,modelName)

    if~bdIsLoaded(modelName)
        return;
    end

    h=get_param(blkName,'porthandles');


    inports=find_system(modelName,'SearchDepth',1,'BlockType','Inport');


    for i=1:length(inports)
        vardimInfo=get_param(inports(i),'VarSizeSig');
        if(strcmp(vardimInfo,'Yes'))
            in=add_block('built-in/Inport',[tmpModel,'/In'],'MakeNameUnique','on');
            set_param(in,'VarSizeSig','Yes');
            set_param(in,'Interpolate','off');


            ph=get_param(in,'PortHandles');
            add_line(tmpModel,ph.Outport,h.Inport(i));
        end

        outputFunctionCallInfo=get_param(inports(i),'OutputFunctionCall');
        if(strcmp(outputFunctionCallInfo,'on'))

            pc=get_param(inports(i),'PortConnectivity');
            dst=pc{1}.DstBlock;
            blockType=get_param(dst,'BlockType');
            isAsync=strcmp(blockType,'AsynchronousTaskSpecification');

            if(isAsync)
                taskPriority=get_param(dst,'taskPriority');
                in=add_block('built-in/Inport',[tmpModel,'/In'],'MakeNameUnique','on');

                set_param(in,'OutputFunctionCall','on');

                asynctaskBlock=add_block('rtwlib/Asynchronous/Asynchronous Task Specification',[tmpModel,'/asyncTaskSpec'],'MakeNameUnique','on');
                set_param(asynctaskBlock,'taskPriority',taskPriority);


                ph=get_param(in,'PortHandles');
                abh=get_param(asynctaskBlock,'PortHandles');
                add_line(tmpModel,ph.Outport,abh.Inport);
                add_line(tmpModel,abh.Outport,h.Inport(i));
            end
        end

    end
end



