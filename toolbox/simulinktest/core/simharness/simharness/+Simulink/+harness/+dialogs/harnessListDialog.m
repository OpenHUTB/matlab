classdef harnessListDialog<handle



    properties(SetObservable=true)
        mdlH=[];
        hList={};
        ownerList={};
        displayedList={};
        selIdx=1;
        currIdx=1;
        numChecked=0;
readOnly
hModelCloseListener
studioApp
    end

    methods

        function varType=getPropDataType(this,varName)%#ok
            assert(strcmp(varName,'selIdx'));
            varType='double';
        end

        function setPropValue(this,varName,varVal)
            if(strcmp(varName,'selIdx'))
                this.selIdx=str2double(varVal);
            else
                DAStudio.Protocol.setPropValue(this,varName,varVal);
            end
        end

        function this=harnessListDialog(model,selection)

            this.mdlH=get_param(model,'handle');
            if~isempty(selection)
                selection=strrep(selection,sprintf('\n'),'\n');
            end

            this.updateList(selection);

            this.studioApp=SLM3I.SLDomain.getLastActiveStudioApp();
            this.readOnly=false;
        end

        function dlgDescGroup=addDialogDescriptionUI(this)
            lbl.Name=DAStudio.message('Simulink:Harness:HarnessListDialogInstructions');
            lbl.Type='text';
            lbl.Alignment=1;
            lbl.WordWrap=true;
            lbl.Tag='HarnessListDlgDescLblTag';
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,2];

            link.Name=getfullname(this.mdlH);
            link.Type='hyperlink';
            link.Tag='HarnessListDlgDescLinkTag';
            link.RowSpan=[1,1];
            link.ColSpan=[3,3];
            link.ObjectMethod='opensystem_cb';
            link.MethodArgs={};
            link.ArgDataTypes={};

            dlgDescGroup.Type='group';
            dlgDescGroup.Items={lbl,link};
            dlgDescGroup.Tag='HarnessListDlgDescGroupTag';
            dlgDescGroup.RowSpan=[1,1];
            dlgDescGroup.ColSpan=[1,7];
            dlgDescGroup.LayoutGrid=[1,3];
            dlgDescGroup.ColStretch=[0,1,0];
        end

        function selector=addHarnessOwnerSelector(this)
            selector.Type='combobox';
            selector.Name=DAStudio.message('Simulink:Harness:HarnessListDialogSelector');
            selector.Entries=this.ownerList;
            selector.Values=1:length(this.ownerList);
            selector.ObjectProperty='selIdx';
            selector.ObjectMethod='ownerchanged_cb';
            selector.MethodArgs={'%dialog'};
            selector.ArgDataTypes={'handle'};
            selector.Mode=true;
            selector.Tag='HarnessListOwnerSelector';
            selector.RowSpan=[2,2];
            selector.ColSpan=[1,7];
        end

        function lbl=addEmptyModelNote(~)
            lbl.Name=DAStudio.message('Simulink:Harness:HarnessListDialogEmptyToolStrip');
            lbl.Type='text';
            lbl.Alignment=1;
            lbl.WordWrap=true;
            lbl.Tag='HarnesslistDlgEmptyNote';
            lbl.PreferredSize=[300,-1];
            lbl.RowSpan=[1,4];
            lbl.ColSpan=[1,7];
        end

        function table=addHarnessListTable(this)

            selectedOwner=this.ownerList{this.selIdx};

            this.displayedList=this.hList;
            allH=strcmp(selectedOwner,'All');

            if~allH
                this.displayedList=this.hList(arrayfun(@(x)strcmp(...
                strrep(x.ownerFullPath,sprintf('\n'),'\n'),...
                selectedOwner),this.hList));
            end

            numEls=length(this.displayedList);

            table.Type='table';
            table.HeaderVisibility=[0,1];
            table.ColHeader={' ',...
            DAStudio.message('Simulink:Harness:HarnessListDialogTableColHeader2'),...
            DAStudio.message('Simulink:Harness:HarnessListDialogTableColHeader3'),...
            };
            table.Size=[numEls,3];
            table.Editable=true;
            table.Tag='HarnessListTable';

            table.ItemClickedCallback=@Simulink.harness.dialogs.harnessListDialog.handleTableClick;
            table.ValueChangedCallback=@Simulink.harness.dialogs.harnessListDialog.handleTableValueChanged;
            table.ColumnStretchable=[0,0,1];
            table.SelectionBehavior='Row';

            lenCol2=length(DAStudio.message('Simulink:Harness:HarnessListDialogTableColHeader2'));
            lenCol3=length(DAStudio.message('Simulink:Harness:HarnessListDialogTableColHeader3'));

            for i=1:numEls
                table.Data{i,1}=this.createDeleteBox(this.displayedList(i));
                table.Data{i,2}=this.createNameWidget(this.displayedList(i));
                table.Data{i,3}=this.createOwnerWidget(this.displayedList(i));

                lenCol2=max(length(table.Data{i,2}.Name),lenCol2);
                lenCol3=max(length(table.Data{i,3}.Name),lenCol3);
            end

            table.ColumnCharacterWidth=[2,lenCol2,lenCol3];
            numChars=sum(table.ColumnCharacterWidth);
            table.PreferredSize=[numChars*12,-1];
            table.RowSpan=[3,4];
            table.ColSpan=[1,7];
        end

        function owner=createOwnerWidget(~,hInfo)
            owner.Type='text';
            owner.Name=strrep(hInfo.ownerFullPath,sprintf('\n'),'\n');
            if strcmp(hInfo.ownerFullPath,hInfo.model)
                owner.Name='./';
            else
                owner.Name=regexprep(owner.Name,hInfo.model,'.','once');
            end
            owner.Tag=sprintf('Harness_%s_owner',hInfo.name);
        end

        function name=createNameWidget(~,hInfo)
            name.Name=hInfo.name;
            name.Tag=sprintf('Harness_%s',hInfo.name);
            name.Type='hyperlink';
            name.DialogRefresh=true;
        end

        function btn=createDeleteBox(~,hInfo)
            btn.Name='';
            btn.Type='checkbox';
            btn.Tag=sprintf('Harness_%s_delete',hInfo.name);
        end

        function btn=addSelectAllBox(~,checked)
            btn.Name=DAStudio.message('Simulink:Harness:HarnessListDialogSelectAll');
            btn.Type='checkbox';
            btn.Value=checked;
            btn.Tag='SelectAllBox';
            btn.RowSpan=[5,5];
            btn.ColSpan=[1,1];
            btn.ObjectMethod='selectall_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addActionsButton(~,enabled)
            btn.Name='';
            btn.Type='combobox';
            btn.Tag='ActionsButton';
            btn.Enabled=enabled;
            btn.Entries={DAStudio.message('Simulink:Harness:HarnessListDialogActions'),...
            DAStudio.message('Simulink:Harness:HarnessListDialogProperties'),...
            DAStudio.message('Simulink:Harness:HarnessListDialogMove'),...
            DAStudio.message('Simulink:Harness:HarnessListDialogClone')};
            btn.RowSpan=[5,5];
            btn.ColSpan=[4,4];
            btn.ObjectMethod='actions_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addExportSelectedButton(~,enabled)
            btn.Name=DAStudio.message('Simulink:Harness:HarnessListDialogExportSelected');
            btn.Type='pushbutton';
            btn.Tag='ExportSelectedButton';
            btn.Enabled=enabled;
            btn.RowSpan=[5,5];
            btn.ColSpan=[5,5];
            btn.ObjectMethod='exportselected_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addDeleteSelectedButton(~,enabled)
            btn.Name=DAStudio.message('Simulink:Harness:HarnessListDialogDeleteSelected');
            btn.Type='pushbutton';
            btn.Tag='DeleteSelectedButton';
            btn.Enabled=enabled;
            btn.RowSpan=[5,5];
            btn.ColSpan=[6,6];
            btn.ObjectMethod='deleteselected_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function btn=addCloseButton(~)
            btn.Name=DAStudio.message('Simulink:Harness:HarnessListDialogClose');
            btn.Type='pushbutton';
            btn.Tag='CloseButton';
            btn.RowSpan=[5,5];
            btn.ColSpan=[7,7];
            btn.ObjectMethod='closebtn_cb';
            btn.MethodArgs={'%dialog'};
            btn.ArgDataTypes={'handle'};
        end

        function opensystem_cb(this)
            try
                open_system(getfullname(this.mdlH));
            catch ME
                Simulink.harness.internal.error(ME,true);
            end
        end

        function ownerchanged_cb(this,dlg)


            if this.selIdx~=this.currIdx
                this.numChecked=0;
                numEls=numel(this.displayedList);
                for j=1:numEls
                    dlg.setTableItemValue('HarnessListTable',j-1,0,'0');
                end
                dlg.setWidgetValue('SelectAllBox',false);
                dlg.setEnabled('ActionsButton',false);
                dlg.setEnabled('ExportSelectedButton',false);
                dlg.setEnabled('DeleteSelectedButton',false);
                this.currIdx=this.selIdx;
                dlg.refresh;
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
                dlg.setTableItemValue('HarnessListTable',j-1,0,stateChar);
            end
            this.updateEnabled(dlg);
        end

        function exportselected_cb(this,dlg)
            numEls=numel(this.displayedList);
            isSelected=arrayfun(@(x)dlg.getTableItemValue('HarnessListTable',x,0)=='1',0:numEls-1);
            SelectedList=this.displayedList(isSelected);

            try
                if isempty(SelectedList)
                    return;
                elseif numel(SelectedList)==1


                    name=SelectedList.name;
                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:Harness:ExportOneToIndependentTitle');
                    warnStr=DAStudio.message('Simulink:Harness:ExportOneToIndependentMessage',name);

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:Harness:Yes'),...
                    DAStudio.message('Simulink:Harness:No')},...
                    DAStudio.message('Simulink:Harness:No'),...
                    @(choice)confirmexport(choice));
                else
                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:Harness:ExportSelectedToIndependentTitle');
                    warnStr=DAStudio.message('Simulink:Harness:ExportSelectedToIndependentMessage',numel(SelectedList));

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:Harness:Yes'),...
                    DAStudio.message('Simulink:Harness:No')},...
                    DAStudio.message('Simulink:Harness:No'),...
                    @(choice)confirmexport(choice));
                end
            catch ME

                if~strcmp(ME.identifier,'Simulink:editor:DialogCancel')
                    Simulink.harness.internal.error(ME,true);
                end
            end

            function confirmexport(choice)
                if~strcmp(choice,DAStudio.message('Simulink:Harness:Yes'))
                    return;
                end
                this.readOnly=true;
                harnessCreateStage=Simulink.output.Stage(title,...
                'ModelName',getfullname(this.mdlH),'UIMode',true);%#ok
                try
                    if numel(SelectedList)==1
                        [filename,~]=Simulink.SaveDialog(SelectedList.name,false);
                        if~isempty(filename)
                            Simulink.harness.export(SelectedList.ownerHandle,SelectedList.name,'Name',filename);
                        end
                    else
                        Simulink.harness.internal.exportAllHarnesses(getfullname(this.mdlH),false,SelectedList);
                    end
                catch ME
                    if~strcmp(ME.identifier,'Simulink:editor:DialogCancel')
                        Simulink.harness.internal.error(ME,true);
                    end
                end
                this.readOnly=false;
                dlg.refresh;
                src=dlg.getSource;
                src.updateEnabled(dlg);
            end
        end

        function deleteselected_cb(this,dlg)
            numEls=numel(this.displayedList);
            isSelected=arrayfun(@(x)dlg.getTableItemValue('HarnessListTable',x,0)=='1',0:numEls-1);
            SelectedList=this.displayedList(isSelected);
            try
                if isempty(SelectedList)

                    return;
                elseif numel(SelectedList)==1


                    ownerH=SelectedList.ownerHandle;
                    name=SelectedList.name;

                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:Harness:ConfirmDeleteDialogTitle');
                    warnStr=DAStudio.message('Simulink:Harness:ConfirmDeleteDialogText',name);

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:Harness:Yes'),...
                    DAStudio.message('Simulink:Harness:No')},...
                    DAStudio.message('Simulink:Harness:No'),...
                    @(choice)confirmdeletion(choice));
                else
                    dp=DAStudio.DialogProvider;
                    title=DAStudio.message('Simulink:Harness:ConfirmDeleteDialogTitle');
                    warnStr=DAStudio.message('Simulink:Harness:ConfirmDeleteMultiDialogText',numel(SelectedList));

                    dp.questdlg(warnStr,title,{DAStudio.message('Simulink:Harness:Yes'),...
                    DAStudio.message('Simulink:Harness:No')},...
                    DAStudio.message('Simulink:Harness:No'),...
                    @(choice)confirmdeletion(choice));
                end
            catch ME
                Simulink.harness.internal.warn(ME,...
                true,...
                'Simulink:Harness:DeleteHarnessStage',...
                bdroot(ownerH));
            end

            function confirmdeletion(choice)
                if~strcmp(choice,DAStudio.message('Simulink:Harness:Yes'))
                    return;
                end
                harnessCreateStage=Simulink.output.Stage(title,...
                'ModelName',getfullname(this.mdlH),'UIMode',true);%#ok
                try
                    if numel(SelectedList)==1
                        if Simulink.harness.internal.licenseTest()&&SelectedList.canBeOpened&&~SelectedList.isOpen
                            Simulink.harness.internal.delete(ownerH,name);
                        elseif~SelectedList.canBeOpened&&~SelectedList.isOpen&&Simulink.harness.internal.hasActiveHarness(SelectedList.model)
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:Harness:CannotDeleteWhenATestingHarnessIsActive',SelectedList.name),...
                            DAStudio.message('Simulink:Harness:HarnessListDialogTitle',getfullname(this.mdlH)),true);
                        else
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:Harness:CannotDeleteLockedOrOpenHarness'),...
                            DAStudio.message('Simulink:Harness:HarnessListDialogTitle',getfullname(this.mdlH)),true);
                        end
                    else
                        skipped=false;
                        for j=1:numel(SelectedList)
                            ownerH=SelectedList(j).ownerHandle;
                            name=SelectedList(j).name;
                            if Simulink.harness.internal.licenseTest()&&SelectedList(j).canBeOpened&&~SelectedList(j).isOpen
                                Simulink.harness.internal.delete(ownerH,name);
                            else
                                skipped=true;
                            end
                        end
                        if skipped
                            dp0=DAStudio.DialogProvider;
                            dp0.msgbox(DAStudio.message('Simulink:Harness:CannotDeleteMultiLockedOrOpenHarness'),...
                            DAStudio.message('Simulink:Harness:HarnessListDialogTitle',getfullname(this.mdlH)),true);

                        end
                    end
                catch ME
                    if~strcmp(ME.identifier,'Simulink:editor:DialogCancel')
                        Simulink.harness.internal.error(ME,true);
                    end
                end
                dlg.getSource.updateEnabled(dlg);
            end
        end

        function actions_cb(this,dlg)
            numEls=numel(this.displayedList);
            isSelected=arrayfun(@(x)dlg.getTableItemValue('HarnessListTable',x,0)=='1',0:numEls-1);
            row=find(isSelected,1);
            if isempty(row)
                return;
            end
            src=dlg.getSource;
            idx=dlg.getWidgetValue('ActionsButton');
            switch idx
            case 0
                return;
            case 1
                dlg.setWidgetValue('ActionsButton',0);
                this.numChecked=0;
                temp=src.displayedList(row);
                temp.ownerFullPath=getfullname(temp.ownerHandle);
                Simulink.harness.dialogs.updateDialog.create(temp);
            case 2
                dlg.setWidgetValue('ActionsButton',0);
                this.numChecked=0;
                Simulink.harness.dialogs.moveDialog.create(getfullname(src.mdlH),src.displayedList(row).name,getfullname(src.displayedList(row).ownerHandle),'move');
            case 3
                dlg.setWidgetValue('ActionsButton',0);
                this.numChecked=0;
                Simulink.harness.dialogs.moveDialog.create(getfullname(src.mdlH),src.displayedList(row).name,getfullname(src.displayedList(row).ownerHandle),'clone');
            end
        end

        function closebtn_cb(~,dlg)
            delete(dlg);
        end

        function close_cb(this)
            currDlgList=DAStudio.ToolRoot.getOpenDialogs();


            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'MoveDlgTag')&&strcmp(currSrc.mdl,getfullname(this.mdlH))
                    delete(currDlg);
                    break;
                end
            end
        end

        function open_cb(this,~,ownerH,name)
            try
                Simulink.harness.internal.open_from_ui(ownerH,name,'ReuseWindow',false);



            catch ME
                Simulink.harness.internal.warn(ME,...
                true,...
                'Simulink:Harness:OpenHarnessStage',...
                bdroot(ownerH));

            end
        end

        function updateList(this,selection)




            tmpList=Simulink.harness.find(getfullname(this.mdlH));
            for j=1:numel(tmpList)
                if~isempty(strfind(tmpList(j).ownerFullPath,'__tmp_name_for_test_harness_'))
                    [~,loc]=ismember(tmpList(j).name,{this.hList.name});
                    if numel(loc)==1
                        tmpList(j).ownerFullPath=this.hList(loc).ownerFullPath;
                    else
                        tmpList={};
                        break;
                    end
                end
            end
            [~,idx]=sort(arrayfun(@(x){[x.ownerFullPath,'/',x.name]},tmpList));
            this.hList=tmpList(idx);
            if isempty(this.hList)



                this.ownerList={'All'};
                this.selIdx=1;
                this.currIdx=1;
            else

                this.ownerList=unique({this.hList.ownerFullPath});
                this.ownerList{end+1}='All';


                this.ownerList=strrep(this.ownerList,sprintf('\n'),'\n');


                if~isempty(selection)
                    this.selIdx=find(arrayfun(@(x)strcmp(x,selection),this.ownerList));
                    if isempty(this.selIdx)
                        this.selIdx=length(this.ownerList);
                    end
                else
                    this.selIdx=length(this.ownerList);
                end
                this.currIdx=this.selIdx;
            end



            currDlgList=DAStudio.ToolRoot.getOpenDialogs();
            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'MoveDlgTag')&&strcmp(currSrc.mdl,getfullname(this.mdlH))
                    if isempty(Simulink.harness.find(currSrc.harnessOwnerPath,'Name',currSrc.harnessName,'SearchDepth',0))
                        delete(currDlg);
                    end
                    break;
                end
            end
        end

        function updateEnabled(this,dlg)
            numEls=numel(this.displayedList);
            try
                isSelected=arrayfun(@(x)dlg.getTableItemValue('HarnessListTable',x,0)=='1',0:numEls-1);
            catch ME
                if strcmp(ME.identifier,'ERROR:NoIdentifier')
                    return;
                else
                    MException.rethrow(ME);
                end
            end
            this.numChecked=sum(isSelected);
            switch this.numChecked
            case 0
                dlg.setEnabled('ExportSelectedButton',false);
                dlg.setEnabled('DeleteSelectedButton',false);
                dlg.setEnabled('ActionsButton',false);
                dlg.setWidgetValue('SelectAllBox',false);
            case 1
                dlg.setEnabled('ExportSelectedButton',true);
                dlg.setEnabled('DeleteSelectedButton',true);
                dlg.setEnabled('ActionsButton',true);
            otherwise
                dlg.setEnabled('ExportSelectedButton',true);
                dlg.setEnabled('DeleteSelectedButton',true);
                dlg.setEnabled('ActionsButton',false);
            end
            if this.numChecked==numEls
                dlg.setWidgetValue('SelectAllBox',true);
            end
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:HarnessListDialogTitle',getfullname(this.mdlH));
            schema.DialogTag='HarnessListDlgTag';
            schema.LayoutGrid=[5,7];
            schema.RowStretch=[0,0,0,1,0];
            schema.ColStretch=[0,0,1,0,0,0,0];

            if~isempty(this.hList)
                schema.Items={this.addDialogDescriptionUI(),...
                this.addHarnessOwnerSelector(),...
                this.addHarnessListTable(),...
                this.addSelectAllBox(this.numChecked==numel(this.displayedList)),...
                this.addActionsButton(this.numChecked==1),...
                this.addExportSelectedButton(this.numChecked),...
                this.addDeleteSelectedButton(this.numChecked),...
                this.addCloseButton()};
            else
                schema.Items={this.addEmptyModelNote()};
            end

            schema.ExplicitShow=true;
            schema.IsScrollable=0;

            schema.StandaloneButtonSet={''};
            schema.CloseMethod='close_cb';
        end


        function show(~,dlg)
            width=dlg.position(3);
            height=dlg.position(4);
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'ModelCenter');
            dlg.show();
        end

    end

    methods(Static)
        function create(model,selection)
            import Simulink.harness.dialogs.harnessListDialog;

            currDlgList=DAStudio.ToolRoot.getOpenDialogs();



            for j=1:numel(currDlgList)
                currDlg=currDlgList(j);
                currSrc=currDlg.getSource();
                if strcmp(currDlg.dialogTag,'HarnessListDlgTag')&&strcmp(getfullname(currSrc.mdlH),model)
                    currDlg.show();
                    return;
                end
            end

            src=harnessListDialog(model,selection);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get(src.mdlH,'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(src,evt)Simulink.harness.dialogs.harnessListDialog.onModelClose(src,evt,dlg));
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
            end
        end

        function handleTableValueChanged(dlg,~,col,~)
            if col==0
                src=dlg.getSource;
                numEls=numel(src.displayedList);
                isSelected=arrayfun(@(x)dlg.getTableItemValue('HarnessListTable',x,0)=='1',0:numEls-1);
                src.numChecked=sum(isSelected);
                updateEnabled(dlg.getSource,dlg);
            end
        end
    end
end
