

classdef importDialog<handle
    properties(SetObservable=true)
harnessOwner
defaultName
harnessName
saveExternally
harnessFilePath
harnessFileName
importFileName
cutCandidates
cutName
cutMap
unhiliteOnClose
harnessDescription
rebuildOnOpen
rebuildModelData
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

hModelCloseListener
hModelStatusListener
hBlockDeleteListener
        forceClose=false
    end

    methods
        function this=importDialog(harnessOwner)
            this.harnessOwner=harnessOwner;

            this.defaultName=Simulink.harness.internal.getDefaultName(...
            bdroot(this.harnessOwner.Path),this.harnessOwner.getFullName());

            this.harnessName=this.defaultName;
            this.saveExternally=false;
            [path,~,ext]=fileparts(get_param(bdroot(this.harnessOwner.Path),'FileName'));
            if strcmp(ext,'.mdl')
                this.saveExternally=true;
            end
            this.harnessFilePath=path;
            this.harnessFileName=fullfile(path,[this.harnessName,'.slx']);
            this.importFileName='';
            this.cutCandidates={};
            this.cutName='';
            this.cutMap=containers.Map;
            this.unhiliteOnClose=false;
            this.harnessDescription='';
            this.rebuildOnOpen=false;
            this.rebuildModelData=false;
            if this.isImportingForImplicitLink||this.isLibraryModel()||...
                this.isSubsystemModel()
                this.syncComponent=1;
            elseif this.isSubsystemRefBlk()
                this.syncComponent=0;
            else
                this.syncComponent=2;
            end
        end

        function varType=getPropDataType(obj,varName)%#ok
            switch(varName)
            case{'saveExternally',...
                'unhiliteOnClose',...
                'rebuildOnOpen',...
                'rebuildModelData'}
                varType='bool';
            case 'syncComponent'
                varType='double';
            case{'importFileName',...
                'harnessName',...
                'cutName',...
                'harnessDescription',...
                'harnessFileName',...
                'harnessFilePath'}
                varType='string';
            otherwise
                varType='other';
            end
        end

        function setPropValue(obj,varName,varVal)
            if strcmp(varName,'saveExternally')
                obj.saveExternally=(varVal=='1');
            elseif strcmp(varName,'importFileName')
                obj.importFileName=varVal;
            elseif strcmp(varName,'harnessFileName')
                obj.harnessFileName=varVal;
            elseif strcmp(varName,'harnessFilePath')
                obj.harnessFilePath=varVal;
            elseif strcmp(varName,'harnessName')
                obj.harnessName=varVal;
            elseif strcmp(varName,'cutName')
                obj.cutName=varVal;
            elseif strcmp(varName,'harnessDescription')


                obj.harnessDescription=varVal;
            elseif strcmp(varName,'rebuildOnOpen')
                obj.rebuildOnOpen=(varVal=='1');
            elseif strcmp(varName,'rebuildModelData')
                obj.rebuildModelData=(varVal=='1');
            elseif strcmp(varName,'syncComponent')
                obj.syncComponent=str2double(varVal);
            end
        end

        function dlgDescGroup=addDialogDescriptionUI(this)
            lbl.Name=DAStudio.message('Simulink:Harness:ImportDialogInstructions');
            lbl.Type='text';
            lbl.Tag='HarnessImportDescLblTag';
            lbl.Alignment=2;
            lbl.WordWrap=true;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,2];

            lblCUT.Name=DAStudio.message('Simulink:Harness:CUT');
            lblCUT.Type='text';
            lblCUT.Tag='HarnessImportCUTLblTag';
            lblCUT.RowSpan=[2,2];
            lblCUT.ColSpan=[1,1];

            lnk.Name=this.harnessOwner.getFullName();
            lnk.Type='hyperlink';
            lnk.Alignment=1;
            lnk.Tag='HarnessImportDlgOwnerLinkTag';
            lnk.ToolTip=DAStudio.message('Simulink:Harness:HarnessOwnerTooltip');
            lnk.ObjectMethod='link_cb';
            lnk.RowSpan=[2,2];
            lnk.ColSpan=[2,2];

            dlgDescGroup.Type='group';
            dlgDescGroup.LayoutGrid=[1,2];
            dlgDescGroup.RowSpan=[1,1];
            dlgDescGroup.ColStretch=[0,1];
            dlgDescGroup.Items={lbl,lblCUT,lnk};
            dlgDescGroup.Tag='HarnessImportDescGroupTag';
        end

        function[items,newRow]=addHarnessNameUI(this,currRow)
            lbl.Name=DAStudio.message('Simulink:Harness:HarnessName');
            lbl.Type='text';
            lbl.Buddy='HarnessImportDlgNameEditTag';
            lbl.Alignment=1;
            lbl.RowSpan=[currRow,currRow];
            lbl.ColSpan=[1,1];

            edit.Type='edit';
            edit.ObjectProperty='harnessName';
            edit.Mode=true;
            edit.ObjectMethod='harnessName_cb';
            edit.Tag='HarnessImportDlgNameEditTag';
            edit.RowSpan=[currRow,currRow];
            edit.ColSpan=[2,6];
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
                this.saveExternally=true;
            case Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_INTERNALLY
                saveExt.Name=['<i>',DAStudio.message('Simulink:Harness:HarnessesSavedInternally'),'</i>'];
                saveExt.Tag='HarnessesSavedInternallyTag';
                saveExt.Type='text';
                this.saveExternally=false;
            end
            saveExt.Alignment=1;
            currRow=currRow+1;
            saveExt.RowSpan=[currRow,currRow];
            saveExt.ColSpan=[2,3];
            saveExt.Visible=extHarnessVisible;

            saveExtHelp.Name=DAStudio.message('Simulink:Harness:HarnessesSavedExternallyHelp');
            saveExtHelp.Type='hyperlink';
            saveExtHelp.Tag='HarnessesSavedExternallyHelpTag';
            saveExtHelp.RowSpan=[currRow,currRow];
            saveExtHelp.ColSpan=[4,4];
            saveExtHelp.Visible=extHarnessVisible;
            saveExtHelp.ObjectMethod='saveexthelp_cb';

            currRow=currRow+1;
            saveExtFilePath.Name=DAStudio.message('Simulink:Harness:ExternalHarnessDirectory');
            saveExtFilePath.Type='edit';
            saveExtFilePath.ObjectProperty='harnessFilePath';
            saveExtFilePath.Tag='HarnessesSavedExternallyFilePathTag';
            saveExtFilePath.Mode=true;
            saveExtFilePath.Visible=this.saveExternally;
            saveExtFilePath.RowSpan=[currRow,currRow];
            saveExtFilePath.ColSpan=[2,5];

            saveExtBrowse.Type='pushbutton';
            saveExtBrowse.Name=DAStudio.message('Simulink:Harness:BrowseBtn');
            saveExtBrowse.Enabled=true;
            saveExtBrowse.MaximumSize=[80,40];
            saveExtBrowse.RowSpan=[currRow,currRow];
            saveExtBrowse.ColSpan=[6,6];
            saveExtBrowse.Tag='HarnessDirBrowseBtn';
            saveExtBrowse.Mode=true;
            saveExtBrowse.Visible=this.saveExternally;
            saveExtBrowse.DialogRefresh=true;
            saveExtBrowse.ObjectMethod='dirBrowseBtn_cb';

            panel.Type='panel';
            panel.LayoutGrid=[2,6];
            panel.ColStretch=[0,0,0,0,1,1];
            panel.Items={lbl,edit,saveExt,saveExtHelp,...
            saveExtFilePath,saveExtBrowse};

            group.Name='';
            group.Type='group';
            group.Items={panel};
            items={group};

            newRow=currRow+1;
        end

        function[group,newRow]=addFileAndCUTGroup(this,curRow)
            group.Name='';
            group.Type='group';
            group.Items={};
            [items,curRow]=this.addFileNameUI(curRow);
            group.Items={group.Items{:},items{:}};%#ok 
            [items,curRow]=this.addSpecifyCUTUI(curRow);
            group.Items={group.Items{:},items{:}};%#ok 
            group={group};
            newRow=curRow+1;
        end

        function[items,newRow]=addFileNameUI(~,curRow)
            lbl.Name=DAStudio.message('Simulink:Harness:ImportFileName');
            lbl.Type='text';
            lbl.Buddy='HarnessImportDlgNameLblTag';
            lbl.Alignment=1;
            lbl.RowSpan=[curRow,curRow];
            lbl.ColSpan=[1,1];

            edit.Type='edit';
            edit.ObjectProperty='importFileName';
            edit.Mode=true;
            edit.Tag='HarnessImportDlgFileNameEditTag';
            edit.RowSpan=[curRow,curRow];
            edit.ColSpan=[2,2];
            edit.DialogRefresh=true;
            edit.ObjectMethod='importFileName_cb';

            btn.Type='pushbutton';
            btn.Name=DAStudio.message('Simulink:Harness:BrowseBtn');
            btn.Enabled=true;
            btn.MaximumSize=[80,40];
            btn.RowSpan=[curRow,curRow];
            btn.ColSpan=[3,3];
            btn.Tag='HarnessImportFileBrowseBtn';
            btn.Mode=true;
            btn.DialogRefresh=true;
            btn.ObjectMethod='importBrowseBtn_cb';

            panel.Type='panel';
            panel.LayoutGrid=[1,3];
            panel.Items={lbl,edit,btn};

            items={panel};
            newRow=curRow+1;
        end

        function[items,newRow]=addSpecifyCUTUI(this,curRow)
            CUTCandidates=this.cutCandidates';
            numCandidates=length(CUTCandidates);
            CUTVals=zeros(1,numCandidates);
            for i=1:numCandidates
                CUTVals(i)=i;
            end

            specifyCUTCBox=Simulink.harness.internal.getComboBoxSrc(...
            'Simulink:Harness:ImportSpecifyCUT',...
            'HarnessImportDlgNameComboBoxTag',...
            CUTCandidates,...
            CUTVals);
            specifyCUTCBox.Mode=true;
            specifyCUTCBox.ObjectProperty='cutName';
            specifyCUTCBox.Alignment=0;
            specifyCUTCBox.Enabled=true;
            specifyCUTCBox.RowSpan=[curRow,curRow];
            specifyCUTCBox.ColSpan=[1,1];
            specifyCUTCBox.Visible=true;

            items={specifyCUTCBox};
            newRow=curRow+1;
        end

        function editArea=addHarnessDescriptionUI(~)
            editArea.Name=DAStudio.message('Simulink:Harness:HarnessDescription');
            editArea.Type='editarea';
            editArea.MinimumSize=[0,1];
            editArea.WordWrap=true;
            editArea.ObjectProperty='harnessDescription';
            editArea.Tag='HarnessImportDlgDescriptionTag';
        end

        function saveexthelp_cb(~)


            try
                helpview(fullfile(docroot,'sltest','helptargets.map'),'HarnessCreateDlgNameCBoxTag');
            catch me %#ok

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

        function importBrowseBtn_cb(this)
            [file,path]=uigetfile('*.slx; *.mdl',DAStudio.message('Simulink:Harness:SelectModel'));
            if~isequal(file,0)&&~isequal(path,0)
                this.importFileName=fullfile(path,file);
                populateDropdown(this);
            end
        end

        function dirBrowseBtn_cb(this)
            directoryname=uigetdir(this.harnessFilePath,DAStudio.message('Simulink:Harness:SelectDir'));
            if ischar(directoryname)
                this.harnessFilePath=directoryname;
            end
        end

        function importFileName_cb(this)
            if exist(this.importFileName,'file')
                [fullpath,~,ext]=fileparts(this.importFileName);
                if isempty(fullpath)||isempty(ext)
                    this.importFileName=which(this.importFileName);
                end
            end
            populateDropdown(this);
        end

        function populateDropdown(this)
            [~,importModelName,ext]=fileparts(this.importFileName);
            this.cutMap=containers.Map;
            if exist(this.importFileName,'file')&&...
                (strcmp(ext,'.slx')||strcmp(ext,'.mdl'))
                try
                    bd=find_system('type','block_diagram','Name',importModelName);
                    if isempty(bd)
                        load_system(this.importFileName);
                        oc=onCleanup(@()close_system(importModelName,0));
                    end
                    blockList=getBlockList(this);
                    blkNames=get_param(blockList,'Name');
                    blkNamesNoNL=strrep(blkNames,sprintf('\n'),' ');
                    this.cutCandidates=blkNamesNoNL;
                    for i=1:length(blkNames)
                        this.cutMap(this.cutCandidates{i})=blkNames{i};
                    end
                catch me %#ok

                end
            end

        end

        function harnessName_cb(this)
            this.harnessFileName=fullfile(this.harnessFilePath,[this.harnessName,'.slx']);
        end

        function interface=getBlockInterface(~,blockH)
            portHandles=get_param(blockH,'PortHandles');
            interface.numInputs=length(portHandles.Inport);
            interface.numOutputs=length(portHandles.Outport);
            interface.numEnable=length(portHandles.Enable);
            interface.numTrigger=length(portHandles.Trigger);
            interface.numState=length(portHandles.State);
            interface.numLConn=length(portHandles.LConn);
            interface.numRConn=length(portHandles.RConn);
            interface.Ifaction=length(portHandles.Ifaction);
            interface.Reset=length(portHandles.Reset);
        end

        function blkNames=getBlockList(this)
            [~,importModelName,~]=fileparts(this.importFileName);
            convSS={sprintf('%s/Output\nConversion\nSubsystem',importModelName);...
            sprintf('%s/Input\nConversion\nSubsystem',importModelName)};


            blockList2=find_system(importModelName,...
            'SearchDepth',1,...
            'BlockType','SubSystem');

            blockList2=setdiff(blockList2,convSS);


            blockList3=find_system(importModelName,...
            'SearchDepth',1,...
            'BlockType','ModelReference');


            blockList4=find_system(importModelName,...
            'SearchDepth',1,...
            'BlockType','S-Function');
            blockList5=find_system(importModelName,...
            'SearchDepth',1,...
            'BlockType','M-S-Function');
            blockList6=find_system(importModelName,...
            'SearchDepth',1,...
            'BlockType','MATLABSystem');
            blockList7=find_system(importModelName,...
            'SearchDepth',1,...
            'BlockType','FMU');
            blockList8=cell(0,1);
            if slfeature('CustomCodeIntegrationHarness')>0
                blockList8=find_system(importModelName,...
                'SearchDepth',1,...
                'BlockType','CCaller');
            end


            if isa(this.harnessOwner,'Simulink.SubSystem')
                blkNames=[blockList2;blockList3;blockList4;blockList5;blockList6;blockList7;blockList8];
            elseif isa(this.harnessOwner,'Simulink.ModelReference')||...
                isa(this.harnessOwner,'Simulink.BlockDiagram')

                blkNames=[blockList2;blockList3];
            elseif strcmp(this.harnessOwner.BlockType,'S-Function')
                blkNames=blockList4;
            elseif strcmp(this.harnessOwner.BlockType,'M-S-Function')
                blkNames=blockList5;
            elseif strcmp(this.harnessOwner.BlockType,'MATLABSystem')
                blkNames=blockList6;
            elseif strcmp(this.harnessOwner.BlockType,'FMU')
                blkNames=blockList7;
            elseif strcmp(this.harnessOwner.BlockType,'CCaller')
                blkNames=blockList8;
            end


            tmpList={};
            if~isa(this.harnessOwner,'Simulink.BlockDiagram')&&length(blkNames)>1
                ownerInterface=getBlockInterface(this,this.harnessOwner.Handle);
                ownerName=get_param(this.harnessOwner.Handle,'Name');
                ownerType=get_param(this.harnessOwner.Handle,'BlockType');
                for i=1:length(blkNames)
                    candidateInterface=getBlockInterface(this,...
                    get_param(blkNames{i},'Handle'));
                    candidateType=get_param(blkNames{i},'BlockType');
                    candidateName=get_param(blkNames{i},'Name');

                    if strcmp(candidateName,ownerName)&&...
                        isequal(ownerInterface,candidateInterface)
                        tmpList{end+1}=blkNames{i};%#ok

                    elseif strcmp(candidateName,ownerName)&&...
                        strcmp(ownerType,candidateType)
                        tmpList{end+1}=blkNames{i};%#ok

                    elseif strcmp(ownerType,candidateType)&&...
                        isequal(ownerInterface,candidateInterface)
                        tmpList{end+1}=blkNames{i};%#ok     

                    elseif isequal(ownerInterface,candidateInterface)
                        tmpList{end+1}=blkNames{i};%#ok  

                    elseif strcmp(candidateName,ownerName)
                        tmpList{end+1}=blkNames{i};%#ok  
                    end
                end

            elseif isa(this.harnessOwner,'Simulink.BlockDiagram')&&length(blkNames)>1

                ownerName=get_param(this.harnessOwner.Handle,'Name');
                for i=1:length(blkNames)
                    candidateType=get_param(blkNames{i},'BlockType');
                    candidateName=get_param(blkNames{i},'Name');
                    if strcmp(ownerName,candidateName)
                        tmpList{end+1}=blkNames{i};%#ok  
                    elseif strcmp(candidateType,'ModelReference')
                        tmpList{end+1}=blkNames{i};%#ok  
                    end
                end
            end

            if~isempty(tmpList)
                blkNames=[tmpList';setdiff(blkNames,tmpList)];
            end
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

        function r=isImportingForImplicitLink(this)
            ownerHandle=this.harnessOwner.Handle;
            r=false;
            if ishandle(ownerHandle)&&strcmp(get_param(ownerHandle,'Type'),'block')
                r=Simulink.harness.internal.isImplicitLink(ownerHandle);
            end
        end

        function r=isLibraryModel(this)
            modelName=bdroot(this.harnessOwner.getFullName());
            r=bdIsLibrary(modelName);
        end

        function r=isSubsystemModel(this)
            modelName=bdroot(this.harnessOwner.getFullName());
            r=bdIsSubsystem(modelName);
        end

        function r=isSubsystemRefBlk(this)
            r=isa(this.harnessOwner,'Simulink.SubSystem')&&~isempty(this.harnessOwner.ReferencedSubsystem);
        end





        function group=addRebuildOptionsUI(this)
            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessRebuildOpts');
            group.LayoutGrid=[2,1];
            group.Items={};

            rebuildOnOpenCheckbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:RebuildOnOpenCheckbox',...
            'rebuildOnOpen',...
            'HarnessRebuildOnOpenTag');
            rebuildOnOpenCheckbox.Mode=true;
            rebuildOnOpenCheckbox.RowSpan=[1,1];
            rebuildOnOpenCheckbox.ColSpan=[1,1];
            rebuildOnOpenCheckbox.Enabled=~this.isLibraryModel()&&~this.isSubsystemModel();
            group.Items{end+1}=rebuildOnOpenCheckbox;

            rebuildModelDataCheckbox=Simulink.harness.internal.getCheckBoxSrc(...
            'Simulink:Harness:RebuildModelDataCheckbox',...
            'rebuildModelData',...
            'HarnessRebuildModelDataTag');
            rebuildModelDataCheckbox.Mode=true;
            rebuildModelDataCheckbox.RowSpan=[2,2];
            rebuildModelDataCheckbox.ColSpan=[1,1];
            rebuildModelDataCheckbox.Enabled=~this.isLibraryModel()&&~this.isSubsystemModel();
            group.Items{end+1}=rebuildModelDataCheckbox;

        end

        function group=addSyncOptionsUI(this)
            group.Type='group';
            group.Name=DAStudio.message('Simulink:Harness:HarnessSyncOpts');
            group.LayoutGrid=[1,1];
            if this.isLibraryModel()||this.isSubsystemModel()
                synchronizationModecombobox=Simulink.harness.internal.getComboBoxSrc(...
                'Simulink:Harness:HarnessSyncMode',...
                'synchronizationModeTag',...
                this.syncComponentModeEntriesLib,...
                this.syncComponentModeValuesLib);
            elseif(isa(this.harnessOwner,'Simulink.SubSystem')||...
                isa(this.harnessOwner,'Simulink.ModelReference')||...
                Simulink.harness.internal.isUserDefinedFcnBlock(this.harnessOwner.Handle))&&...
                ~this.isImportingForImplicitLink
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

            synchronizationModecombobox.Enabled=~this.isImportingForImplicitLink&&~this.isSubsystemModel();
            group.Items={synchronizationModecombobox};
        end



        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:ImportDialogTitle');
            schema.DialogTag='HarnessImportDlgTag';

            schema.Items={};
            tab1.Items={};
            curRow=1;
            [items,curRow]=this.addHarnessNameUI(curRow);
            tab1.Items={tab1.Items{:},items{:}};%#ok 
            [items,curRow]=this.addFileAndCUTGroup(curRow);
            tab1.Items={tab1.Items{:},items{:}};%#ok 
            tab1.Items={tab1.Items{:}};
            tab1.LayoutGrid=[curRow-1,5];
            tab1.Name=DAStudio.message('Simulink:Harness:PropertiesTab');
            tab1.RowStretch=[zeros(1,curRow-1),1];

            tab3.Name=DAStudio.message('Simulink:Harness:HarnessDescriptionTab');
            tab3.Items={this.addHarnessDescriptionUI()};

            tabs.Type='tab';
            tabs.Tag='ImportSimulationHarnessDialogTabs';

            if this.isSubsystemModel

                tabs.Tabs={tab1,tab3};
            else
                tab2.Items={};
                tab2.Name=DAStudio.message('Simulink:Harness:AdvancedOptions');
                rebuildOptsGroup=this.addRebuildOptionsUI();

                emptylbl.Name='   ';
                emptylbl.Type='text';
                emptylbl.ColSpan=[1,1];

                emptylbl.RowSpan=[3,1];
                syncOptsGroup=this.addSyncOptionsUI();
                tab2.LayoutGrid=[3,1];
                tab2.Items={rebuildOptsGroup,syncOptsGroup,emptylbl};
                tab2.RowStretch=[0,0,1];

                tabs.Tabs={tab1,tab2,tab3};
            end

            panel.Type='panel';
            panel.Items={this.addDialogDescriptionUI(),tabs};
            panel.Tag='ImportSimulationHarnessDialogPanel';

            schema.Items={panel};
            schema.ExplicitShow=true;
            schema.HelpMethod='dlgHelpMethod';

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};
            schema.CloseMethod='dlgCloseMethod';
            schema.IsScrollable=true;

            schema.StandaloneButtonSet={'OK','Cancel','Help'};
        end

        function[status,msg]=dlgPostApplyMethod(this,~)
            status=false;
            msg=[];


            harnessCreateStage=Simulink.output.Stage(...
            DAStudio.message('Simulink:Harness:ImportHarnessStage'),...
            'ModelName',bdroot(this.harnessOwner.Path),...
            'UIMode',true);%#ok

            if isempty(strip(this.importFileName))
                msg=DAStudio.message('Simulink:Harness:ImportFileNameEmpty');
                return;
            end

            if~exist(this.importFileName,'file')
                msg=DAStudio.message('Simulink:LoadSave:FileNotFound',this.importFileName);
                return;
            end

            try
                if this.saveExternally
                    this.harnessFileName=fullfile(this.harnessFilePath,[this.harnessName,'.slx']);
                else
                    this.harnessFileName='';
                end

                if this.cutMap.isempty
                    msg=DAStudio.message('Simulink:Harness:ImportFailedNoCompatibleBlocks',this.importFileName,this.harnessOwner.Path);
                    return;
                end

                this.cutName=this.cutMap(this.cutName);
                if~isempty(this.harnessFileName)&&...
                    exist(this.harnessFileName,'file')
                    warnStr=DAStudio.message('Simulink:Harness:WarnAboutReplaceOnImport',this.harnessFileName);
                    title=DAStudio.message('Simulink:Harness:WarnAboutReplaceOnImportTitle');
                    continueButton=DAStudio.message('Simulink:Harness:Continue');
                    cancelButton=DAStudio.message('Simulink:Harness:Cancel');
                    choice=questdlg(warnStr,title,continueButton,cancelButton,continueButton);
                    if~strcmp(choice,continueButton)
                        msg=DAStudio.message('Simulink:Harness:HarnessCreationAbortedFileShadow');
                        return;
                    end
                elseif~isempty(which(this.harnessName))&&...
                    ~isequal(this.harnessName,bdroot)&&...
                    isempty(find_system('SearchDepth',0,'type','block_diagram','Name',this.harnessName))

                    warnStr=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnCreation');
                    title=DAStudio.message('Simulink:Harness:WarnAboutNameShadowingOnCreationTitle');
                    choice=questdlg(warnStr,title,'Continue','Cancel','Continue');
                    if~strcmp(choice,'Continue')
                        msg=DAStudio.message('Simulink:Harness:HarnessCreationAbortedFileShadow');
                        return;
                    end
                end

                if this.syncComponent==0
                    syncModeArg='SyncOnOpenAndClose';
                elseif this.syncComponent==1
                    syncModeArg='SyncOnOpen';
                else
                    syncModeArg='SyncOnPushRebuildOnly';
                end

                Simulink.harness.import(this.harnessOwner.Handle,'ImportFileName',this.importFileName,...
                'ComponentName',this.cutName,...
                'SynchronizationMode',syncModeArg,...
                'FromUI',true,...
                'Name',this.harnessName,...
                'SaveExternally',this.saveExternally,...
                'RebuildOnOpen',this.rebuildOnOpen,...
                'RebuildModelData',this.rebuildModelData,...
                'Description',this.harnessDescription,...
                'HarnessPath',this.harnessFileName);
                status=true;

            catch ME

                Simulink.harness.internal.error(ME,true);



                msg=DAStudio.message('Simulink:Harness:CreateAborted');

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
        end

        function show(~,dlg)

            if ispc
                width=max(600,dlg.position(3));
            else
                width=max(550,dlg.position(3));
            end
            height=dlg.position(4)+60;
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Model');
            dlg.show();
        end
    end

    methods(Static)
        function create(harnessOwner)
            import Simulink.harness.dialogs.importDialog;
            src=importDialog(harnessOwner);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get_param(bdroot(harnessOwner.Handle),'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(s,e)importDialog.onModelClose(s,e,src,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',{@importDialog.onStatusChanged,src});
            src.hBlockDeleteListener=Simulink.listener(harnessOwner,'DeleteEvent',@(s,e)importDialog.onBlockDelete(s,e,src,dlg));
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
