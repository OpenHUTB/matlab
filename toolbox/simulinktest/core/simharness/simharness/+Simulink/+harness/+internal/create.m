function harnessInfo=create(harnessOwner,createForLoad,checkoutLicense,varargin)





    try


        [harnessInfo.model,harnessInfo.ownerHandle]=Simulink.harness.internal.parseForSystemModel(harnessOwner);

        if Simulink.harness.isHarnessBD(harnessInfo.model)
            DAStudio.error('Simulink:Harness:HarnessCannotBeCreatedForAHarnessMdl');
        end


        if strcmp(get_param(harnessInfo.model,'isObserverBD'),'on')
            DAStudio.error('Simulink:Harness:HarnessCannotBeCreatedForAnObserverMdl');
        end


        if Simulink.harness.internal.isMathWorksLibrary(get_param(harnessInfo.model,'Handle'))
            DAStudio.error('Simulink:Harness:HarnessCannotBeCreatedForAMWLib');
        end


        if bdIsLibrary(harnessInfo.model)&&strcmp('on',get_param(harnessInfo.model,'Lock'))
            DAStudio.error('Simulink:Harness:CannotCreateHarnessWhenLibIsLocked',harnessInfo.model);
        end

        [harnessInfo.ownerType,harnessInfo.ownerFullPath]=Simulink.harness.internal.validateOwnerHandle(harnessInfo.model,harnessInfo.ownerHandle);
        ownerUDD=get_param(harnessInfo.ownerHandle,'Object');
        isLinked=false;
        if isa(ownerUDD,'Simulink.ModelReference')||isa(ownerUDD,'Simulink.SubSystem')||...
            Simulink.harness.internal.isUserDefinedFcnBlock(harnessInfo.ownerHandle)
            isLinked=strcmp(get_param(harnessInfo.ownerHandle,'LinkStatus'),'resolved')||...
            strcmp(get_param(harnessInfo.ownerHandle,'LinkStatus'),'inactive');
        end

        cm=DAStudio.CustomizationManager;
        harnessCustomizationsEnabled=slfeature('SLT_HarnessCustomizationRegistration')>0;
        harnessCustomizationsEnabled=harnessCustomizationsEnabled&&...
        isprop(cm,'SimulinkTestCustomizer');


        isLibHarness=bdIsLibrary(harnessInfo.model);
        isSSMdlHarness=bdIsSubsystem(harnessInfo.model);

        harnessInfo.createFromDialog=Simulink.harness.internal.CreateFromDialogFlag();
        allowMultiplePostCreateCB=slfeature('MultiplePostCreateCallbacks')>0;


        harnessInfo=Simulink.harness.internal.generateHarnessCreateDefaults(...
        harnessInfo,cm,harnessCustomizationsEnabled);

        harnessInfo.param.existingBuildFolder='';

        harnessInfo.param.driveFcnCallWithTS=true;
        harnessInfoFile=...
        Simulink.harness.internal.getHarnessInfoFileName(harnessInfo.model);
        harnessInfoFileExists=(exist(harnessInfoFile,'file')==2);
        isInSLDVExtractMode=slsvTestingHook('UnifiedHarnessBackendMode')>0;



        harnessInfo.param.usedSignalsOnly=false;
        existingBuildFolder=harnessInfo.param.existingBuildFolder;



        schedulerOptions={'None','Test Sequence','MATLAB Function','Schedule Editor'};

        if slfeature('UseStateflowHarnessInput')>0
            schedulerOptions{end+1}='Chart';
        end

        import Simulink.harness.internal.TestHarnessSourceTypes;
        import Simulink.harness.internal.TestHarnessSinkTypes;


        if bdIsLibrary(harnessInfo.model)

            if strcmp(harnessInfo.ownerFullPath,harnessInfo.model)
                DAStudio.error('Simulink:Harness:HarnessCannotBeCreatedForALibraryMdl');
            end
        end



        if Simulink.internal.isArchitectureModel(harnessInfo.model,'AUTOSARArchitecture')&&...
            slInternal('isSubsystem',harnessInfo.ownerHandle)
            serviceComp=autosar.bsw.ServiceComponent.find(harnessInfo.ownerHandle);
            if~isempty(serviceComp)
                DAStudio.error('Simulink:Harness:ServiceComponentsNotAllowedInCompositionBlock',...
                getfullname(harnessInfo.ownerHandle));
            end
        end

        harnessInfo.param.functionInterfaceName='';


        harnessInfo.param.UsedSignalsCell={};

        harnessInfo.param.SLDVCompatible=false;

        synchronizationModes={'SyncOnOpenAndClose','SyncOnOpen','SyncOnPushRebuildOnly'};
        verificationModes={'Normal','SIL','PIL'};


        if nargin>3||...
            (harnessCustomizationsEnabled&&...
            ~isempty(cm.SimulinkTestCustomizer.createHarnessDefaultsObj.userDefinedProps))
            testingSources=Simulink.harness.internal.getTestingSourcesList;
            testingSinks=Simulink.harness.internal.getTestingSinksList;


            p=inputParser;
            p.CaseSensitive=0;
            p.KeepUnmatched=0;
            p.PartialMatching=0;
            p.addParameter('Name',harnessInfo.name,@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addParameter('Description',harnessInfo.description,@(x)validateattributes(x,{'char'},{'real'}));
            p.addParameter('PostCreateCallBack',harnessInfo.param.postCreateCallBack,@(x)validateattributes(x,{'char','cell'},{'real'}));
            p.addParameter('PostRebuildCallBack',harnessInfo.param.postRebuildCallBack,@(x)validateattributes(x,{'char'},{'real'}));
            p.addParameter('Source','Inport',@(x)validateFcn(x,testingSources));
            p.addParameter('Sink','Outport',@(x)validateFcn(x,testingSinks));
            p.addParameter('SeparateAssessment',false,@islogical);
            p.addParameter('CreateWithoutCompile',harnessInfo.param.createGraphicalHarness,...
            @(x)validateattributes(x,{'logical'},{'nonempty'}));
            p.addParameter('CreateFromDialog',harnessInfo.createFromDialog,...
            @(x)validateattributes(x,{'logical'},{'nonempty'}));
            p.addParameter('VerificationMode','Normal',@(x)validateFcn(x,verificationModes));
            p.addParameter('ExistingBuildFolder',existingBuildFolder,@(x)validateattributes(x,{'char'},{'real'}));
            p.addParameter('CustomSourcePath',harnessInfo.param.customSourcePath,@(x)validateattributes(x,{'char'},{'real'}));
            p.addParameter('CustomSinkPath',harnessInfo.param.customSinkPath,@(x)validateattributes(x,{'char'},{'real'}));
            p.addParameter('SaveExternally',harnessInfo.param.saveExternally,...
            @(x)validateattributes(x,{'logical'},{'nonempty'}));
            p.addParameter('RebuildOnOpen',harnessInfo.param.rebuildOnOpen,@(x)validateattributes(x,{'logical'},{'nonempty'}));
            p.addParameter('RebuildModelData',harnessInfo.param.rebuildModelData,@(x)validateattributes(x,{'logical'},{'nonempty'}));

            p.addParameter('DriveFcnCallWithTestSequence',harnessInfo.param.driveFcnCallWithTS,@islogical);
            p.addParameter('SchedulerBlock',harnessInfo.param.schedulerBlock,@(x)validateFcn(x,schedulerOptions));
            p.addParameter('ScheduleInitTermReset',harnessInfo.param.scheduleInitTermReset,@islogical);
            p.addParameter('AutoShapeInputs',harnessInfo.param.autoShapeInputs,@islogical);
            p.addParameter('HarnessPath',harnessInfo.param.fileName,@(x)validateattributes(x,{'char'},{'real'}));
            p.addParameter('UsedSignalsOnly',harnessInfo.param.usedSignalsOnly,@islogical);
            p.addParameter('SynchronizationMode',harnessInfo.param.synchronizationMode,@(x)any(validatestring(x,synchronizationModes)));

            p.addParameter('UsedSignalsCell',harnessInfo.param.UsedSignalsCell,@iscell);
            p.addParameter('FunctionInterfaceName',harnessInfo.param.functionInterfaceName,@(x)validateattributes(x,{'char'},{'real'}));

            p.addParameter('LogHarnessOutputs',...
            harnessInfo.param.logHarnessOutputs,@(x)validateattributes(x,{'logical'},{'scalar'}));
            p.addParameter('LogOutputs',...
            harnessInfo.param.logHarnessOutputs,@(x)validateattributes(x,{'logical'},{'scalar'}));

            p.addParameter('SLDVCompatible',harnessInfo.param.SLDVCompatible,@islogical);

            p.parse(varargin{:});


            Simulink.harness.internal.ensureNoRepeatedParams(varargin)


            harnessInfo.description=p.Results.Description;



            if harnessCustomizationsEnabled
                harnessInfo.param.postCreateCallBack=...
                string(cm.SimulinkTestCustomizer.createHarnessDefaultsObj.PostCreateCallback).strip;
            end

            if iscell(p.Results.PostCreateCallBack)&&...
                ~(iscellstr(p.Results.PostCreateCallBack)||...
                all(cellfun(@isstring,p.Results.PostCreateCallBack)))


                DAStudio.error('Simulink:Harness:InvalidPostCreateCallbackError');

            elseif allowMultiplePostCreateCB





                tempCBStr=string(p.Results.PostCreateCallBack).split(',').strip;
                harnessInfo.param.postCreateCallBack=...
                [harnessInfo.param.postCreateCallBack(:);tempCBStr(:)];

            else
                harnessInfo.param.postCreateCallBack=...
                [harnessInfo.param.postCreateCallBack(:);string(p.Results.PostCreateCallBack(:))];
            end



            harnessInfo.param.postCreateCallBack=...
            harnessInfo.param.postCreateCallBack(harnessInfo.param.postCreateCallBack~="");


            harnessInfo.param.postRebuildCallBack=p.Results.PostRebuildCallBack;
            harnessInfo.param.createGraphicalHarness=p.Results.CreateWithoutCompile;
            harnessInfo.param.createFromDialog=p.Results.CreateFromDialog;
            if~ismember('VerificationMode',p.UsingDefaults)
                harnessInfo.param.verificationMode=p.Results.VerificationMode;
            end


            if ischar(harnessInfo.param.verificationMode)||isstring(harnessInfo.param.verificationMode)
                harnessInfo.param.verificationMode=...
                find(strcmpi(verificationModes,harnessInfo.param.verificationMode))-1;
            end

            harnessInfo.param.customSourcePath=strtrim(p.Results.CustomSourcePath);
            harnessInfo.param.customSinkPath=strtrim(p.Results.CustomSinkPath);






            harnessInfo.param.saveExternally=p.Results.SaveExternally;
            if~any(contains(p.UsingDefaults,'SaveExternally'))&&~harnessInfo.param.saveExternally&&...
                ~any(contains(p.UsingDefaults,'HarnessPath'))&&p.Results.HarnessPath~=""
                MSLDiagnostic('Simulink:Harness:EmbHarnessModelNotConfigWarning').reportAsWarning;
            else
                harnessInfo.param.fileName=p.Results.HarnessPath;
            end

            if~ismember('RebuildOnOpen',p.UsingDefaults)
                harnessInfo.param.rebuildOnOpen=p.Results.RebuildOnOpen;
            end
            harnessInfo.param.rebuildModelData=p.Results.RebuildModelData;
            harnessInfo.param.usedSignalsOnly=p.Results.UsedSignalsOnly;
            harnessInfo.param.synchronizationMode=p.Results.SynchronizationMode;
            harnessInfo.param.UsedSignalsCell=p.Results.UsedSignalsCell;
            harnessInfo.param.SLDVCompatible=p.Results.SLDVCompatible;

            existingBuildFolder=p.Results.ExistingBuildFolder;
            harnessInfo.param.functionInterfaceName=p.Results.FunctionInterfaceName;












            if slfeature('HarnessOutputSignalLogging')>0
                logHarnessOutputsSpecified=~ismember('LogHarnessOutputs',p.UsingDefaults);
                logOutputsSpecified=~ismember('LogOutputs',p.UsingDefaults);

                if logOutputsSpecified&&~logHarnessOutputsSpecified



                    harnessInfo.param.logHarnessOutputs=p.Results.LogOutputs;
                elseif~logOutputsSpecified&&logHarnessOutputsSpecified
                    MSLDiagnostic('Simulink:Harness:UsingLogHarnessOutputs').reportAsWarning;
                    harnessInfo.param.logHarnessOutputs=p.Results.LogHarnessOutputs;
                elseif logOutputsSpecified&&logHarnessOutputsSpecified
                    MSLDiagnostic('Simulink:Harness:TwoLoggingParamsSpecified').reportAsWarning;
                    harnessInfo.param.logHarnessOutputs=p.Results.LogOutputs;
                else

                    harnessInfo.param.logHarnessOutputs=p.Results.LogOutputs;
                end
            end

            if(~isempty(existingBuildFolder))
                if(isa(ownerUDD,'Simulink.ModelReference')||isa(ownerUDD,'Simulink.BlockDiagram'))
                    DAStudio.error('Simulink:Harness:BuildFolderPathForModelError');
                end
                if(~isfolder(existingBuildFolder))
                    DAStudio.error('Simulink:Harness:ExistingBuildFolderError')
                end
                if(harnessInfo.param.verificationMode==0)
                    MSLDiagnostic('Simulink:Harness:NormalHarnessBuildFolderWarning').reportAsWarning;
                    existingBuildFolder='';
                end
                harnessInfo.param.existingBuildFolder=existingBuildFolder;
            end






            hasHarnesses=~isempty(Simulink.harness.find(harnessInfo.model));
            hasCodeContexts=false;
            if bdIsLibrary(harnessInfo.model)
                codeContexts=Simulink.libcodegen.internal.getAllCodeContexts(harnessInfo.model);
                hasCodeContexts=~isempty(codeContexts);
            end
            if~harnessInfo.param.saveExternally&&harnessInfoFileExists
                MSLDiagnostic('Simulink:Harness:EmbHarnessModelNotConfigWarning',...
                harnessInfo.name,harnessInfo.model).reportAsWarning;
                harnessInfo.param.saveExternally=true;
            elseif(harnessInfo.param.saveExternally||...
                ~isempty(harnessInfo.param.fileName))&&...
                ~harnessInfoFileExists&&...
                (hasHarnesses||hasCodeContexts)
                MSLDiagnostic('Simulink:Harness:IndHarnessModelNotConfigWarning',...
                harnessInfo.name,harnessInfo.model).reportAsWarning;
                harnessInfo.param.saveExternally=false;
            elseif harnessInfoFileExists||...
                (~hasHarnesses&&...
                ~isempty(harnessInfo.param.fileName))
                harnessInfo.param.saveExternally=true;
            end


            if~ismember('Source',p.UsingDefaults)
                harnessInfo.param.source=p.Results.Source;
            end



            if harnessInfo.param.source=="Signal Builder"...
                &&~harnessInfo.param.SLDVCompatible
                validSources=Simulink.harness.internal.getTestingSourcesList(...
                "IncludeSigBuilder",false);
                validateFcn(harnessInfo.param.source,validSources);
            end

            if strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name)&&~license('test','Stateflow')
                DAStudio.error('Simulink:Harness:ChartSourceNeedsStateflow');
            end
            if strcmpi(p.Results.Source,TestHarnessSourceTypes.REACTIVE_TEST.name)
                if~ismember('Sink',p.UsingDefaults)&&...
                    ~strcmpi(p.Results.Sink,TestHarnessSinkTypes.REACTIVE_TEST.name)
                    Simulink.harness.internal.warn('Simulink:Harness:InvalidSinkForReactiveTest');
                end
                harnessInfo.param.sink=TestHarnessSinkTypes.REACTIVE_TEST.name;
            elseif strcmpi(p.Results.Source,TestHarnessSourceTypes.STATEFLOW.name)
                if~ismember('Sink',p.UsingDefaults)&&...
                    ~strcmpi(p.Results.Sink,TestHarnessSinkTypes.STATEFLOW.name)
                    Simulink.harness.internal.warn('Simulink:Harness:InvalidSinkForStateflowChart');
                end
                harnessInfo.param.sink=TestHarnessSinkTypes.STATEFLOW.name;
            elseif~ismember('Sink',p.UsingDefaults)
                harnessInfo.param.sink=p.Results.Sink;
            end


            sourceIdx=find(strcmpi(testingSources,harnessInfo.param.source));
            harnessInfo.param.source=testingSources{sourceIdx};%#ok
            sinkIdx=find(strcmpi(testingSinks,harnessInfo.param.sink));
            harnessInfo.param.sink=testingSinks{sinkIdx};%#ok

            if~ismember('SeparateAssessment',p.UsingDefaults)
                harnessInfo.param.separateAssessment=p.Results.SeparateAssessment;
            end
            harnessInfo.param.driveFcnCallWithTS=p.Results.DriveFcnCallWithTestSequence;


            if harnessInfo.param.separateAssessment==true&&...
                isa(ownerUDD,'Simulink.BlockDiagram')
                blks=find_system(harnessInfo.model,'SearchDepth',1,'BlockType','AsynchronousTaskSpecification');
                if~isempty(blks)


                    Simulink.harness.internal.warn('Simulink:Harness:InvalidSeparateAssessmentJMAAB_B');
                    harnessInfo.param.separateAssessment=false;
                end
            end

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')
                if~ismember('SchedulerBlock',p.UsingDefaults)||...
                    (harnessCustomizationsEnabled&&...
                    any(strcmpi("SchedulerBlock",cm.SimulinkTestCustomizer.createHarnessDefaultsObj.userDefinedProps)))
                    if strcmpi(p.Results.SchedulerBlock,'Chart')&&~license('test','Stateflow')
                        DAStudio.error('Simulink:Harness:ChartSourceNeedsStateflow');
                    end
                    harnessInfo.param.schedulerBlock=p.Results.SchedulerBlock;
                else
                    if((isa(ownerUDD,'Simulink.BlockDiagram')&&strcmpi(get_param(ownerUDD.Handle,'IsExportFunctionModel'),'on'))||...
                        (isa(ownerUDD,'Simulink.ModelReference')&&strcmpi(get_param(ownerUDD.Handle,'IsModelRefExportFunction'),'on')))
                        if strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name)&&slfeature('UseStateflowHarnessInput')>0
                            harnessInfo.param.schedulerBlock='Chart';
                        else
                            harnessInfo.param.schedulerBlock=schedulerOptions{2};
                        end
                    elseif isa(ownerUDD,'Simulink.SubSystem')||Simulink.harness.internal.isUserDefinedFcnBlock(harnessInfo.ownerHandle)
                        harnessInfo.param.schedulerBlock=schedulerOptions{2};
                    elseif isa(ownerUDD,'Simulink.ModelReference')&&...
                        strcmpi(get_param(ownerUDD.Handle,'ShowModelPeriodicEventPorts'),'on')
                        if strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name)&&slfeature('UseStateflowHarnessInput')>0
                            harnessInfo.param.schedulerBlock='Chart';
                        else
                            harnessInfo.param.schedulerBlock=schedulerOptions{2};
                        end
                    end
                end
            end


            if strcmp(harnessInfo.param.schedulerBlock,'Schedule Editor')
                if~isa(ownerUDD,'Simulink.BlockDiagram')
                    DAStudio.error('Simulink:Harness:ScheduleEditorNotSupported');
                elseif isa(ownerUDD,'Simulink.BlockDiagram')&&...
                    strcmpi(get_param(harnessInfo.model,'SolverType'),'Variable-step')
                    DAStudio.error('Simulink:Harness:CannotCreateWhen_SolverType_Variable');
                elseif isa(ownerUDD,'Simulink.BlockDiagram')&&...
                    strcmpi(get_param(harnessInfo.model,'IsExportFunctionModel'),'off')&&...
                    strcmpi(get_param(harnessInfo.model,'EnableMultiTasking'),'off')
                    DAStudio.error('Simulink:Harness:CannotCreateWhen_EnableMultiTasking_Off');
                end
            end

            harnessInfo.param.scheduleInitTermReset=p.Results.ScheduleInitTermReset;

            if harnessInfo.param.scheduleInitTermReset
                if isa(ownerUDD,'Simulink.SubSystem')||...
                    isa(ownerUDD,'Simulink.ModelReference')||...
                    (isa(ownerUDD,'Simulink.BlockDiagram')&&bdIsSubsystem(ownerUDD.handle))||...
                    Simulink.harness.internal.isUserDefinedFcnBlock(harnessInfo.ownerHandle)

                    if~harnessInfo.param.createFromDialog
                        Simulink.harness.internal.warn('Simulink:Harness:InvalidScheduleInitTermResetOption');
                    end
                    harnessInfo.param.scheduleInitTermReset=false;
                end
            end

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')>0





                if isa(ownerUDD,'Simulink.ModelReference')
                    if strcmp(get_param(ownerUDD.handle,'ShowModelPeriodicEventPorts'),'on')&&...
                        strcmp(get_param(ownerUDD.handle,'IsModelRefExportFunction'),'off')
                        if~strcmp(harnessInfo.param.schedulerBlock,schedulerOptions{1})
                            origTHVal=slsvTestingHook('AllowToSpecifyPortDiscreteRateWithOffset',1);
                            cleanupTH=onCleanup(@()slsvTestingHook('AllowToSpecifyPortDiscreteRateWithOffset',origTHVal));
                        end
                    elseif~strcmp(harnessInfo.param.schedulerBlock,schedulerOptions{1})&&...
                        strcmp(get_param(ownerUDD.handle,'IsModelRefExportFunction'),'off')
                        harnessInfo.param.schedulerBlock=schedulerOptions{1};
                        Simulink.harness.internal.warn('Simulink:Harness:InvalidCreateUnifiedSchedulerOptionForMR');
                    end
                end
            end

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')<=0
                if harnessInfo.param.scheduleInitTermReset&&...
                    strcmpi(get_param(harnessInfo.model,'IsExportFunctionModel'),'off')

                    Simulink.harness.internal.warn('Simulink:Harness:InvalidScheduleInitTermResetOption');
                    harnessInfo.param.scheduleInitTermReset=false;
                end
            end



            if strcmp(harnessInfo.param.schedulerBlock,schedulerOptions{1})&&...
                strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.REACTIVE_TEST.name)&&...
                ~isa(ownerUDD,'Simulink.BlockDiagram')&&...
                ~isa(ownerUDD,'Simulink.ModelReference')
                harnessInfo.param.schedulerBlock=schedulerOptions{2};
            end

            if slfeature('UseStateflowHarnessInput')>0
                if strcmp(harnessInfo.param.schedulerBlock,schedulerOptions{1})&&...
                    strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name)&&...
                    ~isa(ownerUDD,'Simulink.BlockDiagram')&&...
                    ~isa(ownerUDD,'Simulink.ModelReference')
                    harnessInfo.param.schedulerBlock='Chart';
                end
            end

            harnessInfo.param.schedulerBlock=find(strcmpi(schedulerOptions,harnessInfo.param.schedulerBlock))-1;
            if~ismember('DriveFcnCallWithTestSequence',p.UsingDefaults)&&...
                ismember('SchedulerBlock',p.UsingDefaults)&&...
                slfeature('CreateSchedulerForBdAndMdlRefHarness')&&...
                ~harnessInfo.param.createFromDialog

                if harnessInfo.param.driveFcnCallWithTS
                    harnessInfo.param.schedulerBlock=1;
                else
                    harnessInfo.param.schedulerBlock=0;
                end
            end




            harnessInfo.param.autoShapeInputs=p.Results.AutoShapeInputs;
            isAutoShapeInputsUserSpecified=~ismember('AutoShapeInputs',p.UsingDefaults)||...
            (harnessCustomizationsEnabled&&...
            any(strcmpi("AutoShapeInputs",cm.SimulinkTestCustomizer.createHarnessDefaultsObj.userDefinedProps)));
            if strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.SIGNAL_BUILDER.name)





                if isAutoShapeInputsUserSpecified&&...
                    ~harnessInfo.param.autoShapeInputs
                    MSLDiagnostic('Simulink:Harness:InvalidAutoShapeInputsOption2').reportAsWarning;
                end
                harnessInfo.param.autoShapeInputs=true;
            elseif strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.REACTIVE_TEST.name)||...
                strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name)
                if isAutoShapeInputsUserSpecified&&...
                    harnessInfo.param.autoShapeInputs
                    MSLDiagnostic('Simulink:Harness:InvalidAutoShapeInputsOption2').reportAsWarning;
                end
                harnessInfo.param.autoShapeInputs=false;
            elseif strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&...
                ~strcmpi(p.Results.CustomSourcePath,'built-in/Constant')&&...
                ~strcmpi(p.Results.CustomSourcePath,'simulink/Sources/Constant')&&...
                ~strcmpi(p.Results.CustomSourcePath,'built-in/FromFile')&&...
                ~strcmpi(p.Results.CustomSourcePath,'simulink/Sources/From File')&&...
                ~strcmpi(p.Results.CustomSourcePath,'built-in/FromWorkspace')&&...
                ~strcmpi(p.Results.CustomSourcePath,'simulink/Sources/From Workspace')
                if isAutoShapeInputsUserSpecified&&harnessInfo.param.autoShapeInputs
                    MSLDiagnostic('Simulink:Harness:InvalidAutoShapeInputsOption2').reportAsWarning;
                end
                harnessInfo.param.autoShapeInputs=false;
            end

            if harnessInfo.param.autoShapeInputs&&...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.INPORT.name)&&...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.SIGNAL_BUILDER.name)&&...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CONSTANT.name)&&...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.FROM_WORKSPACE.name)&&...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.FROM_FILE.name)&&...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CONSTANT.name)&&...
                ~(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&strcmpi(p.Results.CustomSourcePath,'built-in/Constant'))&&...
                ~(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&strcmpi(p.Results.CustomSourcePath,'simulink/Sources/Constant'))&&...
                ~(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&strcmpi(p.Results.CustomSourcePath,'built-in/FromFile'))&&...
                ~(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&strcmpi(p.Results.CustomSourcePath,'simulink/Sources/From File'))&&...
                ~(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&strcmpi(p.Results.CustomSourcePath,'built-in/FromWorkspace'))&&...
                ~(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)&&strcmpi(p.Results.CustomSourcePath,'simulink/Sources/From Workspace'))

                Simulink.harness.internal.warn('Simulink:Harness:InvalidAutoShapeInputsOption');
                harnessInfo.param.autoShapeInputs=false;
            end

            if any(ismember(p.UsingDefaults,'Source'))&&...
                any(ismember(p.UsingDefaults,'AutoShapeInputs'))&&...
                (harnessInfo.param.usedSignalsOnly||~isempty(harnessInfo.param.UsedSignalsCell))
                harnessInfo.param.source=TestHarnessSourceTypes.SIGNAL_BUILDER.name;
                harnessInfo.param.autoShapeInputs=true;
            end


            Simulink.harness.internal.sfcheck(harnessInfo.ownerHandle);

            if(isLibHarness||isSSMdlHarness)&&harnessInfo.param.verificationMode~=0

                Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','VerificationMode','Normal'});
                harnessInfo.param.verificationMode=0;
            end

            if harnessInfo.param.verificationMode~=0&&Simulink.harness.internal.isUserDefinedFcnBlock(harnessInfo.ownerHandle)


                Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForUserDefFcn','VerificationMode','Normal'});
                harnessInfo.param.verificationMode=0;
            end

            if harnessInfo.param.verificationMode~=0&&...
                Simulink.harness.internal.isSimulinkFunctionBlockForHarnessCreation(harnessInfo.ownerHandle)

                DAStudio.error('Simulink:Harness:SILPILNotSupportedForSimulinkFunctionSubsystem');
            end

            if harnessInfo.param.verificationMode==1||harnessInfo.param.verificationMode==2
                if~license('test','RTW_Embedded_Coder')
                    DAStudio.error('Simulink:Harness:SILPILNeedsERT');
                end
                if isa(ownerUDD,'Simulink.SubSystem')&&...
                    harnessInfo.param.createGraphicalHarness
                    Simulink.harness.internal.warn('Simulink:Harness:InvalidCreateGraphicalForSILPIL');
                    harnessInfo.param.createGraphicalHarness=false;
                end
                if strcmp(get_param(harnessInfo.model,'InitializeInteractiveRuns'),'on')
                    DAStudio.error('Simulink:Harness:SILPILNotSupportedForFastRestart');
                end
            end

            harnessInfo.name=p.Results.Name;


            Simulink.harness.internal.validateHarnessName(harnessInfo.model,harnessInfo.ownerFullPath,harnessInfo.name);


            if strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.CUSTOM.name)
                Simulink.harness.internal.validateLibraryPath(harnessInfo.param.customSourcePath,'source');
            elseif~isempty(harnessInfo.param.customSourcePath)
                DAStudio.error('Simulink:Harness:CustomSrcPathSpecifiedForBuiltInSrc');
            end

            if(~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.REACTIVE_TEST.name)||...
                ~strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name))&&...
                strcmpi(harnessInfo.param.sink,TestHarnessSinkTypes.CUSTOM.name)
                Simulink.harness.internal.validateLibraryPath(harnessInfo.param.customSinkPath,'sink');
            end

            if~strcmpi(harnessInfo.param.sink,TestHarnessSinkTypes.CUSTOM.name)&&...
                ~(harnessInfo.param.customSinkPath=="")
                DAStudio.error('Simulink:Harness:CustomSinkPathSpecifiedForBuiltInSink');
            end



            if~harnessInfo.param.driveFcnCallWithTS&&...
                strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.REACTIVE_TEST.name)
                Simulink.harness.internal.warn('Simulink:Harness:IgnoringDriveFcnCallWithTestSequence');
            end

            if~harnessInfo.param.driveFcnCallWithTS&&...
                strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.STATEFLOW.name)
                Simulink.harness.internal.warn('Simulink:Harness:IgnoringDriveFcnCallWithTestSequence');
            end


            if harnessInfo.param.saveExternally
                if isempty(harnessInfo.param.fileName)
                    harnessInfo.param.fileName=fullfile(pwd,[harnessInfo.name,'.slx']);
                elseif isdir(harnessInfo.param.fileName)
                    harnessInfo.param.fileName=fullfile(harnessInfo.param.fileName,[harnessInfo.name,'.slx']);
                elseif any(ismember(p.UsingDefaults,'Name'))


                    [~,harnessFileName,~]=fileparts(harnessInfo.param.fileName);
                    harnessInfo.name=harnessFileName;

                    Simulink.harness.internal.validateHarnessName(harnessInfo.model,...
                    harnessInfo.ownerFullPath,harnessInfo.name);
                end


                [filePath,harnessFileName,ext]=fileparts(harnessInfo.param.fileName);
                if isempty(filePath)
                    harnessInfo.param.fileName=fullfile(pwd,[harnessFileName,'.slx']);
                end

                if~isempty(ext)&&~strcmp(ext,'.slx')&&~strcmp(ext,'.mdl')
                    DAStudio.error('Simulink:LoadSave:InvalidFileNameExtension',harnessInfo.param.fileName);
                end

                if~strcmp(harnessFileName,harnessInfo.name)
                    DAStudio.error('Simulink:Harness:ExternalHarnessFileNameMustMatchHarnessName',...
                    harnessInfo.param.fileName,harnessInfo.name);
                end

                [filePath,~,~]=fileparts(harnessInfo.param.fileName);
                if exist(filePath,'dir')~=7
                    DAStudio.error('Simulink:Harness:ExternalHarnessDirectoryMissing',...
                    filePath);
                end

                if exist(harnessInfo.param.fileName,'file')&&~createForLoad
                    DAStudio.error('Simulink:Harness:IndHarnessFileExists',harnessInfo.name,...
                    harnessInfo.param.fileName);
                end

                modelFileName=get_param(harnessInfo.model,'FileName');
                if isempty(modelFileName)||strcmp(get_param(harnessInfo.model,'Dirty'),'on')
                    DAStudio.error('Simulink:Harness:IndHarnessModelMustBeSaved');
                end
                [~,message,~]=fileattrib(filePath);
                if~message.UserWrite
                    DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',harnessInfo.name,filePath);
                end
                hInfoFile=Simulink.harness.internal.getHarnessInfoFileName(harnessInfo.model);
                if exist(hInfoFile,'file')
                    [path,~,~]=fileparts(hInfoFile);
                    [~,message,~]=fileattrib(path);
                    if~message.UserWrite
                        DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',harnessInfo.name,path);
                    end

                    [~,message,~]=fileattrib(hInfoFile);
                    if~message.UserWrite
                        DAStudio.error('Simulink:Harness:IndependentHarnessOperationFailed','create');
                    end
                else

                    [path,~,~]=fileparts(modelFileName);
                    [~,message,~]=fileattrib(path);
                    if~message.UserWrite
                        DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',harnessInfo.name,path);
                    end
                end

                Simulink.harness.internal.setSavedIndependently(harnessInfo.model,true);

            else
                Simulink.harness.internal.setSavedIndependently(harnessInfo.model,false);
                harnessInfo.param.fileName='';
            end


            if isLibHarness||isSSMdlHarness

                if~harnessInfo.param.createGraphicalHarness
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','CreateWithoutCompile','true'});
                    harnessInfo.param.createGraphicalHarness=true;
                end


                if harnessInfo.param.rebuildOnOpen
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','RebuildOnOpen','false'});
                    harnessInfo.param.rebuildOnOpen=false;
                end


                if harnessInfo.param.rebuildModelData
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForLibHarness','RebuildModelData','false'});
                    harnessInfo.param.rebuildModelData=false;
                end


                if harnessInfo.param.postRebuildCallBack~=""
                    Simulink.harness.internal.warn({'Simulink:Harness:InvalidPostRebuildCBForLibHarness'});
                    harnessInfo.param.postRebuildCallBack='';
                end
            end
            Simulink.harness.internal.validatePostRebuildCB(harnessInfo.param.postRebuildCallBack);

        else
            if harnessInfo.param.saveExternally
                harnessInfo.param.fileName=fullfile(pwd,[harnessInfo.name,'.slx']);
                Simulink.harness.internal.setSavedIndependently(harnessInfo.model,true);
            else
                Simulink.harness.internal.setSavedIndependently(harnessInfo.model,false);
            end


            harnessInfo.param.verificationMode=find(strcmpi(verificationModes,harnessInfo.param.verificationMode))-1;
            harnessInfo.param.schedulerBlock=find(strcmpi(schedulerOptions,harnessInfo.param.schedulerBlock))-1;
        end

        isNormalMode=(harnessInfo.param.verificationMode==0);
        if(~exist('p','var')||ismember('SynchronizationMode',p.UsingDefaults))&&...
            ~(harnessCustomizationsEnabled&&...
            any(strcmpi("SynchronizationMode",cm.SimulinkTestCustomizer.createHarnessDefaultsObj.userDefinedProps)))


            if isCreatingForImplicitLink(harnessInfo.ownerHandle)&&isNormalMode
                harnessInfo.param.synchronizationMode=synchronizationModes{2};
            elseif~isNormalMode
                harnessInfo.param.synchronizationMode=synchronizationModes{3};
            elseif isa(ownerUDD,'Simulink.BlockDiagram')||...
                isCreatingForImplicitLink(harnessInfo.ownerHandle)||Simulink.internal.isArchitectureModel(harnessInfo.model)

                harnessInfo.param.synchronizationMode=synchronizationModes{2};
            else

                harnessInfo.param.synchronizationMode=synchronizationModes{1};
            end
        elseif~ismember(lower(harnessInfo.param.synchronizationMode),lower(synchronizationModes))
            DAStudio.error('Simulink:Harness:InvalidSyncModeArg',harnessInfo.param.synchronizationMode);
        elseif bdIsLibrary(harnessInfo.model)&&strcmpi(harnessInfo.param.synchronizationMode,synchronizationModes{3})
            if isCreatingForImplicitLink(harnessInfo.ownerHandle)
                Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForImplicitLink','SynchronizationMode','SyncOnOpen'});
                harnessInfo.param.synchronizationMode=synchronizationModes{2};
            else
                Simulink.harness.internal.warn('Simulink:Harness:InvalidSyncModeForLibrary');
                harnessInfo.param.synchronizationMode=synchronizationModes{1};
            end
        elseif~isNormalMode&&~strcmpi(harnessInfo.param.synchronizationMode,synchronizationModes{3})
            Simulink.harness.internal.warn('Simulink:Harness:InvalidSyncModeForSILPIL');
            harnessInfo.param.synchronizationMode=synchronizationModes{3};
        elseif isNormalMode&&isCreatingForImplicitLink(harnessInfo.ownerHandle)&&~strcmpi(harnessInfo.param.synchronizationMode,synchronizationModes{2})
            Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForImplicitLink','SynchronizationMode','SyncOnOpen'});
            harnessInfo.param.synchronizationMode=synchronizationModes{2};
        elseif isa(ownerUDD,'Simulink.BlockDiagram')&&strcmpi(harnessInfo.param.synchronizationMode,synchronizationModes{1})
            Simulink.harness.internal.warn('Simulink:Harness:InvalidSyncModeForBD');
            harnessInfo.param.synchronizationMode=synchronizationModes{2};
        elseif Simulink.internal.isArchitectureModel(harnessInfo.model)&&~strcmpi(harnessInfo.param.synchronizationMode,synchronizationModes{2})
            Simulink.harness.internal.warn('Simulink:Harness:InvalidSyncModeForZCHarness');
            harnessInfo.param.synchronizationMode=synchronizationModes{2};
        end


        harnessInfo.param.synchronizationMode=find(strcmpi(synchronizationModes,harnessInfo.param.synchronizationMode))-1;

        if harnessInfo.param.SLDVCompatible
            if harnessInfo.param.driveFcnCallWithTS==true
                Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForSLDVCompatHarness','DriveFcnCallWithTestSequence','false'});
                harnessInfo.param.driveFcnCallWithTS=false;
            end

            if(strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.INPORT.name)&&...
                harnessInfo.param.autoShapeInputs==true)
                Simulink.harness.internal.warn({'Simulink:Harness:InvalidParamValueForSLDVCompatHarness','AutoShapeInputs','false'});
                harnessInfo.param.autoShapeInputs=false;
            end

            if harnessInfo.param.schedulerBlock~=0&&~isSchedulerNeeded()




                harnessInfo.param.schedulerBlock=0;
            end

        end

        cleanupUtilLib=onCleanup(@()Simulink.harness.internal.closeUtilLib());

        modelH=get_param(harnessInfo.model,'Handle');
        harnessFileName=get_param(modelH,'FileName');
        [~,~,ext]=fileparts(harnessFileName);
        if strcmp(ext,'.mdl')&&~harnessInfo.param.saveExternally&&...
            ~isInSLDVExtractMode
            DAStudio.error('Simulink:Harness:CreateInMDLFormatNotSupported');
        end

        usedSignals={};
        if isa(ownerUDD,'Simulink.BlockDiagram')&&...
            strcmpi(harnessInfo.param.source,TestHarnessSourceTypes.SIGNAL_BUILDER.name)&&...
            harnessInfo.param.autoShapeInputs&&...
            harnessInfo.param.usedSignalsOnly&&...
            ~harnessInfo.param.createGraphicalHarness&&...
            license('test','Simulink_Design_Verifier')
            try
                harnessOpts=sldvharnessopts;
                harnessOpts.usedSignalsOnly=true;
                sldvData=Sldv.DataUtils.generateDataFromMdl(modelH,harnessOpts.usedSignalsOnly,harnessOpts.modelRefHarness);
                usedSignals={};
                usedSignals=Simulink.harness.internal.populateUsedSignals(sldvData.AnalysisInformation.InputPortInfo,usedSignals);
                usedSignals=usedSignals{:};
            catch me
                me.throwAsCaller;
            end
        elseif harnessInfo.param.usedSignalsOnly
            MSLDiagnostic('Simulink:Harness:UsedSignalsOnlyUnsupportedConfig').reportAsWarning;
        end

        if isempty(usedSignals)
            usedSignals=harnessInfo.param.UsedSignalsCell;
        end

        harnessInfo.param.usedSignalsOnly=usedSignals;

        if~isempty(harnessInfo.param.functionInterfaceName)&&slfeature('RLSTestHarness')>0

            codeContext=Simulink.libcodegen.internal.getCodeContext(harnessInfo.model,harnessInfo.ownerHandle,harnessInfo.param.functionInterfaceName);
            if isempty(codeContext)
                DAStudio.error('Simulink:CodeContext:CodeContextNotFound',harnessInfo.param.functionInterfaceName,harnessInfo.ownerFullPath);
            end

            if~Simulink.harness.internal.isRLS(harnessInfo.ownerHandle)
                DAStudio.error('Simulink:CodeContext:CodeContextInvalidOwnerTypeForHarness',harnessInfo.ownerFullPath);
            end


            prevLoaded=codeContext.isOpen;
            Simulink.libcodegen.internal.loadCodeContext(codeContext.ownerHandle,codeContext.name);
            if strcmp(get_param(codeContext.name,'Dirty'),'on')
                if~prevLoaded
                    close_system(codeContext.name,0);
                    DAStudio.error('Simulink:CodeContext:CodeContextUnsavedChanges',harnessInfo.name,harnessInfo.param.functionInterfaceName);
                end
            end

            tempModel=[tempname,'.slx'];


            Simulink.libcodegen.internal.exportCodeContext(codeContext.ownerHandle,codeContext.name,'Name',tempModel);
            load_system(tempModel);
            [~,tempModelName,~]=fileparts(tempModel);
            oc1=onCleanup(@()close_system(tempModel,0));
            tempHarnessInfo=harnessInfo;
            tempHarnessInfo.model=tempModelName;


            tempCUT=find_system(tempModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SID','1');
            tempHarnessInfo.ownerHandle=get_param(tempCUT{1},'Handle');
            tempHarnessInfo.param.synchronizationMode=1;
            tempHarnessInfo.param.createGraphicalHarness=false;
            newHarness=Simulink.harness.internal.createHarness(tempHarnessInfo.model,tempHarnessInfo,false,true);


            ws=warning('off','Simulink:Harness:HarnessMoved');
            oc2=onCleanup(@()warning(ws.state,'Simulink:Harness:HarnessMoved'));
            Simulink.harness.move(newHarness.ownerFullPath,newHarness.name,'DestinationOwner',harnessInfo.ownerFullPath,'Name',harnessInfo.name);
            Simulink.harness.internal.set(harnessInfo.ownerFullPath,harnessInfo.name,'FunctionInterfaceName',harnessInfo.param.functionInterfaceName);
            Simulink.harness.internal.set(harnessInfo.ownerFullPath,harnessInfo.name,'RebuildWithoutCompile',false);
        else

            Simulink.harness.internal.createHarness(harnessInfo.model,harnessInfo,createForLoad,checkoutLicense);
        end


        Simulink.harness.internal.refreshHarnessListDlg(harnessInfo.model);
    catch ME
        ME.throwAsCaller;
    end

    function r=isCreatingForImplicitLink(ownerHandle)
        r=false;
        if ishandle(ownerHandle)&&strcmp(get_param(ownerHandle,'Type'),'block')
            r=Simulink.harness.internal.isImplicitLink(ownerHandle);
        end
    end

    function validateFcn(input,inputList)
        if~any(strcmpi(input,inputList))
            DAStudio.error('Simulink:Harness:InvalidInputArgumentForHarnessCreation',strjoin(inputList,''', '''),input);
        end
    end

    function needsSchedulerBlk=isSchedulerNeeded()
        ownerObject=get_param(harnessInfo.ownerHandle,'Object');


        if isa(ownerObject,'Simulink.BlockDiagram')
            needsSchedulerBlk=strcmp(get_param(harnessInfo.ownerHandle,'IsExportFunctionModel'),'on');
        elseif ownerObject.isModelReference
            needsSchedulerBlk=strcmp(get_param(harnessInfo.ownerHandle,'IsModelRefExportFunction'),'on');
        else
            ssType=Simulink.SubsystemType(harnessInfo.ownerHandle);
            needsSchedulerBlk=ssType.isFunctionCallSubsystem||ssType.isSimulinkFunction;
        end
    end
end

