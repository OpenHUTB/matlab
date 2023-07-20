



classdef updateDialog<handle

    properties(SetObservable=true)
        hilited=false;
harness
harnessDescription
graphicalRebuild
newHarnessName
        readonly=false;
hModelCloseListener
hModelStatusListener
hBlockDeleteListener
        forceClose=false
rebuildOnOpen
rebuildModelData
postRebuildCallback
syncComponent
verificationMode
        syncComponentModeEntriesAll={
        message('Simulink:Harness:SyncOptBothWays').getString,...
        message('Simulink:Harness:SyncOptOneWay').getString,...
        message('Simulink:Harness:SyncOptExplicitFull').getString};
        syncComponentModeValuesAll=[0,1,2];
        syncComponentModeEntriesLimited={
        message('Simulink:Harness:SyncOptOneWay').getString,...
        message('Simulink:Harness:SyncOptExplicitOneWay').getString};
        syncComponentModeValuesLimited=[1,2];
        syncComponentModeEntriesOpen={
        message('Simulink:Harness:SyncOptBothWays').getString,...
        message('Simulink:Harness:SyncOptOneWay').getString};
        syncComponentModeValuesOpen=[0,1];
        syncComponentModeEntriesZC={
        message('Simulink:Harness:SyncOptOneWay').getString};
        syncComponentModeValuesZC=[1];
enableDetailConfigPanel
        useGeneratedCodeFlag=false
        existingBuildFolder=''
    end

    methods

        function this=updateDialog(harness)
            this.harness=harness;
            this.newHarnessName=harness.name;
            this.harnessDescription=harness.description;
            this.graphicalRebuild=harness.graphical;
            this.rebuildOnOpen=harness.rebuildOnOpen;
            this.useGeneratedCodeFlag=(~isempty(harness.existingBuildFolder));
            this.existingBuildFolder=harness.existingBuildFolder;
            this.rebuildModelData=harness.rebuildModelData;
            this.postRebuildCallback=harness.postRebuildCallback;
            this.verificationMode=harness.verificationMode;
            this.syncComponent=harness.synchronizationMode;
        end





        function varType=getPropDataType(this,varName)%#ok
            switch(varName)
            case{'newHarnessName',...
                'harnessDescription',...
                'existingBuildFolder',...
                'postRebuildCallback'}
                varType='string';
            case 'harness'
                varType='struct';
            case{'graphicalRebuild',...
                'forceClose',...
                'rebuildOnOpen',...
                'rebuildModelData',...
                'useGeneratedCodeFlag',...
                'enableDetailConfigPanel'}
                varType='bool';
            case{'syncComponent',...
                'verificationMode'}
                varType='double';
            otherwise
                varType='other';
            end
        end

        function setPropValue(obj,varName,varVal)
            if strcmp(varName,'harnessDescription')


                obj.harnessDescription=varVal;
            elseif strcmp(varName,'postRebuildCallback')


                obj.postRebuildCallback=varVal;
            elseif strcmp(varName,'newHarnessName')
                obj.newHarnessName=varVal;
            elseif strcmp(varName,'existingBuildFolder')
                obj.existingBuildFolder=varVal;
            else
                DAStudio.Protocol.setPropValue(obj,varName,varVal);
            end
        end

        function ret=isBDorMRorLinked(this)
            isLinked=false;
            if strcmp(this.harness.ownerType,'Simulink.SubSystem')
                isLinked=strcmp(get_param(this.harness.ownerFullPath,'LinkStatus'),'resolved')||...
                strcmp(get_param(this.harness.ownerFullPath,'LinkStatus'),'inactive');
            end

            ret=strcmp(this.harness.ownerType,'Simulink.ModelReference')||...
            strcmp(this.harness.ownerType,'Simulink.BlockDiagram')||...
            isLinked;
        end

        function r=isOwnerImplicitLink(this)
            ownerHandle=get_param(this.harness.ownerFullPath,'Handle');
            r=false;
            if ishandle(ownerHandle)&&strcmp(get_param(ownerHandle,'Type'),'block')
                r=Simulink.harness.internal.isImplicitLink(ownerHandle);
            end
        end

        function dlgCloseMethod(this)
            if this.forceClose
                return
            end
            if this.hilited&&~strcmp(this.harness.ownerFullPath,this.harness.model)
                hilite_system(this.harness.ownerFullPath,'none');
            end
        end

        function setReadonly(this,dlg,val)
            this.readonly=val;
            dlg.setEnabled('UpdateSimulationHarnessDialogPanel',~val);
        end

        function[status,err]=dlgPostApplyMethod(this,dlg)%#ok
            status=false;
            err='';
            try

                if this.harness.verificationMode==0
                    if this.isOwnerImplicitLink()
                        this.syncComponent=1;
                    end
                else
                    this.syncComponent=2;
                end

                if this.syncComponent==0
                    syncModeArg='SyncOnOpenAndClose';
                elseif this.syncComponent==1
                    syncModeArg='SyncOnOpen';
                else
                    syncModeArg='SyncOnPushRebuildOnly';
                end

                wstate=warning('off','Simulink:Harness:WarnAboutNameShadowingOnCreationfromCMD');
                oc=onCleanup(@()warning(wstate));
                if~strcmp(this.harness.name,this.newHarnessName)
                    Simulink.harness.internal.validateHarnessName(this.harness.model,[],...
                    this.newHarnessName);
                end
                oc.delete;

                if~strcmp(this.harness.name,this.newHarnessName)&&...
                    ~isempty(which(this.newHarnessName))&&...
                    ~isequal(this.newHarnessName,this.harness.model)&&...
                    isempty(find_system('SearchDepth',0,'type','block_diagram','Name',this.newHarnessName))
                    warnStr=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnRename');
                    title=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnRenameTitle');


                    continueButton=DAStudio.message('Simulink:Harness:Continue');
                    cancelButton=DAStudio.message('Simulink:Harness:Cancel');
                    choice=questdlg(warnStr,title,continueButton,cancelButton,continueButton);
                    if~strcmp(choice,continueButton)
                        status=false;
                        err=DAStudio.message('Simulink:Harness:UpdateAborted');
                        return;
                    end
                end

                if(~this.useGeneratedCodeFlag)
                    this.existingBuildFolder='';
                else
                    if(isempty(this.existingBuildFolder))
                        DAStudio.error('Simulink:Harness:ExistingBuildFolderError');
                    else
                        if(~isfolder(this.existingBuildFolder))
                            DAStudio.error('Simulink:Harness:ExistingBuildFolderError');
                        end
                    end
                end

                existingBuildFolderArg=this.existingBuildFolder;

                Simulink.harness.set(this.harness.ownerFullPath,...
                this.harness.name,...
                'Description',this.harnessDescription,...
                'RebuildOnOpen',this.rebuildOnOpen,...
                'RebuildModelData',this.rebuildModelData,...
                'PostRebuildCallback',this.postRebuildCallback,...
                'RebuildWithoutCompile',this.graphicalRebuild,...
                'ExistingBuildFolder',existingBuildFolderArg,...
                'SynchronizationMode',syncModeArg,...
                'Name',this.newHarnessName);
                status=true;


                Simulink.harness.internal.refreshHarnessListDlg(this.harness.model);
            catch ME
                ME.throwAsCaller;
            end
        end

        function link_cb(this)
            if strcmp(this.harness.ownerFullPath,this.harness.model)
                open_system(this.harness.ownerFullPath);
            else
                this.hilited=true;
                hilite_system(this.harness.ownerFullPath);
            end
        end

        function browseBuildFolder_cb(this)
            directoryname=uigetdir('','Select the build folder for the existing code');
            if ischar(directoryname)
                this.existingBuildFolder=directoryname;
            end
        end

        function saveexthelp_cb(~)


            try
                helpview(fullfile(docroot,'sltest','helptargets.map'),'HarnessCreateDlgNameCBoxTag');
            catch me %#ok

            end
        end

        function dlgHelpMethod(~)
            try
                helpview(fullfile(docroot,'sltest','helptargets.map'),'harnessCreateHelp');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
        end








        function grp=addDialogInstructionsUI(this)
            lbl.Name=DAStudio.message('Simulink:Harness:UpdateDialogInstructions');
            lbl.Type='text';
            lbl.Alignment=2;
            lbl.WordWrap=true;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,2];

            lblCUT.Name=DAStudio.message('Simulink:Harness:CUT');
            lblCUT.Type='text';
            lblCUT.RowSpan=[2,2];
            lblCUT.ColSpan=[1,1];

            lnk.Name=this.harness.ownerFullPath;
            lnk.Type='hyperlink';
            lnk.Alignment=1;
            lnk.Tag='HarnessUpdateDlgOwnerLinkTag';
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
            lbl.Buddy='HarnessUpdateDlgNameEditTag';
            lbl.Alignment=1;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,1];

            edit.Type='edit';
            edit.ObjectProperty='newHarnessName';
            edit.Mode=true;
            edit.Tag='HarnessUpdateDlgNameEditTag';
            edit.RowSpan=[1,1];
            edit.ColSpan=[2,4];

            extHarnessVisible=true;
            if~Simulink.harness.internal.isSavedIndependently(this.harness.model)
                saveExt.Name=['<i>',DAStudio.message('Simulink:Harness:HarnessesSavedInternally'),'</i>'];
                saveExt.Tag='HarnessesSavedInternallyTag';
            else
                saveExt.Name=['<i>',DAStudio.message('Simulink:Harness:HarnessesSavedExternally'),'</i>'];
                saveExt.Tag='HarnessesSavedExternallyTag';
            end
            saveExt.Type='text';
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

            panel.Type='panel';
            panel.LayoutGrid=[2,4];
            panel.ColStretch=[0,0,0,1];
            panel.Items={lbl,edit,saveExt,saveExtHelp};
        end

        function editArea=addHarnessDescriptionUI(~)
            editArea.Name=DAStudio.message('Simulink:Harness:HarnessDescription');
            editArea.Type='editarea';
            editArea.WordWrap=true;

            editArea.ObjectProperty='harnessDescription';
            editArea.Tag='HarnessUpdateDlgDescriptionTag';
        end

        function group=addBasicPropertiesUI(this)
            group.Name=DAStudio.message('Simulink:Harness:BasicProperties');
            group.Type='group';
            group.Items={this.addHarnessNameUI()};
        end

        function panel=addHarnessSrcUI(this)

            txt.Name=DAStudio.message('Simulink:Harness:OriginalSource');
            txt.Type='text';
            txt.RowSpan=[1,1];
            txt.ColSpan=[1,1];

            src.Name=this.harness.origSrc;
            src.Type='text';
            src.Bold=true;
            src.RowSpan=[1,1];
            src.ColSpan=[2,2];

            panel.Type='panel';
            panel.LayoutGrid=[1,2];
            panel.ColStretch=[0,1];
            panel.Items={txt,src};
        end

        function panel=addHarnessSinkUI(this)
            txt.Name=DAStudio.message('Simulink:Harness:OriginalSink');
            txt.Type='text';
            txt.RowSpan=[1,1];
            txt.ColSpan=[1,1];

            snk.Name=this.harness.origSink;
            snk.Type='text';
            snk.Bold=true;
            snk.RowSpan=[1,1];
            snk.ColSpan=[2,2];

            panel.Type='panel';
            panel.LayoutGrid=[1,2];
            panel.ColStretch=[0,1];
            panel.Items={txt,snk};

            if strcmp(this.harness.origSrc,Simulink.harness.internal.TestHarnessSourceTypes.REACTIVE_TEST.name)

                panel.Visible=false;
            else
                panel.Visible=true;
            end

        end

        function group=addSrcSinkUI(this)
            group.Name=DAStudio.message('Simulink:Harness:HarnessConfig');
            group.Type='group';
            group.Items={...
            this.addHarnessSrcUI(),...
            this.addHarnessSinkUI()
            };
        end

        function cbox=addGraphicalHarnessUI(~)
            cbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:GraphicalRebuild',...
            'graphicalRebuild',...
            'HarnessUpdateDlgGraphicalRebuildCBoxTag');
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


        function group=addRebuildOptionsUI(this)
            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessRebuildOpts');
            group.Items={};
            group.LayoutGrid=[7,6];

            if this.isBDorMRorLinked()||this.harness.verificationMode==0
                group.Items{end+1}=this.addGraphicalHarnessUI();
            end

            harnessRebuildOnOpenCheckBox=this.addHarnesRebuildOnOpenUI();
            harnessRebuildOnOpenCheckBox.ColSpan=[1,6];
            group.Items{end+1}=harnessRebuildOnOpenCheckBox;

            generatedCodeGroup.Type='group';
            generatedCodeGroup.LayoutGrid=[2,6];
            generatedCodeGroup.Items={};

            if(isequal(this.harness.ownerType,'Simulink.SubSystem')&&this.verificationMode~=0)
                generatedCodeCheckBox=Simulink.harness.internal.getCheckBoxSrc(...
                'Simulink:Harness:GeneratedCodeForSILPILBlockRebuild',...
                'useGeneratedCodeFlag',...
                'UseExistingCodeTag');
                generatedCodeCheckBox.Enabled=true;
                generatedCodeCheckBox.Alignment=1;
                generatedCodeCheckBox.RowSpan=[3,3];
                generatedCodeCheckBox.ColSpan=[1,6];
                generatedCodeCheckBox.Visible=true;
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

            harnessRebuildDataCheckBox=this.addHarnesRebuildModelDataUI();
            harnessRebuildDataCheckBox.RowSpan=[5,5];
            harnessRebuildDataCheckBox.ColSpan=[1,1];
            group.Items{end+1}=harnessRebuildDataCheckBox;


            editBox.Name=DAStudio.message('Simulink:Harness:PostRebuildCBTitle');
            editBox.Type='edit';
            editBox.Mode=true;
            editBox.RowSpan=[6,6];
            editBox.ColSpan=[1,1];
            editBox.ObjectProperty='postRebuildCallback';
            editBox.Tag='HarnessUpdateDlgPostRebuildCBTag';

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
                enableGroup=false;
            elseif~strcmp(this.harness.ownerType,'Simulink.BlockDiagram')&&...
                ~this.isOwnerImplicitLink()&&...
                this.verificationMode==0
                if~this.harness.isOpen&&~this.isLibraryModel()
                    synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                    'Simulink:Harness:HarnessSyncMode',...
                    'synchronizationModeTag',...
                    this.syncComponentModeEntriesAll,...
                    this.syncComponentModeValuesAll);
                    enableGroup=true;
                elseif this.harness.synchronizationMode~=2
                    synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                    'Simulink:Harness:HarnessSyncMode',...
                    'synchronizationModeTag',...
                    this.syncComponentModeEntriesOpen,...
                    this.syncComponentModeValuesOpen);
                    enableGroup=true;
                else
                    synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                    'Simulink:Harness:HarnessSyncMode',...
                    'synchronizationModeTag',...
                    this.syncComponentModeEntriesAll,...
                    this.syncComponentModeValuesAll);
                    enableGroup=false;
                end
            else
                synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessSyncMode',...
                'synchronizationModeTag',...
                this.syncComponentModeEntriesLimited,...
                this.syncComponentModeValuesLimited);
                enableGroup=~this.harness.isOpen&&(this.verificationMode==0)&&...
                ~this.isOwnerImplicitLink();
            end
            synchronizationModecombobox.ObjectProperty='syncComponent';
            synchronizationModecombobox.Enabled=enableGroup;
            group.Items={synchronizationModecombobox};
        end



        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:UpdateDialogTitle',this.harness.name);
            schema.DialogTag='UpdateSimulationHarnessDialog';

            tab1.Name=DAStudio.message('Simulink:Harness:PropertiesTab');
            this.enableDetailConfigPanel=true;
            if~this.isLibraryModel()&&~this.isSubsystemModel()
                tab1.Items={...
                this.addBasicPropertiesUI(),...
                this.addSrcSinkUI(),...
                this.addRebuildOptionsUI(),...
                this.addSyncOptionsUI()};
            elseif this.isSubsystemModel()
                tab1.Items={...
                this.addBasicPropertiesUI(),...
                this.addSrcSinkUI()};
            else
                tab1.Items={...
                this.addBasicPropertiesUI(),...
                this.addSrcSinkUI(),...
                this.addSyncOptionsUI()};
            end

            tab2.Name=DAStudio.message('Simulink:Harness:HarnessDescriptionTab');
            tab2.Items={this.addHarnessDescriptionUI()};

            tabs.Type='tab';
            tabs.Tabs={tab1,tab2};
            tabs.Tag='UpdateSimulationHarnessDialogTabs';

            panel.Type='panel';
            panel.Tag='UpdateSimulationHarnessDialogPanel';
            panel.Items={this.addDialogInstructionsUI(),...
            tabs};
            panel.Enabled=~this.readonly;

            schema.Items={panel};
            schema.ExplicitShow=true;

            schema.CloseMethod='dlgCloseMethod';

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};

            schema.HelpMethod='dlgHelpMethod';

            schema.DisableDialog=this.isHierarchyReadonly();
            schema.IsScrollable=true;

            schema.StandaloneButtonSet={'OK','Cancel','Help'};
        end








        function result=isHierarchyReadonly(this)

            if this.readonly
                result=true;
                return;
            end
            obj=this.getAssociatedModel(this.harness);
            result=obj.isHierarchyReadonly||obj.isHierarchySimulating||obj.isHierarchyBuilding;
        end

        function r=isLibraryModel(this)
            ownerModelName=this.harness.model;
            r=bdIsLibrary(ownerModelName);
        end

        function r=isSubsystemModel(this)
            ownerModelName=this.harness.model;
            r=bdIsSubsystem(ownerModelName);
        end

        function r=isCreatingForZCModel(this)
            r=false;
            if Simulink.internal.isArchitectureModel(this.harness.model)
                r=true;
            end
        end

        function show(this,dlg)

            width=max(600,dlg.position(3));
            height=dlg.position(4)+30;
            if strcmp(this.harness.ownerFullPath,this.harness.model)
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Model');
            else
                dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Block',this.harness.ownerFullPath);
            end
            dlg.show();
        end
    end

    methods(Static)
        function create(harness)

            for dlg=DAStudio.ToolRoot.getOpenDialogs()'
                if strcmp(dlg.dialogTag,'UpdateSimulationHarnessDialog')
                    src=dlg.getSource();
                    if strcmp(src.harness.ownerFullPath,harness.ownerFullPath)...
                        &&strcmp(src.harness.name,harness.name)
                        dlg.show();
                        if dlg.isEnabled('HarnessUpdateDlgNameEditTag')
                            dlg.setFocus('HarnessUpdateDlgNameEditTag');
                        else
                            dlg.setFocus('HarnessUpdateDlgNameCBoxTag');
                        end
                        return
                    end
                end
            end


            import Simulink.harness.dialogs.updateDialog;
            src=updateDialog(harness);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            model=updateDialog.getAssociatedModel(harness);
            harnessOwner=get_param(harness.ownerFullPath,'Object');




            src.hModelCloseListener=Simulink.listener(model,'CloseEvent',@(s,e)updateDialog.onModelClose(s,e,src,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',{@updateDialog.onStatusChanged,src});
            src.hBlockDeleteListener=Simulink.listener(harnessOwner,'DeleteEvent',@(s,e)updateDialog.onBlockDelete(s,e,src,dlg));
        end

        function model=getAssociatedModel(harness)
            try

                model=get_param(harness.name,'Object');
            catch ME
                if strcmp(ME.identifier,'Simulink:Commands:InvSimulinkObjectName')

                    model=get_param(harness.model,'Object');
                else
                    rethrow(ME);
                end
            end
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


