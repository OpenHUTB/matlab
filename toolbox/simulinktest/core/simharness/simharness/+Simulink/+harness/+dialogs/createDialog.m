




classdef createDialog<handle

    properties(SetObservable=true)


harnessOwner
harnessName
harnessType
verificationMode
testingSrc
testingSink
separateAssessment
schedulerBlock
        schedulerBlockEntries={'None','Test Sequence','MATLAB Function'};
        schedulerBlockValues=[0,1,2];
enableAutoShapeInputs
harnessDescription
previewImg
activateFlag
customSrcPath
customSinkPath
enableDetailConfigPanel
saveExternally
harnessFilePath
harnessFileName
scheduleInitTermReset
driveFcnCallWithTSBFlag


logHarnessOutputsFlag
postCreateCallBack
defaultPostCreateCallBack
postRebuildCallBack
graphicalHarnessFlag
rebuildOnOpen
rebuildModelData
readonly
harnessCreated
defaultName
harnessTypeEntries
harnessTypeValues
        verificationModeEntries={
        message('Simulink:studio:SimModeNormalToolBar').getString,...
        message('Simulink:studio:SimModeSILToolBar').getString,...
        message('Simulink:studio:SimModePILToolBar').getString};
        verificationModeValues=[0,1,2];
syncComponent
        syncComponentModeEntriesAll={
        message('Simulink:Harness:SyncOptBothWays').getString,...
        message('Simulink:Harness:SyncOptOneWay').getString,...
        message('Simulink:Harness:SyncOptExplicitFull').getString};
        syncComponentModeValuesAll=[0,1,2];
        syncComponentModeEntriesLimited={
        message('Simulink:Harness:SyncOptOneWay').getString,...
        message('Simulink:Harness:SyncOptExplicitOneWay').getString};
        syncComponentModeValuesLimited=[1,2];
        syncComponentModeEntriesLib={
        message('Simulink:Harness:SyncOptBothWays').getString,...
        message('Simulink:Harness:SyncOptOneWay').getString};
        syncComponentModeValuesLib=[0,1];
        syncComponentModeEntriesZC={
        message('Simulink:Harness:SyncOptOneWay').getString};
        syncComponentModeValuesZC=[1];

        testingSrcEntries;
        testingSrcValues;
        testingSinkEntries;
        testingSinkValues;

        forceClose=false;
hModelCloseListener
hModelStatusListener
hBlockDeleteListener
unhiliteOnClose
studioApp
lastSource
useGeneratedCodeFlag
existingBuildFolder


        ccList={};
        selIdx=1;
        currIdx=1;
        selectedContextName='None';
        harnessCustomizationsEnabled=slfeature('SLT_HarnessCustomizationRegistration')>0;
        multipleHarnessOpenEnabled=slfeature('MultipleHarnessOpen')>0;
        lockMainMdlSubsysOnHarnessOpenEnabled=slfeature('LockMainMdlSubsysOnHarnessOpen')>0;
    end

    methods

        function this=createDialog(harnessOwner)
            cm=DAStudio.CustomizationManager;
            hCreateCustomizerObj=[];
            if this.harnessCustomizationsEnabled
                hCreateCustomizerObj=cm.SimulinkTestCustomizer.createHarnessDefaultsObj;
            end

            this.harnessOwner=harnessOwner;
            this.harnessName=Simulink.harness.internal.customDefaultsUtils.getDefaultName(...
            this.harnessOwner.getFullName(),bdroot(this.harnessOwner.Path),hCreateCustomizerObj);
            modelName=bdroot(this.harnessOwner.getFullName());
            this.harnessType=0;
            this.existingBuildFolder='';
            this.useGeneratedCodeFlag=false;

            [this.testingSinkEntries,this.testingSinkValues]=...
            Simulink.harness.internal.getTestingSinksList('IncludeChartAndAssmt',false);

            allowChartSource=slfeature('UseStateflowHarnessInput')>0...
            &&license('test','Stateflow');
            [this.testingSrcEntries,this.testingSrcValues]=...
            Simulink.harness.internal.getTestingSourcesList(...
            'IncludeChart',allowChartSource,...
            'IncludeSigBuilder',false);

            if this.harnessCustomizationsEnabled

                this.harnessDescription=hCreateCustomizerObj.Description;


                sourceIdx=find(strcmpi(this.testingSrcEntries,hCreateCustomizerObj.Source));
                if~isempty(sourceIdx)
                    this.testingSrc=this.testingSrcValues(sourceIdx);
                else



                    assert(hCreateCustomizerObj.Source=="Chart")
                    this.testingSrc=this.testingSrcValues(1);
                end


                sinkIdx=find(strcmpi(this.testingSinkEntries,hCreateCustomizerObj.Sink));
                this.testingSink=this.testingSinkValues(sinkIdx);


                switch lower(hCreateCustomizerObj.SynchronizationMode)
                case 'synconopenandclose'
                    this.syncComponent=0;
                    if(isa(this.harnessOwner,'Simulink.BlockDiagram'))||...
                        this.isCreatingForImplicitLink()
                        this.syncComponent=1;
                    end
                case 'synconopen'
                    this.syncComponent=1;
                case 'synconpushrebuildonly'
                    this.syncComponent=2;
                otherwise
                    DAStudio.error('Simulink:Harness:InvalidSyncModeArg',...
                    hCreateCustomizerObj.SynchronizationMode);
                end


                this.separateAssessment=hCreateCustomizerObj.SeparateAssessment;


                this.rebuildModelData=hCreateCustomizerObj.RebuildModelData;


                this.logHarnessOutputsFlag=hCreateCustomizerObj.LogOutputs;


                this.defaultPostCreateCallBack=...
                string(hCreateCustomizerObj.PostCreateCallback).strip;


                this.postRebuildCallBack=...
                string(hCreateCustomizerObj.PostRebuildCallback).strip;

                this.customSrcPath=...
                string(hCreateCustomizerObj.CustomSourcePath).strip;
                this.customSinkPath=...
                string(hCreateCustomizerObj.CustomSinkPath).strip;


                switch lower(hCreateCustomizerObj.VerificationMode)
                case 'normal'
                    this.verificationMode=0;
                case 'sil'
                    this.verificationMode=1;
                case 'pil'
                    this.verificationMode=2;
                end


            else
                this.verificationMode=0;
                this.testingSrc=Simulink.harness.internal.TestHarnessSourceTypes.INPORT.val;
                this.testingSink=Simulink.harness.internal.TestHarnessSinkTypes.OUTPORT.val;

                this.syncComponent=0;
                if(isa(this.harnessOwner,'Simulink.BlockDiagram'))||...
                    this.isCreatingForImplicitLink()
                    this.syncComponent=1;
                end

                this.separateAssessment=false;
                this.rebuildModelData=false;
                this.harnessDescription='';
                this.logHarnessOutputsFlag=false;
                this.defaultPostCreateCallBack='';
                this.postRebuildCallBack='';
                this.customSrcPath='';
                this.customSinkPath='';
            end

            this.schedulerBlock=0;
            this.enableAutoShapeInputs=false;


            this.activateFlag=isempty(this.getActiveHarness())||(this.lockMainMdlSubsysOnHarnessOpenEnabled&&this.multipleHarnessOpenEnabled);
            this.previewImg='';

            this.saveExternally=false;
            this.driveFcnCallWithTSBFlag=true;
            [path,~,ext]=fileparts(get_param(bdroot(this.harnessOwner.Path),'FileName'));
            if strcmp(ext,'.mdl')
                this.saveExternally=true;
            end
            this.harnessFilePath=path;
            if this.harnessCustomizationsEnabled&&~(strip(hCreateCustomizerObj.HarnessPath)=="")
                this.harnessFilePath=strip(hCreateCustomizerObj.HarnessPath);
            end

            this.harnessFileName=fullfile(path,[this.harnessName,'.slx']);
            this.scheduleInitTermReset=false;

            if isa(this.harnessOwner,'Simulink.BlockDiagram')
                if(strcmp(get_param(modelName,'HasInitializeEvent'),'on')||...
                    strcmp(get_param(modelName,'HasTerminateEvent'),'on')||...
                    ~isempty(get_param(modelName,'EventIdentifiers')))
                    this.schedulerBlock=1;
                else
                    this.schedulerBlock=0;
                end
            end

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')>0
                if isa(this.harnessOwner,'Simulink.ModelReference')
                    hasIRT=strcmp(get_param(this.harnessOwner.Handle,'ShowModelInitializePort'),'on')||...
                    strcmp(get_param(this.harnessOwner.Handle,'ShowModelTerminatePort'),'on')||...
                    strcmp(get_param(this.harnessOwner.Handle,'ShowModelReinitializePorts'),'on')||...
                    strcmp(get_param(this.harnessOwner.Handle,'ShowModelResetPorts'),'on');
                else
                    hasIRT=false;
                end
                createScheduler=(isa(this.harnessOwner,'Simulink.BlockDiagram')&&...
                strcmpi(get_param(this.harnessOwner.Handle,'IsExportFunctionModel'),'on'))||...
                (isa(this.harnessOwner,'Simulink.ModelReference')&&...
                strcmpi(get_param(this.harnessOwner.Handle,'IsModelRefExportFunction'),'on'));



                if hasIRT||createScheduler
                    if this.harnessCustomizationsEnabled&&...
                        any(strcmpi("ScheduleInitTermReset",hCreateCustomizerObj.userDefinedProps))
                        this.scheduleInitTermReset=hCreateCustomizerObj.ScheduleInitTermReset;
                    else
                        this.scheduleInitTermReset=true;
                    end
                    this.schedulerBlock=1;
                else
                    this.scheduleInitTermReset=false;
                    this.schedulerBlock=0;
                end

                if isa(this.harnessOwner,'Simulink.ModelReference')&&...
                    strcmpi(get_param(this.harnessOwner.Handle,'ShowModelPeriodicEventPorts'),'on')
                    this.schedulerBlock=1;
                end

                if isa(this.harnessOwner,'Simulink.BlockDiagram')

                    this.schedulerBlockEntries={'None','Test Sequence','MATLAB Function','Schedule Editor'};
                    this.schedulerBlockValues=[0,1,2,3];
                end
            end

            if slfeature('UseStateflowHarnessInput')>0&&license('test','Stateflow')
                this.schedulerBlockEntries{end+1}='Chart';
                indexForStateflow=size(this.schedulerBlockValues,2);
                this.schedulerBlockValues=[this.schedulerBlockValues,indexForStateflow];
            end

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')>0&&...
                ~isa(this.harnessOwner,'Simulink.ModelReference')&&...
                ~isa(this.harnessOwner,'Simulink.BlockDiagram')
                this.schedulerBlock=1;
            end


            if this.harnessCustomizationsEnabled&&...
                any(strcmpi("SchedulerBlock",hCreateCustomizerObj.userDefinedProps))
                switch lower(hCreateCustomizerObj.SchedulerBlock)
                case lower(this.schedulerBlockEntries)
                    schBlockIdx=find(strcmpi(hCreateCustomizerObj.SchedulerBlock,this.schedulerBlockEntries));
                    this.schedulerBlock=schBlockIdx-1;
                otherwise



                    assert(hCreateCustomizerObj.SchedulerBlock=="Chart");
                end
            end


            saveExternallyMode=...
            Simulink.harness.internal.getHarnessCreationCheckboxMode.saveExtCheckboxMode(modelName);
            switch saveExternallyMode




            case Simulink.harness.internal.getHarnessCreationCheckboxMode.ALLOW_SELECTION
                if this.harnessCustomizationsEnabled
                    this.saveExternally=cm.SimulinkTestCustomizer.createHarnessDefaultsObj.SaveExternally;
                else
                    this.saveExternally=false;
                end
            otherwise
                this.saveExternally=...
                saveExternallyMode==Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_EXTERNALLY;
            end

            this.enableDetailConfigPanel=false;
            if this.harnessCustomizationsEnabled&&...
                any(strcmpi("CreateWithoutCompile",hCreateCustomizerObj.userDefinedProps))
                this.graphicalHarnessFlag=hCreateCustomizerObj.CreateWithoutCompile;
            elseif this.isCreatingForLibrary()||this.isCreatingForSubsystemModel()
                this.graphicalHarnessFlag=true;
            else
                this.graphicalHarnessFlag=false;
            end


            if this.isCreatingForLibrary()||this.isCreatingForSubsystemModel()
                this.rebuildOnOpen=false;
            elseif this.isCreatingForImplicitLink()
                this.rebuildOnOpen=true;
            elseif this.harnessCustomizationsEnabled&&...
                any(strcmpi("RebuildOnOpen",hCreateCustomizerObj.userDefinedProps))
                this.rebuildOnOpen=hCreateCustomizerObj.RebuildOnOpen;
            end


            this.readonly=false;
            this.harnessCreated=false;
            this.postCreateCallBack='';

            this.harnessTypeEntries={
            DAStudio.message('Simulink:Harness:HarnessTypeTesting'),...
            };
            this.harnessTypeValues=0;
            this.unhiliteOnClose=false;
            this.studioApp=SLM3I.SLDomain.getLastActiveStudioApp();



            if this.isCreatingForLibrary()&&isa(this.harnessOwner,'Simulink.SubSystem')
                codeContexts=Simulink.libcodegen.internal.getBlockCodeContexts(modelName,this.harnessOwner.Handle);
                if~isempty(codeContexts)
                    this.ccList{1}='None';
                    for i=1:length(codeContexts)
                        this.ccList{end+1}=codeContexts(i).name;
                    end
                end
            end

        end




        function varType=getPropDataType(this,varName)%#ok
            switch(varName)
            case{'harnessName',...
                'harnessDescription',...
                'customSrcPath',...
                'customSinkPath',...
                'harnessFileName',...
                'harnessFilePath',...
                'defaultPostCreateCallBack',...
                'postCreateCallBack',...
                'existingBuildFolder',...
                'postRebuildCallBack'}
                varType='string';
            case{'harnessType',...
                'verificationMode',...
                'testingSrc',...
                'testingSink',...
                'syncComponent',...
                'schedulerBlock',...
                'selIdx'}
                varType='double';
            case{'graphicalHarnessFlag',...
                'driveFcnCallWithTSBFlag',...
                'rebuildOnOpen',...
                'rebuildModelData',...
                'separateAssessment',...
                'enableAutoShapeInputs',...
                'activateFlag',...
                'saveExternally',...
                'useGeneratedCodeFlag',...
                'scheduleInitTermReset',...
                'logHarnessOutputsFlag'}
                varType='bool';
            otherwise
                varType='other';
            end
        end

        function setPropValue(obj,varName,varVal)
            if strcmp(varName,'harnessType')
                obj.harnessType=str2double(varVal);
            elseif strcmp(varName,'verificationMode')
                obj.verificationMode=str2double(varVal);
            elseif strcmp(varName,'existingBuildFolder')
                obj.existingBuildFolder=varVal;
            elseif strcmp(varName,'testingSrc')
                obj.testingSrc=str2double(varVal);
            elseif strcmp(varName,'testingSink')
                obj.testingSink=str2double(varVal);
            elseif strcmp(varName,'harnessDescription')


                obj.harnessDescription=varVal;
            elseif strcmp(varName,'harnessName')
                obj.harnessName=varVal;
            elseif strcmp(varName,'harnessFileName')
                obj.harnessFileName=varVal;
            elseif strcmp(varName,'harnessFilePath')
                obj.harnessFilePath=varVal;
            elseif strcmp(varName,'customSrcPath')
                obj.customSrcPath=varVal;
            elseif strcmp(varName,'customSinkPath')
                obj.customSinkPath=varVal;
            elseif strcmp(varName,'defaultPostCreateCallBack')
                obj.defaultPostCreateCallBack=varVal;
            elseif strcmp(varName,'postCreateCallBack')
                obj.postCreateCallBack=varVal;
            elseif strcmp(varName,'postRebuildCallBack')
                obj.postRebuildCallBack=varVal;
            elseif strcmp(varName,'syncComponent')
                obj.syncComponent=str2double(varVal);
            elseif strcmp(varName,'schedulerBlock')
                obj.schedulerBlock=str2double(varVal);
            elseif(strcmp(varName,'selIdx'))
                obj.selIdx=str2double(varVal);
            else
                DAStudio.Protocol.setPropValue(obj,varName,varVal);
            end

        end

        function dlgHelpMethod(~)
            try
                mapFile=fullfile(docroot,'sltest','helptargets.map');
                helpview(mapFile,'harnessCreateHelp');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
        end

        function dlgCloseMethod(this)
            if this.forceClose
                return
            end
            if isa(this.harnessOwner,'Simulink.SubSystem')&&this.unhiliteOnClose
                hilite(this.harnessOwner,'none');
            end
            if this.harnessCreated&&this.activateFlag
                try



                    Simulink.harness.open(this.harnessOwner.Handle,this.harnessName,'SuppressRebuild',true,'ReuseWindow',false);

                catch ME
                    Simulink.harness.internal.warn(ME,...
                    true,...
                    'Simulink:Harness:OpenHarnessStage',...
                    bdroot(this.harnessOwner.Path));
                end
            end
        end

        function setReadonly(this,dlg,val)
            this.readonly=val;
            dlg.setEnabled('CreateSimulationHarnessDialogPanel',~val);
        end

        function[status,msg]=dlgPostApplyMethod(this,dlg)
            status=false;
            msg=[];

            if this.saveExternally
                modelName=bdroot(this.harnessOwner.getFullName());
                if strcmp(get_param(modelName,'Dirty'),'on')
                    msg=DAStudio.message('Simulink:Harness:IndHarnessModelMustBeSaved');
                    return;
                end
                this.harnessFileName=fullfile(this.harnessFilePath,[this.harnessName,'.slx']);
            end


            harnessCreateStage=Simulink.output.Stage(...
            DAStudio.message('Simulink:Harness:CreateHarnessStage'),...
            'ModelName',bdroot(this.harnessOwner.Path),...
            'UIMode',true);%#ok

            try

                this.setReadonly(dlg,true);
                wstate=warning('off','Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD');
                oc=onCleanup(@()warning(wstate));
                Simulink.harness.internal.validateHarnessName(bdroot(this.harnessOwner.getFullName()),[],...
                this.harnessName);
                oc.delete;

                if~isempty(which(this.harnessName))&&...
                    ~isequal(this.harnessName,bdroot)&&...
                    isempty(find_system('SearchDepth',0,'type','block_diagram','Name',this.harnessName))
                    if this.saveExternally&&exist(this.harnessFileName,'file')==4
                        DAStudio.error('Simulink:Harness:IndHarnessFileExists',this.harnessName,which(this.harnessName));
                    else
                        warnStr=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnCreation');
                        title=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnCreationTitle');
                        continueButton=DAStudio.message('Simulink:Harness:Continue');
                        cancelButton=DAStudio.message('Simulink:Harness:Cancel');
                        choice=questdlg(warnStr,title,continueButton,cancelButton,continueButton);
                        if~strcmp(choice,continueButton)
                            DAStudio.error('Simulink:Harness:HarnessCreationAbortedFileShadow');
                        end
                    end
                end
                switch this.harnessType
                case 0
                    import Simulink.harness.internal.TestHarnessSourceTypes;
                    import Simulink.harness.internal.TestHarnessSinkTypes;

                    src=this.testingSrcEntries{this.testingSrc==this.testingSrcValues};

                    if strcmp(src,TestHarnessSourceTypes.REACTIVE_TEST.name)
                        sink=TestHarnessSinkTypes.REACTIVE_TEST.name;
                    elseif strcmp(src,TestHarnessSourceTypes.STATEFLOW.name)
                        sink=TestHarnessSinkTypes.STATEFLOW.name;
                    else
                        sink=this.testingSinkEntries{this.testingSink==this.testingSinkValues};
                    end



                    verificationModeArg=...
                    this.verificationModeEntries{this.verificationMode==this.verificationModeValues};


                    if strcmp(verificationModeArg,message('Simulink:studio:SimModeSILToolBar').getString)
                        verificationModeArg='SIL';
                    elseif strcmp(verificationModeArg,message('Simulink:studio:SimModePILToolBar').getString)
                        verificationModeArg='PIL';
                    elseif strcmp(verificationModeArg,message('Simulink:studio:SimModeNormalToolBar').getString)
                        verificationModeArg='Normal';
                    end

                    if this.syncComponent==0
                        syncModeArg='SyncOnOpenAndClose';
                    elseif this.syncComponent==1
                        syncModeArg='SyncOnOpen';
                    else
                        syncModeArg='SyncOnPushRebuildOnly';
                    end



                    customSrc=this.customSrcPath;
                    if this.testingSrc~=TestHarnessSourceTypes.CUSTOM.val
                        customSrc='';
                    end

                    customSink=this.customSinkPath;
                    if this.testingSink~=TestHarnessSinkTypes.CUSTOM.val
                        customSink='';
                    end

                    if~this.saveExternally
                        this.harnessFileName='';
                    end

                    existingBuildFolderArg='';
                    if(this.useGeneratedCodeFlag)
                        existingBuildFolderArg=this.existingBuildFolder;
                        if(isempty(existingBuildFolderArg))
                            DAStudio.error('Simulink:Harness:ExistingBuildFolderError');
                        else
                            if(~isfolder(existingBuildFolderArg))
                                DAStudio.error('Simulink:Harness:ExistingBuildFolderError');
                            end
                        end
                    end

                    functionInterfaceName='';
                    if~isempty(this.selectedContextName)&&...
                        ~strcmp(this.selectedContextName,'None')
                        functionInterfaceName=this.selectedContextName;
                    end



                    Simulink.harness.create(this.harnessOwner.Handle,...
                    'Name',this.harnessName,...
                    'Description',this.harnessDescription,...
                    'Source',src,...
                    'Sink',sink,...
                    'SeparateAssessment',this.separateAssessment,...
                    'AutoShapeInputs',this.enableAutoShapeInputs,...
                    'SchedulerBlock',this.schedulerBlockEntries{1+this.schedulerBlock},...
                    'CreateWithoutCompile',this.graphicalHarnessFlag,...
                    'DriveFcnCallWithTestSequence',this.driveFcnCallWithTSBFlag,...
                    'CreateFromDialog',true,...
                    'VerificationMode',verificationModeArg,...
                    'ExistingBuildFolder',existingBuildFolderArg,...
                    'CustomSourcePath',customSrc,...
                    'CustomSinkPath',customSink,...
                    'SaveExternally',this.saveExternally,...
                    'HarnessPath',this.harnessFileName,...
                    'RebuildOnOpen',this.rebuildOnOpen,...
                    'RebuildModelData',this.rebuildModelData,...
                    'ScheduleInitTermReset',this.scheduleInitTermReset,...
                    'SynchronizationMode',syncModeArg,...
                    'PostCreateCallBack',this.postCreateCallBack,...
                    'PostRebuildCallBack',this.postRebuildCallBack,...
                    'FunctionInterfaceName',functionInterfaceName,...
                    'LogOutputs',this.logHarnessOutputsFlag);
                otherwise

                    assert(true,'Wrong harness type specified');
                end


                this.setReadonly(dlg,false);
                this.harnessCreated=true;
                status=true;
            catch ME
                this.setReadonly(dlg,false);
                this.harnessCreated=false;


                Simulink.harness.internal.error(ME,true);



                msg=DAStudio.message('Simulink:Harness:CreateAborted');

            end
        end

        function link_cb(this)
            if isa(this.harnessOwner,'Simulink.SubSystem')
                hilite(this.harnessOwner);
                this.unhiliteOnClose=true;
            else
                view(this.harnessOwner);
            end
        end


        function type_cb(this)
            import Simulink.harness.internal.TestHarnessSourceTypes;
            import Simulink.harness.internal.TestHarnessSinkTypes;

            if this.harnessType~=0
                this.testingSrc=TestHarnessSourceTypes.NONE.val;
                this.testingSink=TestHarnessSinkTypes.NONE.val;
            end
        end

        function saveexthelp_cb(~)


            try
                helpview(fullfile(docroot,'sltest','helptargets.map'),'HarnessCreateDlgNameCBoxTag');
            catch me %#ok

            end
        end

        function harnessName_cb(this)
            this.harnessFileName=fullfile(this.harnessFilePath,[this.harnessName,'.slx']);
        end

        function browseBtn_cb(this)
            directoryname=uigetdir(this.harnessFilePath,'Select a directory');
            if ischar(directoryname)
                this.harnessFilePath=directoryname;
            end
        end

        function browseBuildFolder_cb(this)
            directoryname=uigetdir(this.harnessFilePath,'Select the build folder for the existing code');
            if ischar(directoryname)
                this.existingBuildFolder=directoryname;
            end
        end

        function verificationMode_cb(this)
            if this.verificationMode~=0
                this.syncComponent=2;
                if this.useGeneratedCodeFlag
                    this.rebuildOnOpen=false;
                else
                    this.rebuildOnOpen=true;
                end
                this.rebuildOnOpen=true;
                this.graphicalHarnessFlag=false;
            else
                this.rebuildOnOpen=false;
                if this.isBDorMRorLinked()
                    this.syncComponent=1;
                else
                    this.syncComponent=0;
                end
            end
        end

        function generatedCode_cb(this)
            if this.verificationMode~=0&&this.useGeneratedCodeFlag
                this.rebuildOnOpen=false;
            else
                this.rebuildOnOpen=true;
            end
        end

        function scheduler_cb(this)
        end

        function ret=isBDorMRorLinked(this)
            isLinked=false;
            if isa(this.harnessOwner,'Simulink.SubSystem')
                isLinked=strcmp(get_param(this.harnessOwner.getFullName(),'LinkStatus'),'resolved')||...
                strcmp(get_param(this.harnessOwner.getFullName(),'LinkStatus'),'inactive');
            end

            ret=isa(this.harnessOwner,'Simulink.ModelReference')||...
            isa(this.harnessOwner,'Simulink.BlockDiagram')||...
            isLinked;
        end









        function grp=addDialogInstructionsUI(this)
            lbl.Name=DAStudio.message('Simulink:Harness:CreateDialogInstructions');
            lbl.Type='text';
            lbl.Alignment=2;
            lbl.WordWrap=true;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,2];

            lblCUT.Name=DAStudio.message('Simulink:Harness:CUT');
            lblCUT.Type='text';
            lblCUT.RowSpan=[2,2];
            lblCUT.ColSpan=[1,1];

            lnk.Name=this.harnessOwner.getFullName();
            lnk.Type='hyperlink';
            lnk.Alignment=1;
            lnk.Tag='HarnessCreateDlgOwnerLinkTag';
            lnk.ToolTip=DAStudio.message('Simulink:Harness:HarnessOwnerTooltip');
            lnk.ObjectMethod='link_cb';
            lnk.RowSpan=[2,2];
            lnk.ColSpan=[2,2];

            grp.Name='';
            grp.Type='group';
            grp.Items={lbl,lblCUT,lnk};
            grp.LayoutGrid=[2,2];
            grp.ColStretch=[0,1];
        end

        function panel=addHarnessNameUI(this)
            lbl.Name=DAStudio.message('Simulink:Harness:HarnessName');
            lbl.Type='text';
            lbl.Buddy='HarnessCreateDlgNameEditTag';
            lbl.Alignment=1;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,1];

            edit.Type='edit';
            edit.ObjectProperty='harnessName';
            edit.Mode=true;
            edit.Tag='HarnessCreateDlgNameEditTag';
            edit.RowSpan=[1,1];
            edit.ColSpan=[2,6];
            edit.ObjectMethod='harnessName_cb';
            modelName=bdroot(this.harnessOwner.getFullName());

            extHarnessVisible=true;
            result=Simulink.harness.internal.getHarnessCreationCheckboxMode.saveExtCheckboxMode(modelName);

            switch result
            case Simulink.harness.internal.getHarnessCreationCheckboxMode.ALLOW_SELECTION
                saveExt=Simulink.harness.internal.getCheckBoxSrc(...
                'Simulink:Harness:SaveHarnessesExternally',...
                'saveExternally',...
                'HarnessCreateDlgNameCBoxTag');
                saveExt.Enabled=true;
            case Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_EXTERNALLY
                saveExt.Name=['<i>',DAStudio.message('Simulink:Harness:HarnessesSavedExternally'),'</i>'];
                saveExt.Tag='HarnessesSavedExternallyTag';
                saveExt.Type='text';
            case Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_INTERNALLY
                saveExt.Name=['<i>',DAStudio.message('Simulink:Harness:HarnessesSavedInternally'),'</i>'];
                saveExt.Tag='HarnessesSavedInternallyTag';
                saveExt.Type='text';
            end

            saveExt.Alignment=1;
            saveExt.RowSpan=[2,2];
            saveExt.ColSpan=[2,3];
            saveExt.Visible=extHarnessVisible;

            saveExtHelp.Name=DAStudio.message('Simulink:Harness:HarnessesSavedExternallyHelp');
            saveExtHelp.Type='hyperlink';
            saveExtHelp.Tag='HarnessesSavedExternallyHelpTag';
            saveExtHelp.RowSpan=[2,2];
            saveExtHelp.ColSpan=[4,4];
            saveExtHelp.Visible=extHarnessVisible;
            saveExtHelp.ObjectMethod='saveexthelp_cb';

            saveExtFilePath.Name=DAStudio.message('Simulink:Harness:ExternalHarnessDirectory');
            saveExtFilePath.Type='edit';
            saveExtFilePath.ObjectProperty='harnessFilePath';
            saveExtFilePath.Tag='HarnessesSavedExternallyFilePathTag';
            saveExtFilePath.Mode=true;
            saveExtFilePath.Visible=this.saveExternally;
            saveExtFilePath.RowSpan=[3,3];
            saveExtFilePath.ColSpan=[2,5];

            saveExtBrowse.Type='pushbutton';
            saveExtBrowse.Name=DAStudio.message('Simulink:Harness:BrowseBtn');
            saveExtBrowse.Enabled=true;
            saveExtBrowse.MaximumSize=[70,40];
            saveExtBrowse.RowSpan=[3,3];
            saveExtBrowse.ColSpan=[6,6];
            saveExtBrowse.Alignment=1;
            saveExtBrowse.Tag='HarnessDirBrowseBtn';
            saveExtBrowse.Mode=true;
            saveExtBrowse.Visible=this.saveExternally;
            saveExtBrowse.DialogRefresh=true;
            saveExtBrowse.ObjectMethod='browseBtn_cb';

            panel.Type='panel';
            panel.LayoutGrid=[3,6];
            panel.ColStretch=[0,0,0,0,1,1];
            panel.Items={lbl,edit,saveExt,saveExtHelp,...
            saveExtFilePath,saveExtBrowse};
        end

        function editArea=addHarnessDescriptionUI(~)
            editArea.Name=DAStudio.message('Simulink:Harness:HarnessDescription');
            editArea.Type='editarea';
            editArea.MinimumSize=[0,1];
            editArea.WordWrap=true;
            editArea.ObjectProperty='harnessDescription';
            editArea.Tag='HarnessCreateDlgDescriptionTag';
        end


        function group=addHarnessConfigurationUI(this)
            import Simulink.harness.internal.TestHarnessSourceTypes;
            import Simulink.harness.internal.TestHarnessSinkTypes;

            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessConfig');
            group.LayoutGrid=[3,4];
            group.ColStretch=[0,0,0,1];
            group.Items={};


            srccombobox=Simulink.harness.internal.getComboBoxSrc(...
            '','HarnessCreateDlgSourceTypeTag',...
            this.testingSrcEntries,this.testingSrcValues);
            srccombobox.ObjectProperty='testingSrc';
            srccombobox.RowSpan=[1,1];
            srccombobox.ColSpan=[1,1];
            srccombobox.Enabled=(this.harnessType==0);
            srccombobox.Mode=true;

            preview.Type='image';
            preview.FilePath=this.getPreviewImgfilePath();
            preview.RowSpan=[1,1];
            preview.ColSpan=[2,2];


            sinkcombobox=Simulink.harness.internal.getComboBoxSrc(...
            '','HarnessCreateDlgSinkTypeTag',...
            this.testingSinkEntries,this.testingSinkValues);
            sinkcombobox.ObjectProperty='testingSink';
            sinkcombobox.RowSpan=[1,1];
            sinkcombobox.ColSpan=[3,3];
            sinkcombobox.Visible=(this.testingSrc~=TestHarnessSourceTypes.REACTIVE_TEST.val&&this.testingSrc~=TestHarnessSourceTypes.STATEFLOW.val);
            sinkcombobox.Enabled=(this.harnessType==0);
            sinkcombobox.Mode=true;


            customSrc.Type='edit';
            customSrc.ObjectProperty='customSrcPath';
            customSrc.Mode=true;
            customSrc.Tag='HarnessCustomSrcPathEditTag';
            customSrc.RowSpan=[2,2];
            customSrc.ColSpan=[1,1];
            customSrc.Visible=(this.testingSrc==TestHarnessSourceTypes.CUSTOM.val);

            customSink.Type='edit';
            customSink.ObjectProperty='customSinkPath';
            customSink.Mode=true;
            customSink.Tag='HarnessCustomSinkPathEditTag';
            customSink.RowSpan=[2,2];
            customSink.ColSpan=[3,3];
            customSink.Visible=(this.testingSrc~=TestHarnessSourceTypes.REACTIVE_TEST.val&&...
            this.testingSrc~=TestHarnessSourceTypes.STATEFLOW.val&&...
            this.testingSink==TestHarnessSinkTypes.CUSTOM.val);



            if~this.isCreatingForLibrary()&&~this.isCreatingForSubsystemModel()
                import Simulink.harness.internal.TestHarnessSourceTypes;
                autoShapeCheckbox=this.addAutoShapeInputsUI();
                autoShapeCheckbox.ToolTip=DAStudio.message('Simulink:Harness:AutoShapeInputsTooltip');
                autoShapeCheckbox.RowSpan=[3,3];
                autoShapeCheckbox.ColSpan=[1,1];
                src=this.testingSrcEntries{this.testingSrc==this.testingSrcValues};
                if~strcmp(src,this.lastSource)
                    this.lastSource=src;
                    cm=DAStudio.CustomizationManager;
                    if this.harnessCustomizationsEnabled&&...
                        any(strcmpi("AutoShapeInputs",...
                        cm.SimulinkTestCustomizer.createHarnessDefaultsObj.userDefinedProps))
                        this.enableAutoShapeInputs=...
                        cm.SimulinkTestCustomizer.createHarnessDefaultsObj.AutoShapeInputs;
                    else
                        this.enableAutoShapeInputs=false;
                    end
                end
                if strcmp(src,TestHarnessSourceTypes.CUSTOM.name)||...
                    strcmp(src,TestHarnessSourceTypes.REACTIVE_TEST.name)||...
                    strcmp(src,TestHarnessSourceTypes.STATEFLOW.name)||...
                    strcmp(src,TestHarnessSourceTypes.NONE.name)||...
                    strcmp(src,TestHarnessSourceTypes.SIGNAL_EDITOR.name)||...
                    strcmp(src,TestHarnessSourceTypes.GROUND.name)
                    isEnabled=false;
                else
                    isEnabled=true;
                end
                autoShapeCheckbox.Enabled=isEnabled;
                group.Items{end+1}=autoShapeCheckbox;
            end

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')>0

                schBlockOpts=this.addUnifiedSchedulerUI();
                schBlockOpts.ObjectProperty='schedulerBlock';
                schBlockOpts.ObjectMethod='scheduler_cb';
                schBlockOpts.RowSpan=[4,4];
                schBlockOpts.ColSpan=[1,2];
                group.Items{end+1}=schBlockOpts;

                showIRT=true;
                if~isa(this.harnessOwner,'Simulink.BlockDiagram')||...
                    this.isCreatingForSubsystemModel()
                    showIRT=false;
                end

                if showIRT
                    irt=Simulink.harness.internal.getCheckBoxSrc(...
                    'Simulink:Harness:InitTermResetOption',...
                    'scheduleInitTermReset',...
                    'HarnessCreateDlgInitTermResetOptionTag');
                    irt.Mode=true;
                    if this.schedulerBlock==0||this.schedulerBlock==3
                        this.scheduleInitTermReset=false;
                        irt.Enabled=false;
                    else
                        irt.Enabled=true;
                    end
                    irt.RowSpan=[5,5];
                    irt.ColSpan=[1,2];
                    group.Items{end+1}=irt;
                end

            end


            separateassessmentcbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:UseSeparateAssessmentForReactiveTest',...
            'separateAssessment',...
            'HarnessCreateDlgSeparateAssessmentCBoxTag');
            separateassessmentcbox.RowSpan=[6,6];
            separateassessmentcbox.ColSpan=[1,2];
            separateassessmentcbox.Visible=true;
            separateassessmentcbox.Mode=true;

            group.Items=[group.Items,{srccombobox,preview,sinkcombobox,...
            customSrc,customSink,...
            separateassessmentcbox}];
        end

        function filePath=getPreviewImgfilePath(this)
            if this.testingSrc~=Simulink.harness.internal.TestHarnessSourceTypes.REACTIVE_TEST.val&&...
                this.testingSrc~=Simulink.harness.internal.TestHarnessSourceTypes.STATEFLOW.val
                filePath=[matlabroot,'/toolbox/simulinktest/core/simharness/simharness/'...
                ,'+Simulink/+harness/resources/CUT1.png'];
            elseif this.separateAssessment
                filePath=[matlabroot,'/toolbox/simulinktest/core/simharness/simharness/'...
                ,'+Simulink/+harness/resources/CUT3.png'];
            else
                filePath=[matlabroot,'/toolbox/simulinktest/core/simharness/simharness/'...
                ,'+Simulink/+harness/resources/CUT2.png'];
            end
        end

        function cbox=addGraphicalHarnessUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:GraphicalCreate',...
            'graphicalHarnessFlag',...
            'HarnessCreateDlgGraphicalCreateCBoxTag');
        end

        function cbox=addUnifiedSchedulerUI(this)
            if isa(this.harnessOwner,'Simulink.ModelReference')||isa(this.harnessOwner,'Simulink.BlockDiagram')
                cboxname='Simulink:Harness:SchedulerBlock';
            else
                cboxname='Simulink:Harness:FcnCallDriverBlock';
            end
            cbox=Simulink.harness.internal.getComboBoxSrc(...
            cboxname,...
            'HarnessCreateDlgUnifiedSchedulerCBoxTag',...
            this.schedulerBlockEntries,...
            this.schedulerBlockValues);
        end

        function cbox=addAutoShapeInputsUI(this)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:AutoShapeInputsForReactiveTest',...
            'enableAutoShapeInputs',...
            'HarnessCreateDlgAutoShapeCBoxTag');
        end

        function group=addInitTermResetOptions(this)

            group.Name=DAStudio.message('Simulink:Harness:InitTermResetGroup');
            group.Type='group';

            irt=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:InitTermResetOption',...
            'scheduleInitTermReset',...
            'HarnessCreateDlgInitTermResetOptionTag');
            irt.Mode=true;

            group.Items={irt};

            bd=bdroot(this.harnessOwner.Handle);

            if isa(this.harnessOwner,'Simulink.BlockDiagram')&&...
                strcmpi(get_param(bd,'IsExportFunctionModel'),'on')
                group.Visible=true;
            else
                group.Visible=false;
            end

        end

        function cbox=addHarnesRebuildOnOpenUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:RebuildOnOpenCheckbox',...
            'rebuildOnOpen',...
            'HarnessRebuildOnOpenTag');
            cbox.Mode=true;
        end

        function cbox=addHarnesRebuildModelDataUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:RebuildModelDataCheckbox',...
            'rebuildModelData',...
            'HarnessRebuildModelDataTag');
            cbox.Mode=true;
        end

        function cbox=addHarnessOutputLoggingUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:LogHarnessOutputs',...
            'logHarnessOutputsFlag',...
            'HarnessLogOutputsTag');
        end

        function group=addBasicPropertiesUI(this)
            group.Name='';
            group.Type='group';
            group.Items={this.addHarnessNameUI(),this.addContextSelectorUI()};
        end

        function cbox=addHarnessActivationUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:HarnessActivate',...
            'activateFlag',...
            'HarnessCreateDlgActivateCBoxTag');
        end



        function group=addCreateOptionsUI(this)
            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessCreateOpts');
            group.LayoutGrid=[10,6];
            group.Items={};

            if this.isBDorMRorLinked()||this.verificationMode==0
                graphicalCheckbox=this.addGraphicalHarnessUI();
                graphicalCheckbox.RowSpan=[1,1];
                graphicalCheckbox.ColSpan=[1,6];
                graphicalCheckbox.ObjectMethod='graphicalCheckbox_cb';
                graphicalCheckbox.Enabled=this.verificationMode==0&&...
                ~this.isCreatingForLibrary&&~this.isCreatingForSubsystemModel;
                group.Items{end+1}=graphicalCheckbox;
            end

            if license('test','RTW_Embedded_Coder')
                verificationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessVerificationMode',...
                'verificationModeTag',...
                this.verificationModeEntries,...
                this.verificationModeValues);
                verificationModecombobox.ObjectProperty='verificationMode';
                verificationModecombobox.ObjectMethod='verificationMode_cb';
                verificationModecombobox.Enabled=~this.graphicalHarnessFlag&&...
                this.isCreatingForValidSILPILBlock()&&...
                ~Simulink.harness.internal.isSimulinkFunctionBlockForHarnessCreation(this.harnessOwner.Handle);
                verificationModecombobox.RowSpan=[2,2];
                verificationModecombobox.ColSpan=[1,6];
                group.Items{end+1}=verificationModecombobox;

                if(this.verificationMode==0)
                    this.useGeneratedCodeFlag=false;
                end

                generatedCodeGroup.Type='group';
                generatedCodeGroup.LayoutGrid=[1,6];
                generatedCodeGroup.Items={};

                if(isa(this.harnessOwner,'Simulink.SubSystem'))
                    generatedCodeCheckBox=Simulink.harness.internal.getCheckBoxSrc(...
                    'Simulink:Harness:GeneratedCodeForSILPILBlockCreate',...
                    'useGeneratedCodeFlag',...
                    'UseExistingCodeTag');
                    generatedCodeCheckBox.Enabled=true;
                    generatedCodeCheckBox.Alignment=1;
                    generatedCodeCheckBox.RowSpan=[3,3];
                    generatedCodeCheckBox.ColSpan=[1,6];
                    generatedCodeCheckBox.Visible=(this.verificationMode==1||this.verificationMode==2);
                    generatedCodeCheckBox.ObjectMethod='generatedCode_cb';
                    group.Items{end+1}=generatedCodeCheckBox;
                end

                if(this.useGeneratedCodeFlag)
                    silExistingBuildFolder.Name=DAStudio.message('Simulink:Harness:ExistingBuildFolder');
                    silExistingBuildFolder.Type='edit';
                    silExistingBuildFolder.ObjectProperty='existingBuildFolder';
                    silExistingBuildFolder.Tag='SILExistingBuildFolderTag';
                    silExistingBuildFolder.Mode=true;
                    silExistingBuildFolder.Visible=this.useGeneratedCodeFlag;
                    silExistingBuildFolder.RowSpan=[1,1];
                    silExistingBuildFolder.ColSpan=[2,5];
                    generatedCodeGroup.Items{end+1}=silExistingBuildFolder;

                    silBuildFolderBrowse.Type='pushbutton';
                    silBuildFolderBrowse.Name=DAStudio.message('Simulink:Harness:BrowseBtn');
                    silBuildFolderBrowse.Enabled=true;
                    silBuildFolderBrowse.MaximumSize=[70,40];
                    silBuildFolderBrowse.RowSpan=[1,1];
                    silBuildFolderBrowse.ColSpan=[6,6];
                    silBuildFolderBrowse.Tag='SILBuildFolderBrowseBtn';
                    silBuildFolderBrowse.Mode=true;
                    silBuildFolderBrowse.Visible=this.useGeneratedCodeFlag;
                    silBuildFolderBrowse.DialogRefresh=true;
                    silBuildFolderBrowse.ObjectMethod='browseBuildFolder_cb';
                    generatedCodeGroup.Items{end+1}=silBuildFolderBrowse;

                    group.Items{end+1}=generatedCodeGroup;
                end

            end


            textBoxCB.Name=strcat('<i>',...
            DAStudio.message('Simulink:Harness:DefaultPostCreateCBTitle'),...
            {' '},'</i>',...
            this.defaultPostCreateCallBack);
            textBoxCB.ToolTip=DAStudio.message('Simulink:Harness:DefaultPostCreateCBTooltip');
            textBoxCB.Type='text';
            textBoxCB.Tag='HarnessCreateDlgDefaultPostCreateCBTag';
            textBoxCB.Visible=this.defaultPostCreateCallBack~="";
            textBoxCB.RowSpan=[6,6];
            textBoxCB.ColSpan=[1,1];
            group.Items{end+1}=textBoxCB;


            if textBoxCB.Visible



                editBox.Name=DAStudio.message('Simulink:Harness:AdditionalPostCreateCBTitle');
            else
                editBox.Name=DAStudio.message('Simulink:Harness:PostCreateCBTitle');
            end
            editBox.Type='edit';
            editBox.Mode=true;
            editBox.ObjectProperty='postCreateCallBack';
            editBox.Tag='HarnessCreateDlgPostCreateCBTag';
            editBox.RowSpan=[7,7];
            editBox.ColSpan=[1,1];
            group.Items{end+1}=editBox;

            if slfeature('CreateSchedulerForBdAndMdlRefHarness')<=0
                initTermResetOptions=this.addInitTermResetOptions();
                initTermResetOptions.RowSpan=[8,8];
                initTermResetOptions.ColSpan=[1,1];
                group.Items{end+1}=initTermResetOptions;
            end


            hOutLoggingCheckbox=this.addHarnessOutputLoggingUI();
            hOutLoggingCheckbox.RowSpan=[10,10];
            hOutLoggingCheckbox.ColSpan=[1,1];
            hOutLoggingCheckbox.Enabled=true;
            hOutLoggingCheckbox.Visible=slfeature('HarnessOutputSignalLogging')>1;
            group.Items{end+1}=hOutLoggingCheckbox;

        end

        function group=addRebuildOptionsUI(this)
            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessRebuildOpts');
            group.LayoutGrid=[3,1];
            group.Items={};

            rebuildOnOpenCheckbox=this.addHarnesRebuildOnOpenUI();
            rebuildOnOpenCheckbox.RowSpan=[1,1];
            rebuildOnOpenCheckbox.ColSpan=[1,1];
            rebuildOnOpenCheckbox.Enabled=~this.isCreatingForLibrary&&~this.isCreatingForSubsystemModel;
            group.Items{end+1}=rebuildOnOpenCheckbox;

            rebuildModelDataCheckbox=this.addHarnesRebuildModelDataUI();
            rebuildModelDataCheckbox.RowSpan=[2,2];
            rebuildModelDataCheckbox.ColSpan=[1,1];
            rebuildModelDataCheckbox.Enabled=~this.isCreatingForLibrary&&~this.isCreatingForSubsystemModel;
            group.Items{end+1}=rebuildModelDataCheckbox;


            editBox.Name=DAStudio.message('Simulink:Harness:PostRebuildCBTitle');
            editBox.Type='edit';
            editBox.Mode=true;
            editBox.RowSpan=[3,3];
            editBox.ColSpan=[1,1];
            editBox.ObjectProperty='postRebuildCallBack';
            editBox.Tag='HarnessCreateDlgPostRebuildCBTag';
            group.Items{end+1}=editBox;

        end

        function group=addSyncOptionsUI(this)
            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessSyncOpts');
            group.LayoutGrid=[1,1];
            if this.isCreatingForZCModel
                synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessSyncMode',...
                'synchronizationModeTag',...
                this.syncComponentModeEntriesZC,...
                this.syncComponentModeValuesZC);
            elseif this.isCreatingForLibrary||this.isCreatingForSubsystemModel
                synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessSyncMode',...
                'synchronizationModeTag',...
                this.syncComponentModeEntriesLib,...
                this.syncComponentModeValuesLib);
            elseif(isa(this.harnessOwner,'Simulink.SubSystem')||...
                isa(this.harnessOwner,'Simulink.ModelReference')||...
                Simulink.harness.internal.isUserDefinedFcnBlock(this.harnessOwner.Handle))&&...
                ~this.isCreatingForImplicitLink&&...
                this.verificationMode==0
                synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessSyncMode',...
                'synchronizationModeTag',...
                this.syncComponentModeEntriesAll,...
                this.syncComponentModeValuesAll);
            else
                synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessSyncMode',...
                'synchronizationModeTag',...
                this.syncComponentModeEntriesLimited,...
                this.syncComponentModeValuesLimited);
            end
            synchronizationModecombobox.ObjectProperty='syncComponent';

            synchronizationModecombobox.Enabled=this.verificationMode==0&&...
            ~this.isCreatingForImplicitLink&&~this.isCreatingForSubsystemModel&&~this.isCreatingForZCModel;
            group.Items={synchronizationModecombobox};
        end

        function graphicalCheckbox_cb(this)
            if this.graphicalHarnessFlag
                this.verificationMode=0;
            end
        end




        function panel=addHarnessOptionsUI(this)
            panel.Type='panel';
            panel.Items={this.addHarnessActivationUI()};
        end

        function selectorGroup=addContextSelectorUI(this)
            selector.Type='combobox';
            selector.Entries=this.ccList;
            selector.Values=1:length(this.ccList);
            selector.ObjectProperty='selIdx';
            selector.ObjectMethod='selectionChanged_cb';
            selector.DialogRefresh=true;
            selector.MethodArgs={'%dialog'};
            selector.ArgDataTypes={'handle'};
            selector.Mode=true;
            selector.Tag='CodeContextSelector';
            selector.RowSpan=[1,1];
            selector.ColSpan=[1,3];

            selectorGroup.Type='group';
            selectorGroup.Name=DAStudio.message('Simulink:CodeContext:ContextSelectDialogSelector');
            selectorGroup.Items={selector};
            selectorGroup.Tag='CodeContextSelectDlgDescGroupTag';
            selectorGroup.RowSpan=[4,4];
            selectorGroup.ColSpan=[1,3];
            selectorGroup.LayoutGrid=[1,3];
            selectorGroup.ColStretch=[0,1,0];
            selectorGroup.Visible=~isempty(this.ccList)&&...
            Simulink.harness.internal.isRLS(this.harnessOwner.Handle)&&...
            slfeature('RLSTestHarness')>0;
        end

        function selectionChanged_cb(this,dlg)


            if this.selIdx~=this.currIdx
                this.currIdx=this.selIdx;
                this.selectedContextName=this.ccList{this.selIdx};
                if~strcmp(this.selectedContextName,'None')
                    this.syncComponent=1;
                end
                dlg.refresh;
            end
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:CreateDialogTitle');
            schema.DialogTag='CreateSimulationHarnessDialog';

            tab1.Name=DAStudio.message('Simulink:Harness:PropertiesTab');
            nRow=1;
            basicProps=this.addBasicPropertiesUI();
            basicProps.RowSpan=[nRow,nRow];
            basicProps.ColSpan=[1,1];
            nRow=nRow+1;
            harnesssConfig=this.addHarnessConfigurationUI();
            harnesssConfig.RowSpan=[nRow,nRow];
            harnesssConfig.ColSpan=[1,1];
            nRow=nRow+1;
            tab1.Items={basicProps,harnesssConfig};

            if this.isCreatingForLibrary()
                tab1.Items{end+1}=this.addSyncOptionsUI();
                nRow=nRow+1;
            end

            if this.isCreatingForLibrary()||this.isCreatingForSubsystemModel()





                textBoxCB.Name=strcat('<i>',...
                DAStudio.message('Simulink:Harness:DefaultPostCreateCBTitle'),...
                {' '},'</i>',...
                this.defaultPostCreateCallBack);
                textBoxCB.ToolTip=DAStudio.message('Simulink:Harness:DefaultPostCreateCBTooltip');
                textBoxCB.Type='text';
                textBoxCB.Tag='HarnessCreateDlgDefaultPostCreateCBTag';
                textBoxCB.Visible=this.defaultPostCreateCallBack~="";
                textBoxCB.RowSpan=[nRow,nRow];
                textBoxCB.ColSpan=[1,1];
                tab1.Items{end+1}=textBoxCB;
                nRow=nRow+1;


                if textBoxCB.Visible



                    editBox.Name=DAStudio.message('Simulink:Harness:AdditionalPostCreateCBTitle');
                else
                    editBox.Name=DAStudio.message('Simulink:Harness:PostCreateCBTitle');
                end
                editBox.Type='edit';
                editBox.Mode=true;
                editBox.ObjectProperty='postCreateCallBack';
                editBox.Tag='HarnessCreateDlgPostCreateCBTag';
                editBox.RowSpan=[nRow,nRow];
                editBox.ColSpan=[1,1];
                tab1.Items{end+1}=editBox;
                nRow=nRow+1;


                hOutLoggingCheckbox=this.addHarnessOutputLoggingUI();
                hOutLoggingCheckbox.RowSpan=[nRow,nRow];
                hOutLoggingCheckbox.ColSpan=[1,1];
                hOutLoggingCheckbox.Enabled=true;
                hOutLoggingCheckbox.Visible=slfeature('HarnessOutputSignalLogging')>1;
                tab1.Items{end+1}=hOutLoggingCheckbox;
                nRow=nRow+1;
            end

            harnessOptnUI=this.addHarnessOptionsUI();
            harnessOptnUI.Enabled=~this.lockMainMdlSubsysOnHarnessOpenEnabled||isempty(this.getActiveHarness());
            harnessOptnUI.RowSpan=[nRow,nRow];
            harnessOptnUI.ColSpan=[1,1];
            nRow=nRow+1;
            tab1.Items{end+1}=harnessOptnUI;

            emptylbl1.Name='   ';
            emptylbl1.Type='text';
            emptylbl1.RowSpan=[nRow,nRow];
            emptylbl1.ColSpan=[1,1];

            tab1.Items{end+1}=emptylbl1;
            tab1.LayoutGrid=[nRow,1];
            tab1.RowStretch=[zeros(1,nRow-1),1];

            tab2.Name=DAStudio.message('Simulink:Harness:AdvancedOptions');

            createOptsGroup=this.addCreateOptionsUI();
            createOptsGroup.RowSpan=[1,1];
            createOptsGroup.ColSpan=[1,1];
            rebuildOptsGroup=this.addRebuildOptionsUI();
            rebuildOptsGroup.RowSpan=[2,1];
            rebuildOptsGroup.ColSpan=[1,1];

            syncOptsGroup=this.addSyncOptionsUI();
            syncOptsGroup.RowSpan=[3,1];
            syncOptsGroup.ColSpan=[1,1];

            emptylbl2.Name='   ';
            emptylbl2.Type='text';
            emptylbl2.RowSpan=[4,1];
            emptylbl2.ColSpan=[1,1];

            tab2.Items={createOptsGroup,rebuildOptsGroup,syncOptsGroup,emptylbl2};
            tab2.LayoutGrid=[4,1];
            tab2.RowStretch=[0,0,0,1];


            tab3.Name=DAStudio.message('Simulink:Harness:HarnessDescriptionTab');
            tab3.Items={this.addHarnessDescriptionUI()};

            tabs.Type='tab';
            if this.isCreatingForLibrary()||this.isCreatingForSubsystemModel

                tabs.Tabs={tab1,tab3};
            else
                tabs.Tabs={tab1,tab2,tab3};
            end

            tabs.Tag='CreateSimulationHarnessDialogTabs';

            panel.Type='panel';
            panel.Items={this.addDialogInstructionsUI(),tabs};
            panel.Tag='CreateSimulationHarnessDialogPanel';
            panel.Enabled=~this.readonly;

            schema.Items={panel};
            schema.ExplicitShow=true;

            schema.CloseMethod='dlgCloseMethod';

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};

            schema.HelpMethod='dlgHelpMethod';

            schema.IsScrollable=true;
            schema.DisableDialog=this.isHierarchyReadonly();

            schema.StandaloneButtonSet={'OK','Cancel','Help'};
        end









        function activeHarness=getActiveHarness(this)
            systemModel=Simulink.harness.internal.parseForSystemModel(this.harnessOwner.Handle);
            activeHarness=Simulink.harness.internal.getHarnessList(systemModel,'active');
        end

        function result=isHierarchyReadonly(this)

            if this.readonly
                result=true;
                return;
            end

            bd=bdroot(this.harnessOwner.Handle);
            restartStatus=get_param(bd,'InteractiveSimInterfaceExecutionStatus');

            if restartStatus~=2
                result=this.harnessOwner.isHierarchyReadonly||...
                this.harnessOwner.isHierarchySimulating||...
                this.harnessOwner.isHierarchyBuilding;
            else
                result=false;
            end
        end

        function show(this,dlg)

            if ispc
                width=max(675,dlg.position(3));
            else
                width=max(600,dlg.position(3));
            end
            height=dlg.position(4)+60;
            if isa(this.harnessOwner,'Simulink.BlockDiagram')
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Model');
            else
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Block',this.harnessOwner.Handle);
            end
            dlg.show();
        end

        function r=isCreatingForLibrary(this)
            modelName=bdroot(this.harnessOwner.getFullName());
            r=bdIsLibrary(modelName);
        end

        function r=isCreatingForSubsystemModel(this)
            modelName=bdroot(this.harnessOwner.getFullName());
            r=bdIsSubsystem(modelName);
        end

        function r=isCreatingForImplicitLink(this)
            r=false;
            if~isa(this.harnessOwner,'Simulink.BlockDiagram')
                r=Simulink.harness.internal.isImplicitLink(this.harnessOwner.Handle);
            end
        end

        function r=isCreatingForValidSILPILBlock(this)
            r=false;

            if(isa(this.harnessOwner,'Simulink.BlockDiagram')&&~this.isCreatingForLibrary()&&~this.isCreatingForSubsystemModel())||...
                isa(this.harnessOwner,'Simulink.SubSystem')||isa(this.harnessOwner,'Simulink.ModelReference')
                r=true;
            end
        end

        function r=isCreatingForZCModel(this)
            modelName=bdroot(this.harnessOwner.getFullName());
            r=Simulink.internal.isArchitectureModel(modelName);
        end
    end








    methods(Static)
        function create(harnessOwner)

            dlg=Simulink.harness.dialogs.findDialog('CreateSimulationHarnessDialog',harnessOwner);
            if~isempty(dlg)
                dlg.show();
                if dlg.isEnabled('HarnessCreateDlgNameEditTag')
                    dlg.setFocus('HarnessCreateDlgNameEditTag');
                else
                    dlg.setFocus('HarnessCreateDlgNameCBoxTag');
                end
                return
            end


            import Simulink.harness.dialogs.createDialog;
            src=createDialog(harnessOwner);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get_param(bdroot(harnessOwner.Handle),'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(hSrc,evnt)createDialog.onModelClose(hSrc,evnt,src,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',{@createDialog.onStatusChanged,src});
            src.hBlockDeleteListener=Simulink.listener(harnessOwner,'DeleteEvent',@(hSrc,evnt)createDialog.onBlockDelete(hSrc,evnt,src,dlg));
        end

        function onModelClose(~,~,src,dlg)

            src.forceClose=true;
            if ishandle(dlg)
                delete(dlg);
            end
        end

        function onStatusChanged(~,~,src)


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('ReadonlyChangedEvent',src,'');
        end

        function onBlockDelete(~,~,src,dlg)

            src.forceClose=true;
            if ishandle(dlg)
                delete(dlg);
            end
        end

    end
end

