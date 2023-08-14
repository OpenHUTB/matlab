classdef codeContextListDialog<handle
    properties(SetObservable=true)
        mdlH=[];
        ownerH=[];
        libLocked=false;
        displayedList={};
        testList={};
        testListIdx={};
        testSelected={};
        selIdx=1;
        currIdx=1;
        numChecked=0;
        ccOwner='';
        unhiliteOnClose=false;
readOnly
hModelCloseListener
hModelStatusListener
studioApp
    end

    methods

        function varType=getPropDataType(this,varName)%#ok
            if strcmp(varName,'selIdx')
                varType='double';
            elseif strcmp(varName,'libLocked')||...
                strcmp(varName,'unhiliteOnClose')
                varType='boolean';
            else
                varType='string';
            end
        end

        function setPropValue(this,varName,varVal)
            if(strcmp(varName,'selIdx'))
                this.selIdx=str2double(varVal);
            else
                DAStudio.Protocol.setPropValue(this,varName,varVal);
            end
        end

        function this=codeContextListDialog(model,selection)

            isLib=strcmpi(get_param(model,'BlockDiagramType'),'library');
            if isLib
                this.mdlH=get_param(model,'handle');
                this.ownerH=get_param(selection,'handle');
                this.ccOwner=get_param(this.ownerH,'Object');
            else
                refBlock=get_param(selection,'ReferenceBlock');
                idx=strfind(refBlock,'/');
                idx=idx(1);
                libModel=refBlock(1:idx-1);
                load_system(libModel);
                this.mdlH=get_param(libModel,'handle');
                this.ownerH=get_param(refBlock,'handle');
                this.ccOwner=get_param(this.ownerH,'Object');
                this.hiliteOwner_cb();
            end

            this.libLocked=strcmp(get_param(this.mdlH,'Lock'),'on');
            this.numChecked=0;
            this.updateList();

            this.studioApp=SLM3I.SLDomain.getLastActiveStudioApp();
            this.readOnly=false;
        end

        function dlgDescGroup=addDialogDescriptionUI(this)
            lbl.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogInstructions');
            lbl.Type='text';
            lbl.Alignment=1;

            lbl.Tag='CodeContextListDlgDescLblTag';
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,2];

            link.Name=getfullname(this.ownerH);
            link.Type='hyperlink';
            link.Tag='CodeContextListDlgDescLinkTag';
            link.RowSpan=[1,1];
            link.ColSpan=[3,3];
            link.Alignment=1;
            link.ObjectMethod='hiliteOwner_cb';
            link.MethodArgs={};
            link.ArgDataTypes={};

            btn=Simulink.libcodegen.dialogs.shared.addUnlockLibraryButton(this,1,4);

            dlgDescGroup.Type='group';
            dlgDescGroup.Items={lbl,link,btn};
            dlgDescGroup.Tag='CodeContextListDlgDescGroupTag';
            dlgDescGroup.RowSpan=[1,1];
            dlgDescGroup.ColSpan=[1,8];
            dlgDescGroup.LayoutGrid=[1,8];
            dlgDescGroup.ColStretch=[0,0,0,0,0,0,0,1];
        end

        function lbl=addEmptyModelNote(~)
            lbl.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogEmpty');
            lbl.Type='text';
            lbl.Alignment=1;
            lbl.WordWrap=true;
            lbl.Tag='CodeContextListDlgEmptyNote';
            lbl.PreferredSize=[300,-1];
            lbl.RowSpan=[1,4];
            lbl.ColSpan=[1,7];
        end

        function table=addCodeContextListTable(this)
            numEls=length(this.displayedList);

            table.Type='table';
            table.HeaderVisibility=[0,1];
            if slfeature('CodeContextSILVerification')>0
                table.ColHeader={' ',...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader2'),...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader3'),...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader4'),...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader5')...
                };
                numCols=5;
            else
                table.ColHeader={' ',...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader2'),...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader3'),...
                DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader4'),...
                };
                numCols=3;
            end
            table.Size=[numEls,numCols];
            table.Editable=true;
            table.Tag='CodeContextListTable';

            table.ItemClickedCallback=@Simulink.libcodegen.dialogs.codeContextListDialog.handleTableClick;
            table.ValueChangedCallback=@Simulink.libcodegen.dialogs.codeContextListDialog.handleTableValueChanged;
            table.ColumnStretchable=[zeros(1,numCols-1),1];
            table.SelectionBehavior='Row';

            lenCol2=length(DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader2'));
            lenCol3=length(DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader3'));
            lenCol4=length(DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader4'));
            lenCol5=length(DAStudio.message('Simulink:CodeContext:ContextListDialogTableColHeader5'));

            for i=1:numEls
                this.testList{i}={};
                this.testListIdx{i}=1;
                hInfo=this.displayedList(i);
                table.Data{i,1}=this.createDeleteBox(hInfo);
                table.Data{i,2}=this.createNameWidget(hInfo);
                table.Data{i,3}=this.createDescWidget(hInfo);
                lenCol2=max(length(table.Data{i,2}.Name),lenCol2);
                lenCol3=max(length(table.Data{i,3}.Name),lenCol3);
                if numCols==5
                    table.Data{i,4}=this.createFPCWidget(hInfo);
                    lenCol4=max(length(table.Data{i,4}.Name),lenCol4);
                    table.Data{i,5}=this.createTestsWidget(hInfo,i);
                    lenCol5=max(length(table.Data{i,5}.Entries{1}),lenCol5);
                else
                    lenCol4=0;
                    lenCol5=0;
                end
            end

            table.ColumnCharacterWidth=[2,lenCol2,lenCol3,lenCol4,lenCol5];
            numChars=sum(table.ColumnCharacterWidth);
            table.PreferredSize=[numChars*12,-1];
            table.RowSpan=[3,4];
            table.ColSpan=[1,8];
        end

        function desc=createDescWidget(~,hInfo)
            desc.Type='text';
            desc.Name=hInfo.description;
            desc.WordWrap=true;
            desc.Tag=sprintf('CodeContextDescription_%s',hInfo.name);
        end

        function fpc=createFPCWidget(~,hInfo)
            fpc.Type='hyperlink';
            fpc.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogConfigure');
            fpc.Tag=sprintf('CodeContextListFPCLink_%s',hInfo.name);
            fpc.ObjectMethod='fpc_cb';
            fpc.DialogRefresh=true;
        end

        function name=createNameWidget(~,hInfo)
            name.Name=hInfo.name;
            name.Tag=sprintf('CodeContextList_%s',hInfo.name);
            name.Type='hyperlink';
            name.ObjectMethod='open_cb';
            name.DialogRefresh=true;
        end

        function tests=createTestsWidget(this,hInfo,idx)
            createTestString=DAStudio.message('Simulink:CodeContext:CreateTest');
            if isempty(this.testList{idx})
                this.testList{idx}={DAStudio.message('Simulink:CodeContext:NoTests'),createTestString};
            else
                this.testList{idx}=[this.testList{idx},{createString}];
            end
            this.testSelected{idx}=this.testList{idx}{1};
            tests=Simulink.harness.internal.getComboBoxSrc(...
            '',sprintf('CodeContextTests_%s',hInfo.name),...
            this.testList{idx},1:length(this.testList{idx}));

        end

        function btn=createDeleteBox(~,hInfo)
            btn.Name='';
            btn.Type='checkbox';
            btn.Tag=sprintf('CodeContextList_%s_delete',hInfo.name);
        end

        function btn=addSelectAllBox(~,checked)
            btn.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogSelectAll');
            btn.Type='checkbox';
            btn.Value=checked;
            btn.Tag='SelectAllBox';
            btn.RowSpan=[5,5];
            btn.ColSpan=[1,1];
            btn.ObjectMethod='selectall_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addExportSelectedButton(this,enabled)
            btn.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogExportSelected');
            btn.Type='pushbutton';
            btn.Tag='ExportSelectedButton';
            btn.Enabled=((enabled>0)&&~this.libLocked);
            btn.RowSpan=[5,5];
            btn.ColSpan=[5,5];
            btn.ObjectMethod='exportselected_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addDeleteSelectedButton(this,enabled)
            btn.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogDeleteSelected');
            btn.Type='pushbutton';
            btn.Tag='DeleteSelectedButton';
            btn.Enabled=((enabled>0)&&~this.libLocked);
            btn.RowSpan=[5,5];
            btn.ColSpan=[6,6];
            btn.ObjectMethod='deleteselected_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addCloseButton(~)
            btn.Name=DAStudio.message('Simulink:CodeContext:ContextListDialogClose');
            btn.Type='pushbutton';
            btn.Tag='CloseButton';
            btn.RowSpan=[5,5];
            btn.ColSpan=[7,7];
            btn.ObjectMethod='closebtn_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addHelpButton(~)
            btn.Name=DAStudio.message('Simulink:CodeContext:Help');
            btn.Type='pushbutton';
            btn.Tag='CodeContextListDlgHelpButton';
            btn.RowSpan=[5,5];
            btn.ColSpan=[8,8];
            btn.ObjectMethod='dlgHelpMethod';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function dlgHelpMethod(~,~)
            try
                mapFile=fullfile(docroot,'ecoder','helptargets.map');
                helpview(mapFile,'functionInterfaceManageHelp');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
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

        function selectall_cb(this,dlg)
            numEls=numel(this.displayedList);
            if dlg.getWidgetValue('SelectAllBox')==true
                stateChar='1';
                this.numChecked=numEls;
            else
                stateChar='0';
                this.numChecked=0;
            end
            for j=1:numEls
                dlg.setTableItemValue('CodeContextListTable',j-1,0,stateChar);
            end
            this.updateEnabled(dlg);
        end

        function exportselected_cb(this,dlg)
            numEls=numel(this.displayedList);
            isSelected=arrayfun(@(x)dlg.getTableItemValue('CodeContextListTable',x,0)=='1',0:numEls-1);
            SelectedList=this.displayedList(isSelected);

            try
                if isempty(SelectedList)
                    return;
                elseif numel(SelectedList)==1


                    name=SelectedList.name;
                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:CodeContext:ExportOneToIndependentTitle');
                    warnStr=DAStudio.message('Simulink:CodeContext:ExportOneToIndependentMessage',name);

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:CodeContext:Yes'),...
                    DAStudio.message('Simulink:CodeContext:No')},...
                    DAStudio.message('Simulink:CodeContext:No'),...
                    @(choice)confirmexport(choice));
                else
                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:CodeContext:ExportSelectedToIndependentTitle');
                    warnStr=DAStudio.message('Simulink:CodeContext:ExportSelectedToIndependentMessage',numel(SelectedList));

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:CodeContext:Yes'),...
                    DAStudio.message('Simulink:CodeContext:No')},...
                    DAStudio.message('Simulink:CodeContext:No'),...
                    @(choice)confirmexport(choice));
                end
            catch ME

                if~strcmp(ME.identifier,'Simulink:editor:DialogCancel')
                    Simulink.harness.internal.error(ME,true);
                end
            end

            function confirmexport(choice)
                if~strcmp(choice,DAStudio.message('Simulink:CodeContext:Yes'))
                    return;
                end
                this.readOnly=true;
                harnessCreateStage=Simulink.output.Stage(title,...
                'ModelName',getfullname(this.mdlH),'UIMode',true);%#ok
                try
                    this.updateList();
                    SelectedList=this.displayedList(isSelected);
                    if numel(SelectedList)==1
                        if SelectedList.canBeOpened&&~SelectedList.isOpen
                            exportName=[SelectedList.name,'_export'];
                            exportName=Simulink.harness.internal.getUniqueName(this.mdlH,exportName);
                            [filename,~]=Simulink.SaveDialog(exportName,false);
                            if~isempty(filename)
                                Simulink.libcodegen.internal.exportCodeContext(this.ownerH,SelectedList.name,'Name',filename);
                            end
                        else
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:CodeContext:CannotExportLockedOrOpenCodeContext'),...
                            DAStudio.message('Simulink:CodeContext:ContextListDialogTitle'),true);
                        end
                    else
                        skipped=false;
                        for i=1:numel(SelectedList)

                            if SelectedList(i).canBeOpened&&~SelectedList(i).isOpen
                                Simulink.libcodegen.internal.exportCodeContext(this.ownerH,SelectedList(i).name);
                            else
                                skipped=true;
                            end

                        end
                        if skipped
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:CodeContext:CannotExportMultiLockedOrOpenCodeContexts'),...
                            DAStudio.message('Simulink:CodeContext:ContextListDialogTitle'),true);
                        end
                    end
                catch ME
                    if~strcmp(ME.identifier,'Simulink:editor:DialogCancel')
                        Simulink.harness.internal.error(ME,true);
                    end
                end
                this.readOnly=false;
                src=dlg.getSource;
                src.updateList();
                dlg.refresh;
                src.updateEnabled(dlg);
            end
        end

        function deleteselected_cb(this,dlg)
            numEls=numel(this.displayedList);
            isSelected=arrayfun(@(x)dlg.getTableItemValue('CodeContextListTable',x,0)=='1',0:numEls-1);
            SelectedList=this.displayedList(isSelected);
            try
                if isempty(SelectedList)

                    return;
                elseif numel(SelectedList)==1


                    name=SelectedList.name;

                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:CodeContext:ConfirmDeleteDialogTitle');
                    warnStr=DAStudio.message('Simulink:CodeContext:ConfirmDeleteDialogText',name);

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:CodeContext:Yes'),...
                    DAStudio.message('Simulink:CodeContext:No')},...
                    DAStudio.message('Simulink:CodeContext:No'),...
                    @(choice)confirmdeletion(choice));
                else
                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:CodeContext:ConfirmDeleteDialogTitle');
                    warnStr=DAStudio.message('Simulink:CodeContext:ConfirmDeleteMultiDialogText',numel(SelectedList));

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:CodeContext:Yes'),...
                    DAStudio.message('Simulink:CodeContext:No')},...
                    DAStudio.message('Simulink:CodeContext:No'),...
                    @(choice)confirmdeletion(choice));
                end
            catch ME
                Simulink.harness.internal.warn(ME,...
                true,...
                'Simulink:CodeContext:DeleteCodeContextStage',...
                bdroot(this.ownerH));
            end

            function confirmdeletion(choice)
                if~strcmp(choice,DAStudio.message('Simulink:CodeContext:Yes'))
                    return;
                end
                harnessCreateStage=Simulink.output.Stage(title,...
                'ModelName',getfullname(this.mdlH),'UIMode',true);%#ok
                try
                    if numel(SelectedList)==1
                        if SelectedList.canBeOpened&&~SelectedList.isOpen
                            Simulink.libcodegen.internal.deleteCodeContext(this.ownerH,name);
                        else
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:CodeContext:CannotDeleteLockedOrOpenCodeContext'),...
                            DAStudio.message('Simulink:CodeContext:ContextListDialogTitle'),true);
                        end
                    else
                        skipped=false;
                        for j=1:numel(SelectedList)
                            name=SelectedList(j).name;
                            if SelectedList(j).canBeOpened&&~SelectedList(j).isOpen
                                Simulink.libcodegen.internal.deleteCodeContext(this.ownerH,name);
                            else
                                skipped=true;
                            end
                        end
                        if skipped
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:CodeContext:CannotDeleteMultiLockedOrOpenCodeContexts'),...
                            DAStudio.message('Simulink:CodeContext:ContextListDialogTitle'),true);
                        end
                    end
                catch ME
                    if~strcmp(ME.identifier,'Simulink:editor:DialogCancel')
                        Simulink.harness.internal.error(ME,true);
                    end
                end

                src=dlg.getSource;
                src.updateList();
                src.updateEnabled(dlg);
                dlg.refresh;
            end
        end

        function unlocklibrary_cb(this,dlg)
            set_param(this.mdlH,'Lock','off');
        end

        function closebtn_cb(~,dlg)
            delete(dlg);
        end

        function close_cb(this)
            currDlgList=DAStudio.ToolRoot.getOpenDialogs();


            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'CodeContextViewDlgTag')&&strcmp(currSrc.mdl,getfullname(this.mdlH))
                    delete(currDlg);
                    break;
                end
            end

            if this.unhiliteOnClose
                hilite(this.ccOwner,'none');
            end
        end

        function open_cb(this,~,~,name)
            try
                Simulink.libcodegen.dialogs.codeContextViewDialog.create(this.ownerH,name,false);
            catch ME
                Simulink.harness.internal.warn(ME,...
                true,...
                'Simulink:CodeContext:OpenCodeContextStage',...
                bdroot(this.ownerH));

            end
        end

        function fpc_cb(this,dlg,~,name)











        end

        function updateList(this)
            this.displayedList=Simulink.libcodegen.internal.getBlockCodeContexts(getfullname(this.mdlH),this.ownerH);
            if isempty(this.displayedList)



                this.selIdx=1;
                this.currIdx=1;
            else
                this.currIdx=this.selIdx;
            end

        end

        function updateEnabled(this,dlg)
            numEls=numel(this.displayedList);
            try
                isSelected=arrayfun(@(x)dlg.getTableItemValue('CodeContextListTable',x,0)=='1',0:numEls-1);
            catch ME
                if strcmp(ME.identifier,'ERROR:NoIdentifier')
                    return;
                else
                    MException.rethrow(ME);
                end
            end
            this.numChecked=sum(isSelected);
            this.libLocked=strcmp(get_param(this.mdlH,'Lock'),'on');
            enabled=~this.libLocked;
            switch this.numChecked
            case 0
                dlg.setEnabled('ExportSelectedButton',false);
                dlg.setEnabled('DeleteSelectedButton',false);
                dlg.setWidgetValue('SelectAllBox',false);
            otherwise
                dlg.setEnabled('ExportSelectedButton',enabled);
                dlg.setEnabled('DeleteSelectedButton',enabled);
            end
            dlg.setWidgetValue('SelectAllBox',this.numChecked==numEls);
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:CodeContext:ContextListDialogTitle');
            schema.DialogTag='CodeContextListDlgTag';
            schema.LayoutGrid=[5,7];
            schema.RowStretch=[0,0,0,1,0];


            if~isempty(this.displayedList)
                schema.Items={this.addDialogDescriptionUI(),...
                this.addCodeContextListTable(),...
                this.addSelectAllBox(this.numChecked==numel(this.displayedList)),...
                this.addExportSelectedButton(this.numChecked),...
                this.addDeleteSelectedButton(this.numChecked),...
                this.addCloseButton(),...
                this.addHelpButton()};
            else
                schema.Items={this.addEmptyModelNote()};
            end

            schema.ExplicitShow=true;
            schema.IsScrollable=0;

            schema.StandaloneButtonSet={''};
            schema.CloseMethod='close_cb';
            schema.DialogRefresh=true;
        end


        function show(~,dlg)
            width=dlg.position(3);
            height=dlg.position(4);
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'ModelCenter');
            dlg.show();
        end

        function registerDAListeners(obj)
            bd=get_param(obj.mdlH,'Object');
            bd.registerDAListeners;
        end
    end

    methods(Static)
        function create(model,selection)
            import Simulink.libcodegen.dialogs.codeContextListDialog;

            currDlgList=DAStudio.ToolRoot.getOpenDialogs();



            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'CodeContextListDlgTag')&&strcmp(getfullname(currSrc.ownerH),getfullname(selection))
                    currDlg.show();
                    return;
                end
            end

            src=codeContextListDialog(model,selection);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get(src.mdlH,'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(hSrc,ev)Simulink.libcodegen.dialogs.codeContextListDialog.onModelClose(hSrc,ev,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'ReadonlyChangedEvent',{@Simulink.libcodegen.dialogs.shared.onReadOnlyChanged,src,dlg});
        end

        function onModelClose(~,~,dlg)

            if ishandle(dlg)
                delete(dlg);
            end
        end

        function handleTableClick(dlgH,row,col,~)

            row=row+1;
            col=col+1;
            src=dlgH.getDialogSource;
            hInfo=src.displayedList(row);
            if col==2
                src.open_cb(dlgH,hInfo.ownerHandle,...
                hInfo.name);
                if ishandle(dlgH)
                    delete(dlgH);
                end
                return;
            elseif col==4
                src.fpc_cb(dlgH,hInfo.ownerHandle,...
                hInfo.name);
                if ishandle(dlgH)
                    delete(dlgH);
                end
                return;
            end
            src.updateList();

        end

        function handleTableValueChanged(dlg,~,col,~)
            if col==0
                src=dlg.getSource;
                numEls=numel(src.displayedList);
                isSelected=arrayfun(@(x)dlg.getTableItemValue('CodeContextListTable',x,0)=='1',0:numEls-1);
                src.numChecked=sum(isSelected);
                updateEnabled(dlg.getSource,dlg);
            end
        end
    end
end
