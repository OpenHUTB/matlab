function[mdl_hdl,strPorts,error_occ,mExc]=ss2mdl(block_hdl,varargin)












    blkH=get_param(block_hdl,'Handle');
    mdlH=bdroot(blkH);


    wstate=coder.internal.WarningState;%#ok  

    params=coder.internal.RightClickBuild.parse(varargin{:});




    modelH=bdroot(block_hdl);
    ssType=Simulink.SubsystemType(block_hdl);

    mdl_hdl=-1;
    strPorts=[];
    error_occ=false;
    mExc=[];
    nameObj=Simulink.ModelReference.Conversion.NameUtils;
    modelRefName=nameObj.getValidModelName(block_hdl);




    needToCopySubsystem=ssType.isTriggeredSubsystem|ssType.isFunctionCallSubsystem|...
    ssType.isEnabledAndTriggeredSubsystem|ssType.isEnabledSubsystem|ssType.isResettableSubsystem;


    isExportFunction=params.ExportFunctions;
    if(isExportFunction)
        convertOptions={'AutoFix',true,'RightClickBuild',true,...
        'ExpandVirtualBusPorts',params.ExpandVirtualBusPorts,...
        'ExportedFunctionSubsystem',true,...
        'ReplaceSubsystem',params.ReplaceSubsystem,...
        'CheckSimulationResults',params.CheckSimulationResults,...
        'SS2mdlForPLC',params.SS2mdlForPLC};

        if~isempty(params.ExpFcnFileName)
            modelRefName=params.ExpFcnFileName;
        end

        if~isempty(params.ExpFcnInitFcnName)
            convertOptions{end+1}='ExpFcnInitFcnName';
            convertOptions{end+1}=params.ExpFcnInitFcnName;
        end

        if needToCopySubsystem
            convertOptions{end+1}='CopySubsystem';
            convertOptions{end+1}=true;
        end

        try
            this=Simulink.ModelReference.Conversion.RightClickBuildExportFunction(block_hdl,modelRefName,convertOptions{:});
            this.convert;
            mdl_hdl=get_param(modelRefName,'Handle');
        catch mExc
            error_occ=true;
            if params.PushNags
                modelName=get_param(modelH,'Name');

                m_stage=sldiagviewer.createStage(DAStudio.message('Simulink:modelReferenceAdvisor:Category'),...
                'ModelName',modelName);%#ok<NASGU>
                slprivate('pushExceptionOnNagController',mExc,...
                DAStudio.message('Simulink:modelReferenceAdvisor:Category'),modelName,true);

                return;
            else
                rethrow(mExc);
            end
        end

        if ishandle(block_hdl)
            thisHdl=coder.internal.RightClickBuild.create(mdlH,block_hdl,varargin{:});


            thisHdl.pushNags=false;
            modelAction=Simulink.ModelActions(modelH);
            modelAction.compile;
            strPorts=getIOInfo(block_hdl,thisHdl,mdlH);
            strPorts.GenerateSFunction=params.GenerateSFunction;
            modelAction.terminate;
        else
            strPorts=[];
        end
    else
        useSubsystemConversion=~params.GenerateSFunction&&~strcmp(get_param(mdlH,'SystemTargetFile'),'rtwsfcn.tlc')...
        &&~params.SS2mdlForPLC;
        if slfeature('RightClickBuild')&&useSubsystemConversion
            convertOptions={'AutoFix',true,'RightClickBuild',true,...
            'ExpandVirtualBusPorts',params.ExpandVirtualBusPorts,...
            'ReplaceSubsystem',params.ReplaceSubsystem,...
            'CheckSimulationResults',params.CheckSimulationResults,...
            'SS2mdlForPLC',params.SS2mdlForPLC,...
            'PropagateSignalStorageClass',true};

            if~isempty(params.ExpFcnFileName)
                modelRefName=params.ExpFcnFileName;
            end

            if~isempty(params.ExpFcnInitFcnName)
                convertOptions{end+1}='ExpFcnInitFcnName';
                convertOptions{end+1}=params.ExpFcnInitFcnName;
            end

            if needToCopySubsystem
                convertOptions{end+1}='CopySubsystem';
                convertOptions{end+1}=true;
            end


            fcnName=get_param(block_hdl,'RTWFcnName');
            if~isempty(fcnName)
                base_name=fcnName;
                modelName=bdroot(block_hdl);
                dataAccessor=Simulink.data.DataAccessor.createForExternalData(modelName);
                base_name=Simulink.ModelReference.Conversion.NameUtils.getModelNameFromBaseName(base_name);
                maxIters=1000;
                excludedNames={};


                maxIdLength=get_param(bdroot(block_hdl),'MaxIdLength');
                maxLen=min(namelengthmax,maxIdLength)-3;
                if(length(base_name)>maxLen)
                    base_name=base_name(1:maxLen);
                end


                if strcmpi(base_name,'matrix')||strcmpi(base_name,'vector')
                    base_name=[base_name,'0'];
                end

                startIndex=0;
                modelRefName=Simulink.ModelReference.Conversion.NameUtils.getValidModelNameForBase(...
                base_name,maxIters,dataAccessor,startIndex,excludedNames);

            end

            compileTimeIOAttributes=[];
            try
                this=Simulink.ModelReference.Conversion.RightClickBuild(block_hdl,modelRefName,convertOptions{:});
                this.convert;
                mdl_hdl=get_param(modelRefName,'Handle');
                compileTimeIOAttributes=this.CompileTimeIOAttributes;
            catch mExc
                error_occ=true;
                if params.PushNags
                    modelName=get_param(modelH,'Name');

                    m_stage=sldiagviewer.createStage(DAStudio.message('Simulink:modelReferenceAdvisor:Category'),...
                    'ModelName',modelName);%#ok<NASGU>
                    slprivate('pushExceptionOnNagController',mExc,...
                    DAStudio.message('Simulink:modelReferenceAdvisor:Category'),modelName,true);

                    return;
                else
                    rethrow(mExc);
                end
            end

            if ishandle(block_hdl)
                thisHdl=coder.internal.RightClickBuild.create(mdlH,block_hdl,varargin{:});


                thisHdl.pushNags=false;
                modelAction=Simulink.ModelActions(modelH);
                modelAction.compile;
                strPorts=getIOInfo(block_hdl,thisHdl,mdlH);
                strPorts.GenerateSFunction=params.GenerateSFunction;
                if slfeature('RightClickBuild')~=0
                    try
                        strPorts.isSingleRateSS=get_param(block_hdl,'IsSingleRateSS');
                    catch exec %#ok<NASGU>
                    end

                    if~isempty(compileTimeIOAttributes)
                        strPorts.CompileTimeIOAttributes=compileTimeIOAttributes;
                    end
                end
                modelAction.terminate;
                if ishandle(mdl_hdl)
                    try
                        strPorts.referencedWSVars=get_param(mdl_hdl,'ReferencedWSVars');
                    catch exec %#ok<NASGU>
                        strPorts.referencedWSVars=[];
                    end
                end
            else
                strPorts=[];
            end
        else

            preserve_dirty=Simulink.PreserveDirtyFlag(mdlH,'blockDiagram');
            mdlObj=get_param(mdlH,'Object');
            origCS=mdlObj.getActiveConfigSet();
            bRethrowError=false;
            bMdlIsStopped=~strcmp(get_param(mdlH,'SimulationStatus'),'paused');

            if~slprivate('checkSimPrm',origCS)
                DAStudio.error('RTW:buildProcess:StopAtUserRequest');
            end

            mExc=[];
            try
                if bMdlIsStopped
                    if isa(origCS,'Simulink.ConfigSetRef')
                        newCS=origCS.getResolvedConfigSetCopy();
                    else
                        newCS=origCS.copy;
                    end
                    attachConfigSet(mdlH,newCS,true);
                    setActiveConfigSet(mdlH,newCS.Name)
                end
                [mdl_hdl,strPorts,error_occ,mExc]=ss2mdl_l(mdlH,blkH,varargin{:});
            catch exc
                bRethrowError=true;
                error_occ=1;
            end


            if bMdlIsStopped
                if strcmp(get_param(mdlH,'SimulationStatus'),'paused')
                    feval(get_param(mdlH,'Name'),[],[],[],'term');
                end
                setActiveConfigSet(mdlH,origCS.Name);
                detachConfigSet(mdlH,newCS.Name);
                delete(preserve_dirty);
            end


            if bRethrowError
                rethrow(exc);
            end
        end
    end
end

function[mdl_hdl,strPorts,error_occ,mExc]=ss2mdl_l(origMdlHdl,block_hdl,varargin)
    clear slBus;
    thisHdl=coder.internal.RightClickBuild.create(origMdlHdl,block_hdl,varargin{:});
    warning('off','backtrace');

    mdl_hdl=-1;
    strPorts=[];
    mExc=coder.internal.ss2mdl_basic_checks(origMdlHdl,block_hdl,thisHdl,true);
    error_occ=~isempty(mExc);
    if error_occ
        return;
    end

    portH=get_param(block_hdl,'PortHandles');



    Simulink.ModelReference.Conversion.SubsystemConversionCheck.checkModelBeforeBuildStatic(block_hdl);




    [strPorts,error_occ,error_code,exc]=coder.internal.IOUtils.GetSubsystemIOPorts(block_hdl);
    if error_occ
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,error_code,exc,thisHdl);
        return;
    end



    blkObj=get_param(block_hdl,'object');
    if blkObj.hasLinkToADirtyLibrary
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'HasLinkToDirtyLibrary',[],thisHdl);
        error_occ=1;
        return;
    end


    blkObj.updateReference;

    try
        coder.internal.BusUtils.cacheCompiledBusInfo(block_hdl,strPorts,'on');
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SetCompiledBusInfo',exc,thisHdl);
        error_occ=1;
        return;
    end




    [error_occ,hasStateflow,machineId,modelWasCompiled,exc]=thisHdl.compileModel(strPorts);
    if error_occ
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'CompileOrigModel',exc,thisHdl);
        return;
    end

    if~isequal(get_param(origMdlHdl,'SimulationStatus'),'paused')
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'CompileOrigModel',[],thisHdl);
        error_occ=1;
        return;
    end




    if strcmp(get_param(block_hdl,'CompiledIsActive'),'off')
        DAStudio.error('RTW:buildProcess:InactiveSubsystem');
    end




    if(thisHdl.ss2mdlForPLC)
        tk=PLCCoder.PLCToken.getToken;
        if(strcmp(get_param(origMdlHdl,'SolverType'),'Variable-step'))
            tk.setBaseSampleTime(0);
        else
            tk.setBaseSampleTime(str2double(get_param(origMdlHdl,'CompiledStepSize')));
        end
    end






    if hasStateflow&&strcmp(get_param(block_hdl,'LinkStatus'),'resolved')
        if slprivate('is_stateflow_based_block',block_hdl)
            sfBlks{1}=block_hdl;
        else
            libBlk=get_param(block_hdl,'ReferenceBlock');
            libBd=strtok(libBlk,'/');


            if~bdIsLoaded(libBd)
                load_system(libBd);
            end


            sfBlks=find_system(libBlk,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Type','Block','MaskType','Stateflow');

        end
        if~isempty(sfBlks)
            chartId=sfprivate('block2chart',get_param(sfBlks{1},'Handle'));
            machineId=sf('get',chartId,'chart.machine');
        end
    end








    bSetFixedStepAuto=true;
    fixedStepPrm=get_param(origMdlHdl,'FixedStep');

    bUseFundStepSize=false;
    bFundStepSize=str2double(get_param(origMdlHdl,'CompiledStepSize'));
    if(strcmp(get_param(origMdlHdl,'SolverType'),'Variable-step'))
        bFundStepSize=0;
    end
    blkSampleTime=get_param(block_hdl,'CompiledSampleTime');
    if~strcmpi(fixedStepPrm,'auto')
        bSetFixedStepAuto=coder.internal.SampleTimeChecks.loc_shouldUseAutoFixedStep(block_hdl,bFundStepSize,blkSampleTime);
    else




        bUseFundStepSize=~coder.internal.SampleTimeChecks.loc_shouldUseAutoFixedStep(block_hdl,bFundStepSize,blkSampleTime);
    end

    try
        needConvertSys=thisHdl.runChecks;
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'CheckFailed',exc,thisHdl);
        error_occ=1;
        return;
    end

    try
        strPorts.isSingleRateSS=get_param(block_hdl,'IsSingleRateSS');
    catch exc %#ok<NASGU>
    end


    [strPorts,error_occ,mExc]=updateIOInfo(thisHdl,strPorts,portH,origMdlHdl);
    if~isempty(mExc)
        return;
    end




    try
        for i=1:strPorts.numOfFromBlks
            gotoPortH=coder.internal.GotoFromChecks.getGotoInportH(strPorts.fromBlks(i));
            [strPorts.From{i},thisHdl]=thisHdl.getbus(gotoPortH);
            if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.From{i})
                mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                [],thisHdl);
                error_occ=1;
                return;
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetFromSignals',exc,thisHdl);
        error_occ=1;
        return;
    end



    try
        for i=1:strPorts.numOfGotoBlks
            gotoPortH=get_param(strPorts.gotoBlks(i),'PortHandles');
            [strPorts.Goto{i},thisHdl]=thisHdl.getbus(gotoPortH.Inport);
            if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.Goto{i})
                mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',[],thisHdl);
                error_occ=1;
                return;
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetGotoSignals',exc,thisHdl);
        error_occ=1;
        return;
    end



    try
        dsmInfo=coder.internal.DataStoreUtils.getNeededDSMInfo(block_hdl);
        strPorts.numOfDataStoreBlks=length(dsmInfo);
        for i=1:strPorts.numOfDataStoreBlks
            strPorts.dataStoreBlks(i)=dsmInfo(i).Handle;
            strPorts.DSMemPrm{i}=coder.internal.DataStoreUtils.convDSMInfoToPortPrm(dsmInfo(i));






            strPorts.DSMemPrm{i}.blkSID=[get(origMdlHdl,'Name'),':0'];
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetWriteSignals',exc,thisHdl);
        error_occ=1;
        return;
    end






    strPorts.referencedWSVars=get_param(block_hdl,'ReferencedWSVars');




    if~thisHdl.exportFcns&&~thisHdl.ss2mdlForSLDV
        compiledInfo=get_param(block_hdl,'CompiledRTWSystemInfo');
        if~isempty(compiledInfo)&&ishandle(compiledInfo(7))
            mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'FcnCallWithInheritState',...
            [],thisHdl,compiledInfo(7),block_hdl);
            error_occ=1;
            return;
        end
    end




    if strcmp(get_param(origMdlHdl,'GenCodeOnly'),'off')
        for i=1:strPorts.numOfInports
            if strcmp(get_param(portH.Inport(i),'ActSrcComputeOutputInStart'),'on')
                MSLDiagnostic(...
                'RTW:buildProcess:ICHandShakingAcrossSSInportNotSupported',...
                i,getfullname(block_hdl),i,getfullname(block_hdl)).reportAsWarning;
            end
        end
        for i=1:strPorts.numOfOutports
            if strcmp(get_param(portH.Outport(i),'ActDstOKToReadInputInStart'),'on')
                MSLDiagnostic(...
                'RTW:buildProcess:ICHandShakingAcrossSSOutportNotSupported',...
                i,getfullname(block_hdl),i,getfullname(block_hdl)).reportAsWarning;
            end
        end
    end




    thisHdl.actualDataTypeOverride=...
    get_param(block_hdl,'DataTypeOverride_Compiled');

    blockPriority=Simulink.ModelReference.Conversion.BlockPrioritySort(block_hdl,thisHdl.exportFcns,thisHdl.ss2mdlForPLC);
    blockPriority.sort;


    isCppClass=strcmpi(get_param(origMdlHdl,'CodeInterfacePackaging'),'C++ Class');


    mappingCopier={};
    mappingERTC=Simulink.CodeMapping.get(origMdlHdl,'CoderDictionary');
    mappingGRTC=Simulink.CodeMapping.get(origMdlHdl,'SimulinkCoderCTarget');
    if(~isempty(mappingERTC)||~isempty(mappingGRTC))&&~isCppClass
        mappingCopier=coder.mapping.internal.createCodeMappingCopier(block_hdl,true);
        mappingCopier.CacheRootInportCodeMappings();
    end



    if~modelWasCompiled
        try
            modelActions=Simulink.ModelActions(origMdlHdl);
            modelActions.terminate;
        catch exc
            mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'CannotTerm',exc,thisHdl);
            error_occ=1;
            return;
        end
    end

    if error_occ,return;end




    strPorts.Orientation=get_param(block_hdl,'Orientation');





    [mdl_hdl,newBlkH,error_occ,mExc]=thisHdl.LocalCopySubSystemIntoNewModel(block_hdl);
    if error_occ,return;end

    newModelName=get_param(mdl_hdl,'Name');
    parentPath=get_param(block_hdl,'Parent');

    [error_occ,mExc]=blockPriority.resetBlockPriority(block_hdl,mdl_hdl,false);
    if error_occ,return;end


    origCS=getActiveConfigSet(origMdlHdl);







    coder.internal.Utilities.WarnIfMemSecsDifferent(block_hdl,origMdlHdl);




    try


        backupFields={'StateSaveName','OutputOption','OutputSaveName',...
        'OutputTimes','Open','CloseFcn','LoadExternalInput',...
        'LoadInitialState'};
        backupVals=cell(1,length(backupFields));
        for i=1:length(backupFields)
            backupVals{i}=get_param(mdl_hdl,backupFields{i});
        end




        configSetUtils=Simulink.ModelReference.Conversion.ConfigSet.create;
        configSetUtils.copy(origMdlHdl,mdl_hdl);
        if slfeature('ExecutionDomainExportFunction')==1



            set_param(mdl_hdl,'TempMdlNeedsGraphSearch','on');
        end
        if slfeature('ExecutionDomainExportFunction')>0
            if thisHdl.exportFcns

                set_param(mdl_hdl,'SetExecutionDomain','on');
                set_param(mdl_hdl,'ExecutionDomainType','ExportFunction');
            else

                set_param(mdl_hdl,'SetExecutionDomain','off');
                set_param(mdl_hdl,'ExecutionDomainType','Deduce');
            end
        end
        set_param(mdl_hdl,'Open','off');
        if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
            set_param(mdl_hdl,'EnableAccessToBaseWorkspace',...
            get_param(origMdlHdl,'EnableAccessToBaseWorkspace'));
        end






        coder.internal.Utilities.LocalCopyWSData(get_param(parentPath,'Object'),...
        get_param(mdl_hdl,'ModelWorkspace'));

        cs=getActiveConfigSet(mdl_hdl);


        if thisHdl.exportFcns
            if strcmp(get_param(origCS,'IsERTTarget'),'off')
                cs.switchTarget('ert.tlc',[]);
                cs.assignFrom(origCS,true);
            end
        end

        cs.reenableAllProps;

        for i=1:length(backupFields)
            set_param(mdl_hdl,backupFields{i},backupVals{i});
        end




        set_param(mdl_hdl,'DataTypeOverride',thisHdl.actualDataTypeOverride);




        if strcmp(get_param(mdl_hdl,'SignalResolutionControl'),...
            'TryResolveAllWithWarning')
            set_param(mdl_hdl,'SignalResolutionControl','TryResolveAll');
        end




        if~strcmp(get_param(mdl_hdl,'FrameProcessingCompatibilityMsg'),'none')
            set_param(mdl_hdl,'FrameProcessingCompatibilityMsg','none')
        end

        bIsVariableStepSolver=strcmp(get_param(origMdlHdl,'SolverType'),'Variable-step');











        if~bIsVariableStepSolver
            sampleTimeConstraint=get_param(origMdlHdl,'SampleTimeConstraint');
            trigTs=[-1,-1];
            sysBlkTs=get_param(block_hdl,'CompiledSampleTime');

            sysBlkTsIsTriggered=false;
            if(size(sysBlkTs)==size(trigTs))
                sysBlkTsIsTriggered=all(sysBlkTs==trigTs);
            elseif iscell(sysBlkTs)&&length(sysBlkTs)==2
                sysBlkTsIsTriggered=all(sysBlkTs{1}==[Inf,0])&&...
                all(sysBlkTs{2}==[-1,-1]);
            end

            if(strcmp(sampleTimeConstraint,'STIndependent')||sysBlkTsIsTriggered)
                set_param(mdl_hdl,'SampleTimeConstraint','STIndependent');
                strPorts=coder.internal.IOUtils.SetStrPortsField(strPorts,'CompiledSampleTime',[-1,-1]);
            end
        end

        if iscell(blkSampleTime)
            if((length(blkSampleTime)==2)&&...
                (isequal(blkSampleTime{2},[inf,0])))
                blkSampleTime=blkSampleTime{1};
            end
        end


        if strcmp(get_param(cs,'AutosarCompliant'),'on')&&...
            ~iscell(blkSampleTime)&&...
            (blkSampleTime(1)~=-1)&&...
            (blkSampleTime(1)~=Inf)
            set_param(mdl_hdl,'FixedStep',num2str(blkSampleTime(1)));
        elseif(bUseFundStepSize&&~bIsVariableStepSolver)
            tsStr=sprintf('%.17g',bFundStepSize);
            set_param(mdl_hdl,'FixedStep',tsStr);
        elseif bSetFixedStepAuto
            set_param(mdl_hdl,'FixedStep','auto');
        end
        set_param(mdl_hdl,'SolverPrmCheckMsg','none');


        if thisHdl.exportFcns
            set_param(mdl_hdl,'SolverMode','Auto');
            set_param(mdl_hdl,'CombineOutputUpdateFcns','on');

            if~strcmpi(get_param(mdl_hdl,'CodeInterfacePackaging'),'Nonreusable function')
                set_param(mdl_hdl,'CodeInterfacePackaging','Nonreusable function');
                MSLDiagnostic('RTW:buildProcess:MultiInstanceERTCodeNotSupportedFcnCallErr').reportAsWarning;
            end
            if~strcmpi(get_param(mdl_hdl,'GRTInterface'),'off')
                set_param(mdl_hdl,'GRTInterface','off');
                MSLDiagnostic('RTW:buildProcess:GRTInterfaceNotSupportedFcnCallErr').reportAsWarning;
            end
            if~strcmpi(get_param(origMdlHdl,'MatFileLogging'),'off')
                set_param(mdl_hdl,'MatFileLogging','off');
                MSLDiagnostic('RTW:buildProcess:MatFileLoggingNotSupportedFcnCallErr').reportAsWarning;
            end
            if isValidParam(cs,'GenerateSampleERTMain')&&...
                strcmpi(get_param(cs,'GenerateSampleERTMain'),'off')&&...
                strcmpi(get_param(cs,'CreateSILPILBlock'),'None')&&...
                strcmpi(get_param(cs,'GenCodeOnly'),'off')
                set_param(cs,'GenerateSampleERTMain','on');
                if isValidParam(cs,'TargetOS')
                    set_param(cs,'TargetOS','BareBoardExample');
                end
                MSLDiagnostic('RTW:buildProcess:GenerateSampleERTMainConstraintFcnCallErr').reportAsWarning;
            end
            if isValidParam(cs,'TargetOS')&&...
                isValidParam(cs,'GenerateSampleERTMain')&&...
                strcmpi(get_param(cs,'GenerateSampleERTMain'),'on')&&...
                ~strcmpi(get_param(cs,'TargetOS'),'BareBoardExample')
                set_param(cs,'TargetOS','BareBoardExample');
                MSLDiagnostic('RTW:buildProcess:BareBoardExampleConstraintFcnCallErr').reportAsWarning;
            end

        end










        TLCOptions=get_param(mdl_hdl,'TLCOptions');

        if hasStateflow
            TLCOptions=strcat(TLCOptions,' -aAlwaysIncludeCustomSrc=1');
        end


        if thisHdl.exportFcns
            TLCOptions=strcat(TLCOptions,sprintf(' -aExportFunctionsMode=%d',thisHdl.exportFcns));
            TLCOptions=strcat(TLCOptions,sprintf(' -aSuppressScheduler=1'));
        end

        set_param(mdl_hdl,'TLCOptions',TLCOptions);


        set_param(mdl_hdl,'CheckMdlBeforeBuild','Off');

    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'SetSimParameters',exc,thisHdl);
        error_occ=1;
        return;
    end







    siggens=find_system(origMdlHdl,'AllBlocks','on','searchdepth',1,'type','block','iotype','siggen');
    if~isempty(siggens)
        nSiggens=length(siggens);
        for i=1:nSiggens





            siggen=siggens(i);
            siggenName=get_param(siggen,'Name');
            mdlName=get_param(mdl_hdl,'Name');
            newSiggenName=[mdlName,'/',strrep(siggenName,'/','//')];
            newSiggen=add_block(siggen,newSiggenName);
            set_param(newSiggen,'ReconnectIORec','on');





            empty=true;
            iorec=get_param(newSiggen,'iosignals');
            nSets=length(iorec);
            for j=1:nSets
                set=iorec{j};
                nSigs=length(set);
                if(nSigs>1||(nSigs==1&&set(1).Handle~=-1))
                    empty=false;
                    break;
                end
            end
            if(empty)
                delete_block(newSiggen);
            else

                tempSID=Simulink.ID.getSID(newSiggen);
                origSID=Simulink.ID.getSID(siggen);
                rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);
            end
        end
    end




    blkPos=get_param(newBlkH,'Position');max_y=blkPos(end);
    try
        portH=get_param(newBlkH,'PortHandles');
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'GetPortHandlesNew',exc,thisHdl);
        error_occ=1;
        return;
    end





    try
        portHandles=zeros(1,strPorts.numOfInports);
        inlineSubsystemName=cell(1,strPorts.numOfInports);
        for i=1:strPorts.numOfInports
            [portHandles(i),thisHdl,inlineSubsystemName{i}]=coder.internal.BusUtils.inport2bus(strPorts.Inport{i},...
            mdl_hdl,thisHdl);
        end

        if strPorts.numOfInports>0
            srcPos=get_param(portHandles,'Position');
            if~iscell(srcPos)
                tempVar=srcPos;clear srcPos;srcPos{1}=tempVar;
            end

            max_x=[srcPos{:}];
            max_x=max(max_x(1:2:end));

            destPos=get_param(portH.Inport,'Position');
            if~iscell(destPos)
                tempVar=destPos;clear destPos;destPos{1}=tempVar;
            end

            posBlk=get_param(newBlkH,'Position');
            newPos=[max_x+100,srcPos{1}(2)]-destPos{1};
            posBlk=[(posBlk(1:2)+newPos),(posBlk(3:4)+newPos)];
            set_param(newBlkH,'Position',posBlk);

            for i=1:strPorts.numOfInports
                add_line(mdl_hdl,portHandles(i),portH.Inport(i));
                if~isempty(inlineSubsystemName{i})

                    s.origSubsystemParentName=parentPath;
                    s.newSubsysteParentName=get_param(newBlkH,'Parent');
                    s.origInlineSubsystemName=inlineSubsystemName{i};

                    coder.internal.Utilities.loc_setFcnCallSubsystemToInlineInNewModel(s);
                end
            end

            max_pos=get_param(portHandles(end),'Position');
            max_y=max(max_y,max_pos(end));
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectInportSignals',...
        exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfEnablePorts
            [portHandles(i),thisHdl]=coder.internal.BusUtils.inport2bus(strPorts.Enable{i},mdl_hdl,thisHdl);
            add_line(mdl_hdl,portHandles(i),portH.Enable(i));

            max_pos=get_param(portHandles(i),'Position');
            max_y=max(max_y,max_pos(end));
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectEnableSignals',...
        exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfTriggerPorts
            [portHandles(i),thisHdl]=coder.internal.BusUtils.inport2bus(strPorts.Trigger{i},mdl_hdl,thisHdl);
            add_line(mdl_hdl,portHandles(i),portH.Trigger(i));

            max_pos=get_param(portHandles(i),'Position');
            max_y=max(max_y,max_pos(end));
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectTriggerSignals',...
        exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfStateEnablePorts
            [portHandles(i),thisHdl]=coder.internal.BusUtils.inport2bus(strPorts.StateEnable{i},mdl_hdl,thisHdl);
            add_line(mdl_hdl,portHandles(i),portH.StateEnable(i));

            max_pos=get_param(portHandles(i),'Position');
            max_y=max(max_y,max_pos(end));
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectStateEnableSignals',...
        exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfResetPorts
            [portHandles(i),thisHdl]=coder.internal.BusUtils.inport2bus(strPorts.Reset{i},mdl_hdl,thisHdl);
            add_line(mdl_hdl,portHandles(i),portH.Reset(i));

            max_pos=get_param(portHandles(i),'Position');
            max_y=max(max_y,max_pos(end));
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectResetSignals',...
        exc,thisHdl);
        error_occ=1;
        return;
    end



    try
        for i=1:strPorts.numOfFromBlks
            [outPortH,thisHdl]=coder.internal.BusUtils.inport2bus(strPorts.From{i},mdl_hdl,thisHdl);
            portPos=get_param(outPortH,'Position');
            gotoPortH=coder.internal.GotoFromChecks.getGotoInportH(strPorts.fromBlks(i));
            srcGotoBlk=get_param(gotoPortH,'Parent');
            destGotoBlk=sprintf('%s/_GotoBlk_%d',newModelName,i);
            destPos=[portPos(1)+20,portPos(2)-10,portPos(1)+40,portPos(2)+10];
            newBlkH=add_block(srcGotoBlk,destGotoBlk,'Position',rtwprivate('sanitizePosition',destPos),...
            'ShowName','off');
            inPortH=get_param(newBlkH,'PortHandles');
            add_line(mdl_hdl,outPortH,inPortH.Inport);

            max_y=max(max_y,portPos(end));


            tempSID=Simulink.ID.getSID(newBlkH);



            origSID=coder.internal.Utilities.extractBlkSid(strPorts.From{i});
            rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectFromSignals',exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfOutports
            coder.internal.BusUtils.bus2outport(strPorts.Outport{i},mdl_hdl,portH.Outport(i),thisHdl);
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectOutportSignals',...
        exc,thisHdl);
        error_occ=1;
        return;
    end



    try
        if strPorts.numOfOutports>0
            lastPortPos=get_param(portH.Outport(end),'Position');
        else
            lastPortPos=[45,max_y];
        end

        lastPortPos(2)=lastPortPos(2)+20;
        for i=1:strPorts.numOfGotoBlks
            fromPortH=coder.internal.GotoFromChecks.getFromOutportH(strPorts.gotoBlks(i));
            srcFromBlk=get_param(fromPortH{1},'Parent');
            destFromBlk=sprintf('%s/_FromBlk_%d',newModelName,i);
            lastPortPos(2)=lastPortPos(2)+30;
            destPos=[lastPortPos(1)-25,lastPortPos(2)-10,...
            lastPortPos(1)-5,lastPortPos(2)+10];
            newBlkH=add_block(srcFromBlk,destFromBlk,'Position',rtwprivate('sanitizePosition',destPos),...
            'ShowName','off');
            fromPortH=get_param(newBlkH,'PortHandles');
            coder.internal.BusUtils.bus2outport(strPorts.Goto{i},mdl_hdl,fromPortH.Outport,thisHdl);


            tempSID=Simulink.ID.getSID(newBlkH);


            origSID=coder.internal.Utilities.extractBlkSid(strPorts.Goto{i});
            rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);
        end

        max_y=lastPortPos(2);
        if strPorts.numOfGotoBlks>0&&strPorts.numOfOutports>0
            portH.Outport(end)=fromPortH.Outport;
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'ConnectGotoSignals',exc,thisHdl);
        error_occ=1;
        return;
    end



    try
        if strPorts.numOfScopeBlks>0
            max_y=max_y+30;
            x_pos=20;
        end
        for i=1:strPorts.numOfScopeBlks
            destScopeBlk=sprintf('%s/_GotoScopeBlk_%d',newModelName,i);
            newPos=[x_pos,max_y-10,x_pos+20,max_y+10];
            newBlkH=add_block(strPorts.scopeBlks(i),destScopeBlk,'Position',rtwprivate('sanitizePosition',newPos),...
            'ShowName','off');
            x_pos=x_pos+30;


            tempSID=Simulink.ID.getSID(newBlkH);



            origSID=[get(origMdlHdl,'Name'),':0'];
            rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'AddGotoScopeBlocks',exc,thisHdl);
        error_occ=1;
        return;
    end



    try
        if strPorts.numOfScopeBlks==0&&strPorts.numOfDataStoreBlks>0
            max_y=max_y+30;
            x_pos=20;
        end
        for i=1:strPorts.numOfDataStoreBlks
            dsMemBlk=strPorts.dataStoreBlks(i);
            dstDSBlk=sprintf('%s/_DataStoreBlk_%d',newModelName,str2num(get_param(dsMemBlk,'SID')));
            newPos=[x_pos,max_y-10,x_pos+20,max_y+10];
            newBlkH=add_block(dsMemBlk,dstDSBlk,'Position',rtwprivate('sanitizePosition',newPos),'ShowName','off');
            set_param(newBlkH,'SFunctionWrapperMode','readwrite');
            coder.internal.ParameterUtils.LocalSetBlockParameters(newBlkH,strPorts.DSMemPrm{i},thisHdl);
            x_pos=x_pos+30;

            origDSSid=strPorts.DSMemPrm{i}.blkSID;
            tempDSSid=Simulink.ID.getSID(newBlkH);
            rtwprivate('rtwattic','addToSIDMap',tempDSSid,origDSSid);
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'AddDataStoreMemoryBlocks',...
        exc,thisHdl);
        error_occ=1;
        return;
    end

    try
        if~isempty(mappingCopier)
            copySubsystemStrategy=get_param(bdroot(mdl_hdl),'NewSubsystemHdlForRightClickBuild')==0;
            if copySubsystemStrategy
                copySubsystemStrategy=1;
            else
                copySubsystemStrategy=0;
            end
            mappingCopier.CopyCodeMappings(mdl_hdl,copySubsystemStrategy);
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,mdl_hdl,'CopyCodeMappings',...
        exc,thisHdl);
        error_occ=1;
        return;
    end





    [mdl_hdl,error_occ,mExc]=thisHdl.LocalCopyParams(newBlkH,block_hdl,cs,mdl_hdl,...
    origMdlHdl,hasStateflow,error_occ,mExc,machineId);
    if error_occ,return;end

    if needConvertSys
        newVirtualSys=coder.internal.slPrepMdlForExportFcn(mdl_hdl,block_hdl,thisHdl.expFcnFileName);
        [mdl_hdl,strPorts,error_occ,mExc]=coder.internal.ss2mdl(newVirtualSys,varargin{:});
    else
        if~isempty(thisHdl.expFcnFileName)
            set_param(mdl_hdl,'Name',thisHdl.expFcnFileName);
        end
        if~isempty(thisHdl.expFcnInitFcnName)
            TLCOptions=get_param(mdl_hdl,'TLCOptions');
            TLCOptions=strcat(TLCOptions,[' -aExpFcnInitFcnName=','"',thisHdl.expFcnInitFcnName,'"']);
            set_param(mdl_hdl,'TLCOptions',TLCOptions);
            reservedName=get_param(mdl_hdl,'ReservedNameArray');
            if isempty(reservedName)
                reservedName={thisHdl.expFcnInitFcnName};
            else
                reservedName=[reservedName,thisHdl.expFcnInitFcnName];
            end
            set_param(mdl_hdl,'ReservedNameArray',reservedName);
        end
    end
    delete(thisHdl);
    clear slBus;
end

function strPorts=getIOInfo(block_hdl,thisHdl,origMdlHdl)
    portH=get_param(block_hdl,'PortHandles');
    strPorts=coder.internal.IOUtils.GetSubsystemIOPorts(block_hdl);
    strPorts=updateIOInfo(thisHdl,strPorts,portH,origMdlHdl);
    strPorts.referencedWSVars=[];
end

function[strPorts,error_occ,mExc]=updateIOInfo(thisHdl,strPorts,portH,origMdlHdl)
    error_occ=[];
    mExc=[];
    try
        for i=1:strPorts.numOfInports
            [strPorts.Inport{i},thisHdl]=thisHdl.getbus(portH.Inport(i));
            if strPorts.Inport{i}.type==1
                if coder.internal.SampleTimeChecks.LocalHasMixedSampleTimeSrc(portH.Inport(i))
                    mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'InputPortMixedSampleTime',...
                    [],thisHdl,thisHdl.Systems,i);
                    error_occ=1;
                    return;
                end

                strPorts.Inport{i}=coder.internal.SampleTimeChecks.LocalGetSampleTimeFromDstIfConstant(strPorts.Inport{i},portH.Inport(i));
            else
                if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.Inport{i})
                    mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                    [],thisHdl);
                    error_occ=1;
                    return;
                end
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetInportSignals',exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfOutports
            outPortH=coder.internal.slBus('LocalGetBlockForPortPrm',...
            portH.Outport(i),'PortHandles');
            [strPorts.Outport{i},thisHdl]=thisHdl.getbus(outPortH.Inport);
            if strPorts.Outport{i}.type==1
                if coder.internal.SampleTimeChecks.LocalHasMixedSampleTimeSrc(outPortH.Inport)

                    if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'OutputPortMixedSampleTime',...
                        [],thisHdl,thisHdl.Systems,i);
                        error_occ=1;
                        return;
                    end
                end
            else
                if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.Outport{i})
                    if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                        [],thisHdl);
                        error_occ=1;
                        return;
                    end
                end
            end
            if isfield(strPorts.Outport{i},'prm')
                strPorts.Outport{i}.prm.CompiledPortDimensions=get_param(...
                portH.Outport(i),'CompiledPortDimensions');
                strPorts.Outport{i}.prm.SymbolicDimensions=coder.internal.Utilities.getCompiledSymbolicDims(portH.Outport(i));
                strPorts.Outport{i}.prm.CompiledPortDimensionsMode=get_param(...
                portH.Outport(i),'CompiledPortDimensionsMode');
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetOutportSignals',exc,thisHdl);
        error_occ=1;
        return;
    end




    try
        for i=1:strPorts.numOfEnablePorts
            [strPorts.Enable{i},thisHdl]=thisHdl.getbus(portH.Enable(i));
            if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.Enable{i})
                if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                    mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                    [],thisHdl);
                    error_occ=1;
                    return;
                end
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetEnableSignals',exc,thisHdl);
        error_occ=1;
        return;
    end





    try
        for i=1:strPorts.numOfTriggerPorts
            [strPorts.Trigger{i},thisHdl]=thisHdl.getbus(portH.Trigger(i));
            if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.Trigger{i})
                if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                    mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                    [],thisHdl);
                    error_occ=1;
                    return;
                end
            end
            portDT=get_param(portH.Trigger(i),'CompiledPortDataType');
            if strcmp(portDT,'fcn_call')&&~thisHdl.ss2mdlForSLDV



                if~thisHdl.exportFcns
                    if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'TriggerSignalIsFcnCall',...
                        [],thisHdl);
                        error_occ=1;
                        return;
                    end
                end
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetTriggerSignals',exc,thisHdl);
        error_occ=1;
        return;
    end





    try
        for i=1:strPorts.numOfStateEnablePorts
            [strPorts.StateEnable{i},thisHdl]=thisHdl.getbus(portH.StateEnable(i));
            if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.StateEnable{i})
                if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                    mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                    [],thisHdl);
                    error_occ=1;
                    return;
                end
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetStateEnableSignals',exc,thisHdl);
        error_occ=1;
        return;
    end





    try
        for i=1:strPorts.numOfResetPorts
            [strPorts.Reset{i},thisHdl]=thisHdl.getbus(portH.Reset(i));
            if coder.internal.Utilities.LocalCheckBusStruct(origMdlHdl,strPorts.Reset{i})
                if~(thisHdl.exportFcns||slfeature('RightClickBuild'))
                    mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'SignalLabelsElementNames',...
                    [],thisHdl);
                    error_occ=1;
                    return;
                end
            end
        end
    catch exc
        mExc=coder.internal.ss2mdlErrorExit(origMdlHdl,-1,'GetResetSignals',exc,thisHdl);
        error_occ=1;
        return;
    end
end
