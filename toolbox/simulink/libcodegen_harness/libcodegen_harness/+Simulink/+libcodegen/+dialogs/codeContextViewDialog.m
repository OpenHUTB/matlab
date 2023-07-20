classdef codeContextViewDialog<handle


    properties(SetObservable=true)
        ownerH=[];
        ccOwner='';
        mdlName='';
        mdlH=[];
        codeContextName='';
        newContextName='';
        rebuild=false;
        enableRefresh=false;
        configFPC=false;
        ccInfo='';
        libLocked=false;
        harnessDescription='';
        previewFilePath='';
        inputList={};
        outputList={};
        inports={};
        outports={};
        inputDataTypes={};
        inputDimensions={};
        inputSignalTypes={};
        outputDataTypes={};
        outputDimensions={};
        outputSignalTypes={};
        inputDataType='';
        outputDataType='';
        inputDimension='';
        outputDimension='';
        inputSignalType='';
        outputSignalType='';
        instanceFileName='';
        instanceModelName='';
        configSet='';
        cutName='';
        cutCandidates={};
        cutMap=containers.Map;
        specifyInstance=false;
        signalTypes={'auto','real','complex'};
        inputIdx=1;
        outputIdx=1;
        dtaItems={};
        unhiliteOnClose=false;
readOnly
hModelCloseListener
hModelStatusListener
studioApp
ID
        SubScriptions={}
    end

    methods

        function varType=getPropDataType(obj,varName)%#ok
            if strcmp(varName,'inputIdx')||...
                strcmp(varName,'outputIdx')
                varType='double';
            elseif strcmp(varName,'rebuild')||...
                strcmp(varName,'unhiliteOnClose')||...
                strcmp(varName,'configFPC')||...
                strcmp(varName,'enableRefresh')
                varType='bool';
            else
                varType='string';
            end
        end

        function setPropValue(obj,varName,varVal)
            if(strcmp(varName,'inputIdx'))
                obj.inputIdx=str2double(varVal);
            elseif(strcmp(varName,'outputIdx'))
                obj.outputIdx=str2double(varVal);
            elseif strcmp(varName,'inputDataType')
                obj.inputDataType=varVal;
                obj.inputDataTypes{obj.inputIdx}=obj.inputDataType;

            elseif strcmp(varName,'outputDataType')
                obj.outputDataType=varVal;
                obj.outputDataTypes{obj.outputIdx}=obj.outputDataType;
                obj.enableRefresh=true;
            elseif strcmp(varName,'inputSignalType')
                obj.inputSignalType=varVal;
                obj.inputSignalTypes{obj.inputIdx}=obj.inputSignalType;
                obj.enableRefresh=true;
            elseif strcmp(varName,'outputSignalType')
                obj.outputSignalType=varVal;
                obj.outputSignalTypes{obj.outputIdx}=obj.outputSignalType;
                obj.enableRefresh=true;
            elseif strcmp(varName,'inputDimension')
                obj.inputDimension=varVal;
                obj.inputDimensions{obj.inputIdx}=obj.inputDimension;
                obj.enableRefresh=true;
            elseif strcmp(varName,'outputDimension')
                obj.outputDimension=varVal;
                obj.outputDimensions{obj.outputIdx}=obj.outputDimension;
                obj.enableRefresh=true;
            elseif strcmp(varName,'rebuild')
                obj.rebuild=(varVal=='1');
            elseif strcmp(varName,'instanceFileName')
                obj.instanceFileName=varVal;
            elseif strcmp(varName,'instanceModelName')
                obj.instanceModelName=varVal;
            elseif strcmp(varName,'codeContextName')
                obj.codeContextName=varVal;
            elseif strcmp(varName,'cutName')
                obj.cutName=varVal;
            elseif strcmp(varName,'harnessDescription')


                obj.harnessDescription=varVal;
                obj.enableRefresh=true;
            else
                DAStudio.Protocol.setPropValue(obj,varName,varVal);
            end
        end

        function this=codeContextViewDialog(ownerH,name)
            this.ownerH=ownerH;
            this.ccOwner=get_param(this.ownerH,'Object');
            this.codeContextName=name;
            this.newContextName=name;
            this.mdlH=bdroot(ownerH);
            this.mdlName=getfullname(bdroot(ownerH));
            this.setup();

            builtIns=Simulink.DataTypePrmWidget.getBuiltinList('NumBool');
            this.dtaItems.builtinTypes=builtIns;
            this.dtaItems.scalingModes={'UDTBinaryPointMode','UDTSlopeBiasMode','UDTBestPrecisionMode'};
            this.dtaItems.signModes={'UDTSignedSign','UDTUnsignedSign'};

            this.dtaItems.supportsEnumType=true;
            this.dtaItems.supportsBusType=true;

            this.studioApp=SLM3I.SLDomain.getLastActiveStudioApp();
            this.readOnly=false;
        end

        function setup(this)
            this.clearFields();

            this.libLocked=strcmpi(get_param(this.mdlName,'Lock'),'on');

            this.ccInfo=Simulink.libcodegen.internal.loadCodeContext(this.ownerH,this.codeContextName);
            oc=onCleanup(@()close_system(this.codeContextName));
            activeCS=getActiveConfigSet(this.codeContextName);
            this.configSet=activeCS.copy();

            if~isempty(this.ccInfo.instanceModelName)&&isempty(this.instanceFileName)
                this.instanceFileName=this.ccInfo.instanceModelName;
                Simulink.libcodegen.dialogs.shared.InstanceFileNameCallback(this);

                if isempty(setdiff(this.ccInfo.instanceCUTName,this.cutCandidates))
                    this.cutName=this.ccInfo.instanceCUTName;
                end
            end

            this.harnessDescription=this.ccInfo.description;

            this.populateInputsAndOutputs();

            this.createInterfaceImage();
        end

        function clearFields(this)
            this.rebuild=false;
            this.enableRefresh=false;
            this.configFPC=false;
            this.specifyInstance=false;
            this.instanceFileName='';
            this.instanceModelName='';
            this.cutMap=containers.Map;
            this.cutCandidates={};
            this.cutName='';
        end

        function populateInputsAndOutputs(this)

            this.inports=find_system(this.codeContextName,'SearchDepth',1,...
            'BlockType','Inport');
            this.outports=find_system(this.codeContextName,'SearchDepth',1,...
            'BlockType','Outport');

            this.inputList=get_param(this.inports,'Name')';
            this.outputList=get_param(this.outports,'Name')';

            this.inputDataTypes=get_param(this.inports,'OutDataTypeStr');
            this.outputDataTypes=get_param(this.outports,'OutDataTypeStr');

            this.inputDimensions=get_param(this.inports,'PortDimensions');
            this.outputDimensions=get_param(this.outports,'PortDimensions');

            this.inputSignalTypes=get_param(this.inports,'SignalType');
            this.outputSignalTypes=get_param(this.outports,'SignalType');

            if~isempty(this.inputList)
                this.inputDataType=this.inputDataTypes{this.inputIdx};
                this.inputDimension=this.inputDimensions{this.inputIdx};
                this.inputSignalType=this.inputSignalTypes{this.inputIdx};
            end

            if~isempty(this.outputList)
                this.outputDataType=this.outputDataTypes{this.outputIdx};
                this.outputDimension=this.outputDimensions{this.outputIdx};
                this.outputSignalType=this.outputSignalTypes{this.outputIdx};
            end

        end


        function namepanel=addNameUI(this)
            name.Name=DAStudio.message('Simulink:CodeContext:CodeContextName');
            name.Type='edit';
            name.ObjectProperty='newContextName';
            name.Tag='CodeContextViewDlgNameTag';
            name.RowSpan=[1,1];
            name.ColSpan=[1,2];
            name.Enabled=~this.libLocked;
            name.Mode=true;
            name.DialogRefresh=true;

            lblCUT.Name=DAStudio.message('Simulink:CodeContext:CodeContextComponent');
            lblCUT.Type='text';
            lblCUT.Tag='CodeContextViewDlgCUTLblTag';
            lblCUT.RowSpan=[2,2];
            lblCUT.ColSpan=[1,1];

            cut.Name=getfullname(this.ownerH);
            cut.Type='hyperlink';
            cut.Alignment=1;
            cut.Tag='CodeContextViewDlgOwnerLinkTag';
            cut.ToolTip=DAStudio.message('Simulink:CodeContext:CodeContextOwnerTooltip');
            cut.ObjectMethod='hiliteOwner_cb';
            cut.RowSpan=[2,2];
            cut.ColSpan=[2,2];

            unlockbtn=Simulink.libcodegen.dialogs.shared.addUnlockLibraryButton(this,2,3);

            namepanel.Type='group';
            namepanel.RowSpan=[1,2];
            namepanel.ColSpan=[1,6];
            namepanel.LayoutGrid=[2,6];
            namepanel.Items={name,lblCUT,cut,unlockbtn};
            namepanel.ColStretch=[0,0,0,0,0,1];
        end




        function interfaceGroup=addInterfaceUI(this)
            ioPreviewGroup=this.addIOAndPreviewPanel();
            rebuildGroup=this.addRebuildGroup();

            interfaceGroup.Type='panel';
            interfaceGroup.Items={ioPreviewGroup,rebuildGroup};
            interfaceGroup.Tag='CodeContextViewInterfaceGroupTag';
            interfaceGroup.RowSpan=[1,8];
            interfaceGroup.ColSpan=[1,6];
            interfaceGroup.LayoutGrid=[8,6];
            interfaceGroup.ColStretch=[0,0,1,1,0,0];
            interfaceGroup.Enabled=~this.libLocked;
        end


        function editArea=addCodeContextDescriptionUI(this)
            editArea.Name=DAStudio.message('Simulink:CodeContext:CodeContextDescription');
            editArea.Type='editarea';
            editArea.MinimumSize=[0,1];
            editArea.WordWrap=true;
            editArea.ObjectProperty='harnessDescription';
            editArea.Tag='CodeContextViewDlgDescriptionTag';
            editArea.Enabled=~this.libLocked;
        end

        function ioPreviewGroup=addIOAndPreviewPanel(this)
            inputSelectorPanel=this.addInputSelectorGroup();
            graphicalGroup=this.addGraphicalGroup();
            outputSelectorPanel=this.addOutputSelectorGroup();

            ioPreviewGroup.Type='panel';
            ioPreviewGroup.Items={inputSelectorPanel,graphicalGroup,outputSelectorPanel};
            ioPreviewGroup.LayoutGrid=[4,6];
            ioPreviewGroup.RowSpan=[1,4];
            ioPreviewGroup.ColSpan=[1,6];
            ioPreviewGroup.RowStretch=[0,0,0,1];
        end

        function rebuildPanel=addRebuildGroup(this)

            rebuildCB=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:CodeContext:ContextViewDialogRebuild',...
            'rebuild',...
            'CodeContextViewContextRebuildCBTag');

            rebuildCB.Alignment=1;
            rebuildCB.RowSpan=[1,1];
            rebuildCB.ColSpan=[1,1];
            rebuildCB.Mode=true;
            rebuildCB.DialogRefresh=true;
            rebuildCB.Graphical=true;

            this.specifyInstance=this.rebuild;
            currRow=1;
            [instanceGroup,~]=Simulink.libcodegen.dialogs.shared.createInstanceInfoWidget(this,currRow);
            instanceGroup.RowSpan=[1,2];
            instanceGroup.ColSpan=[1,3];

            rebuildButton=this.addRebuildButton();
            rebuildButton.RowSpan=[3,3];
            rebuildButton.ColSpan=[1,1];
            rebuildButton.Alignment=1;
            rebuildButton.Enabled=this.specifyInstance&&~isempty(this.instanceFileName)&&...
            exist(this.instanceFileName,'file')&&~isempty(this.cutName);

            rebuildGroup.Type='panel';
            rebuildGroup.Name='';
            rebuildGroup.Items={instanceGroup,rebuildButton};
            rebuildGroup.LayoutGrid=[3,4];
            rebuildGroup.RowSpan=[2,4];
            rebuildGroup.ColSpan=[1,4];
            rebuildGroup.Enabled=this.rebuild;
            rebuildGroup.Alignment=2;

            rebuildPanel.Type='panel';
            rebuildPanel.LayoutGrid=[4,6];
            rebuildPanel.RowSpan=[5,8];
            rebuildPanel.ColSpan=[1,6];
            rebuildPanel.Items={rebuildCB,rebuildGroup};
            rebuildPanel.ColStretch=[0,0,0,0,0,1];
        end

        function selectorGroup=addInputSelectorGroup(this)

            if~isempty(this.inputList)
                selector=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:CodeContext:ContextViewDialogInports',...
                'CodeContextViewDialogInputSelector',...
                this.inputList,...
                1:length(this.inputList));
                selector.ObjectProperty='inputIdx';
                selector.RowSpan=[1,1];
                selector.ColSpan=[1,2];
                selector.ObjectMethod='inputSelect_cb';
                selector.Graphical=true;

                datatype=Simulink.DataTypePrmWidget.getDataTypeWidget(this,...
                'inputDataType',...
                DAStudio.message('Simulink:CodeContext:ContextViewDialogDataType'),...
                'CodeContextViewDialogInDataTypeEdit',...
                this.inputDataType,...
                this.dtaItems,...
                false);
                datatype.RowSpan=[1,1];
                datatype.ColSpan=[1,2];
                datatype.Items{2}.Mode=true;
                datatype.Items{2}.DialogRefresh=true;
                datatype.Items{3}.Visible=0;

                dimEdit.Type='edit';
                dimEdit.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogDimensions');
                dimEdit.ObjectProperty='inputDimension';
                dimEdit.Mode=true;
                dimEdit.Tag='CodeContextViewDialogDimensionEdit';
                dimEdit.Alignment=1;
                dimEdit.RowSpan=[2,2];
                dimEdit.ColSpan=[1,2];

                signaltype=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:CodeContext:ContextViewDialogSignalType',...
                'CodeContextViewDialogInputSignalTypeEdit',...
                this.signalTypes,...
                1:length(this.signalTypes));
                signaltype.ObjectProperty='inputSignalType';
                signaltype.RowSpan=[3,3];
                signaltype.ColSpan=[1,2];
                signaltype.Mode=true;

                selectorGroup.Type='group';
                subGroup.Type='group';
                subGroup.Items={datatype,dimEdit,signaltype};
                subGroup.RowSpan=[2,4];
                subGroup.ColSpan=[1,2];
                subGroup.Alignment=2;

                selectorGroup.Items={selector,subGroup};
                selectorGroup.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogInputs');
                selectorGroup.LayoutGrid=[4,2];
                selectorGroup.RowSpan=[1,4];
                selectorGroup.ColSpan=[1,2];
                selectorGroup.Tag='CodeContextViewDlgInputGroupTag';
            else
                selectorGroup.Type='group';
                selectorGroup.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogInputs');
                text.Type='text';
                text.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogNoInputs');
                selectorGroup.RowSpan=[1,4];
                selectorGroup.ColSpan=[1,2];
                selectorGroup.Alignment=0;
                selectorGroup.Items={text};
            end

            selectorGroup.RowStretch=[0,0,0,1];
            selectorGroup.Enabled=~this.rebuild;
        end

        function graphicalGroup=addGraphicalGroup(this)
            preview.Type='image';
            preview.FilePath=this.previewFilePath();
            preview.Tag='CodeContextViewDlgPreviewImageTag';
            preview.RowSpan=[1,4];
            preview.ColSpan=[1,2];
            preview.MinimumSize=[150,150];
            preview.MaximumSize=[300,300];
            preview.Alignment=2;
            configBtn=this.addConfigSetButton();


            graphicalGroup.Type='group';
            graphicalGroup.Items={preview,configBtn};
            graphicalGroup.LayoutGrid=[4,2];
            graphicalGroup.RowSpan=[1,4];
            graphicalGroup.ColSpan=[3,4];
        end

        function btn=addRebuildButton(~)
            btn.Type='pushbutton';
            btn.Tag='CodeContextViewDlgRebuildBtn';
            btn.ObjectMethod='rebuildContext';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
            btn.RowSpan=[1,1];
            btn.ColSpan=[1,1];
            btn.Alignment=1;
            btn.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogRebuildButton');
        end

        function dlgHelpMethod(~)
            try
                mapFile=fullfile(docroot,'ecoder','helptargets.map');
                helpview(mapFile,'functionInterfaceConfigHelp');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
        end

        function updateNameAndDescription(this,dlg)
            if~isequal(this.codeContextName,this.newContextName)
                if~isempty(which(this.newContextName))&&...
                    ~isequal(this.newContextName,bdroot)&&...
                    isempty(find_system('SearchDepth',0,'type','block_diagram','Name',this.newContextName))
                    warnStr=DAStudio.message('Simulink:CodeContext:WarnAboutNameShadowingOnUpdate');
                    title=DAStudio.message('Simulink:CodeContext:WarnAboutNameShadowingOnCreationTitle');
                    choice=questdlg(warnStr,title,'Continue','Cancel','Continue');
                    if~strcmp(choice,'Continue')
                        this.newContextName=this.codeContextName;
                        DAStudio.error('Simulink:CodeContext:UpdateAbortedFileShadow');
                    end
                end
            end
            Simulink.libcodegen.internal.updateCodeContext(this.ownerH,this.codeContextName,'Description',...
            this.harnessDescription,'Name',this.newContextName);
            this.codeContextName=this.newContextName;
            dlg.enableApplyButton(false);
        end

        function configBtn=addConfigSetButton(~)
            configBtn.Type='pushbutton';
            configBtn.FilePath=[matlabroot,'/toolbox/simulinktest/core/simharness/simharness/'...
            ,'+Simulink/+harness/resources/Configuration.png'];
            configBtn.Tag='CodeContextViewDlgOpenConfigBtn';
            configBtn.ObjectMethod='openConfig_cb';
            configBtn.MethodArgs={'%dialog'};
            configBtn.ArgDataTypes={'handle'};
            configBtn.RowSpan=[4,4];
            configBtn.ColSpan=[2,2];
            configBtn.Alignment=10;
            configBtn.ToolTip=DAStudio.message('Simulink:CodeContext:ContextViewDialogOpenConfigSetButton');
        end

        function selectorGroup=addOutputSelectorGroup(this)

            if~isempty(this.outputList)
                selector=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:CodeContext:ContextViewDialogOutports',...
                'CodeContextViewDialogOutputSelector',...
                this.outputList,...
                1:length(this.outputList));
                selector.ObjectProperty='outputIdx';
                selector.RowSpan=[1,1];
                selector.ColSpan=[1,2];
                selector.ObjectMethod='outputSelect_cb';
                selector.Graphical=true;

                datatype=Simulink.DataTypePrmWidget.getDataTypeWidget(this,...
                'outputDataType',...
                DAStudio.message('Simulink:CodeContext:ContextViewDialogDataType'),...
                'CodeContextViewDialogOutDataTypeEdit',...
                this.outputDataType,...
                this.dtaItems,...
                false);
                datatype.Items{2}.Mode=true;
                datatype.Items{2}.DialogRefresh=true;
                datatype.Items{3}.Visible=0;
                datatype.RowSpan=[1,1];
                datatype.ColSpan=[1,2];

                dimEdit.Type='edit';
                dimEdit.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogDimensions');
                dimEdit.ObjectProperty='outputDimension';
                dimEdit.Mode=true;
                dimEdit.Tag='CodeContextViewDialogOutDimensionEdit';
                dimEdit.Alignment=2;
                dimEdit.RowSpan=[2,2];
                dimEdit.ColSpan=[1,2];

                signaltype=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:CodeContext:ContextViewDialogSignalType',...
                'CodeContextViewDialogOutputSignalTypeEdit',...
                this.signalTypes,...
                1:length(this.signalTypes));
                signaltype.ObjectProperty='outputSignalType';
                signaltype.RowSpan=[3,3];
                signaltype.ColSpan=[1,2];
                signaltype.Mode=true;

                selectorGroup.Type='group';
                subGroup.Type='group';
                subGroup.Items={datatype,dimEdit,signaltype};
                subGroup.RowSpan=[2,4];
                subGroup.ColSpan=[1,2];
                subGroup.Alignment=2;

                selectorGroup.Items={selector,subGroup};
                selectorGroup.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogOutputs');
                selectorGroup.LayoutGrid=[4,2];
                selectorGroup.RowSpan=[1,4];
                selectorGroup.ColSpan=[5,6];
                selectorGroup.Tag='CodeContextViewDlgOutputGroupTag';
            else
                selectorGroup.Type='group';
                selectorGroup.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogOutputs');
                text.Type='text';
                text.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogNoOutputs');
                selectorGroup.Items={text};
                selectorGroup.RowSpan=[1,4];
                selectorGroup.ColSpan=[5,6];
                selectorGroup.Flat=true;
                selectorGroup.Alignment=0;
            end
            selectorGroup.RowStretch=[0,0,0,1];
            selectorGroup.Enabled=~this.rebuild;
        end


        function inputSelect_cb(this)
            this.inputDataType=this.inputDataTypes{this.inputIdx};
            this.inputDimension=this.inputDimensions{this.inputIdx};
            this.inputSignalType=this.inputSignalTypes{this.inputIdx};

        end

        function outputSelect_cb(this)
            this.outputDataType=this.outputDataTypes{this.outputIdx};
            this.outputDimension=this.outputDimensions{this.outputIdx};
            this.outputSignalType=this.outputSignalTypes{this.outputIdx};
        end

        function openConfig_cb(this,dlg)
            this.configSet.openDialog();
            dlg.enableApplyButton(true);
            dlg.refresh();
        end

        function hiliteOwner_cb(this)
            try
                open_system(bdroot(this.ownerH));
                hilite(this.ccOwner);
                this.unhiliteOnClose=true;
            catch ME
                Simulink.harness.internal.error(ME,true);
            end
        end

        function unlocklibrary_cb(this,~)
            set_param(this.mdlH,'Lock','off');
        end

        function[status,msg]=rebuildContext(this,dlg)
            status=false;
            try
                this.updateNameAndDescription(dlg);
                Simulink.libcodegen.internal.setContextOpen(this.mdlName,this.ownerH,this.codeContextName,false);
                openCleanup=onCleanup(@()Simulink.libcodegen.internal.setContextOpen(this.mdlName,this.ownerH,this.codeContextName,true));
                [status,msg,this.ccInfo]=Simulink.libcodegen.dialogs.shared.createContextFromDialog(this);
                if status
                    this.deliverRebuildNotification();
                end
            catch me
                msg=me.message;
            end

            this.setup();
            dlg.refresh();

        end

        function refreshContext(this,dlg)
            Simulink.libcodegen.internal.setContextOpen(this.mdlName,this.ownerH,this.codeContextName,false);
            this.ccInfo=Simulink.libcodegen.internal.loadCodeContext(this.ownerH,this.codeContextName);
            loadCleanup=onCleanup(@()close_system(this.codeContextName,0));
            openCleanup=onCleanup(@()Simulink.libcodegen.internal.setContextOpen(this.mdlName,this.ownerH,this.codeContextName,true));
            origCS=getActiveConfigSet(this.codeContextName);
            if~origCS.isequal(this.configSet)
                origName=origCS.Name;
                origCS.Name=this.codeContextName;
                this.configSet.Name=origName;
                attachConfigSet(this.codeContextName,this.configSet);
                setActiveConfigSet(this.codeContextName,this.configSet.Name);
                detachConfigSet(this.codeContextName,origCS.Name);
            end
            for i=1:length(this.inports)
                set_param(this.inports{i},'OutDataTypeStr',this.inputDataTypes{i});
                set_param(this.inports{i},'PortDimensions',this.inputDimensions{i});
                set_param(this.inports{i},'SignalType',this.inputSignalTypes{i});
            end
            for i=1:length(this.outports)
                set_param(this.outports{i},'OutDataTypeStr',this.outputDataTypes{i});
                set_param(this.outports{i},'PortDimensions',this.outputDimensions{i});
                set_param(this.outports{i},'SignalType',this.outputSignalTypes{i});
            end

            this.updateNameAndDescription(dlg);
            clear loadCleanup;

            this.setup();
            dlg.refresh;

        end

        function deliverRebuildNotification(this)
            allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            studio=allStudios(1);
            editor=studio.App.getActiveEditor();
            editorName=editor.getName();
            editor=GLUE2.Util.findAllEditors(editorName);
            editor.deliverInfoNotification('Simulink:CodeContext:rebuildContext',...
            DAStudio.message('Simulink:CodeContext:ContextViewDialogRebuildSuccessful',...
            this.ccInfo.name,[this.instanceModelName,'/',this.cutName]));
        end

        function createInterfaceImage(this)
            if isempty(this.previewFilePath)
                this.previewFilePath=Simulink.libcodegen.internal.createInterfaceImage(this);
            end
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:CodeContext:ContextViewDialogTitle');
            schema.DialogTag=['CodeContextViewDlgTag',this.codeContextName];
            schema.LayoutGrid=[10,6];

            panel.Type='panel';
            panel.Tag='CodeContextViewDialogMainPanel';
            tab1.Items={this.addInterfaceUI()};
            tab1.Name=DAStudio.message('Simulink:CodeContext:ContextViewDialogInterface');
            tab2.Items={this.addCodeContextDescriptionUI()};
            tab2.Name=DAStudio.message('Simulink:CodeContext:CodeContextDescriptionTab');

            tabs.Type='tab';
            tabs.Tag='CodeContextViewDialogTabs';
            tabs.Tabs={tab1,tab2};

            panel.Items={this.addNameUI(),tabs};
            schema.Items={panel};

            schema.ExplicitShow=true;
            schema.IsScrollable=0;

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};
            schema.HelpMethod='dlgHelpMethod';
            schema.StandaloneButtonSet={'OK','Cancel','Help','Apply'};
            schema.CloseMethod='dlgCloseMethod';
        end

        function[status,msg]=dlgPostApplyMethod(this,dlg)
            status=true;
            msg='';
            try
                this.refreshContext(dlg);
            catch me
                msg=me.message;
                status=false;
            end
        end

        function dlgCloseMethod(this)
            for i=1:length(this.SubScriptions)
                message.unsubscribe(this.SubScriptions{i});
            end
            close_system(this.codeContextName,0);

            if this.unhiliteOnClose
                hilite(this.ccOwner,'none');
            end

            if~this.libLocked
                set_param(this.mdlName,'Lock','off');
            end

            if~isempty(this.ccInfo)
                Simulink.libcodegen.internal.setContextOpen(this.mdlName,this.ownerH,this.codeContextName,false);
            end
        end

        function show(this,dlg)

            if ispc
                width=max(675,dlg.position(3));
            else
                width=max(600,dlg.position(3));
            end
            height=dlg.position(4);

            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Block',this.ownerH);
            dlg.show();
            Simulink.libcodegen.internal.setContextOpen(this.mdlName,this.ownerH,this.codeContextName,true);
        end

        function registerDAListeners(obj)
            bd=get_param(obj.mdlH,'Object');
            bd.registerDAListeners;
        end
    end

    methods(Static)
        function create(ownerH,name,varargin)
            import Simulink.libcodegen.dialogs.codeContextViewDialog;

            configFPC=false;
            if nargin>2
                configFPC=varargin{1};
            end

            currDlgList=DAStudio.ToolRoot.getOpenDialogs();



            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,['CodeContextViewDlgTag',name])&&...
                    strcmp(currSrc.mdlName,getfullname(bdroot(ownerH)))
                    currDlg.show();
                    return;
                elseif isa(currSrc,'Simulink.libcodegen.dialogs.codeContextViewDialog')&&...
                    strcmp(currSrc.mdlName,getfullname(bdroot(ownerH)))&&...
                    ~strcmp(currDlg.dialogTag,['CodeContextViewDlgTag',name])


                    DAStudio.error('Simulink:CodeContext:AnotherViewDialogOpen',name,currSrc.mdlName);
                end
            end

            src=codeContextViewDialog(ownerH,name);
            src.configFPC=configFPC;
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get_param(src.mdlName,'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(hSrc,ev)Simulink.libcodegen.dialogs.codeContextViewDialog.onModelClose(hSrc,ev,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'ReadonlyChangedEvent',{@Simulink.libcodegen.dialogs.shared.onReadOnlyChanged,src,dlg});
        end

        function onModelClose(~,~,dlg)

            if ishandle(dlg)
                delete(dlg);
            end
        end

    end
end
