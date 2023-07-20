classdef AttributeSelector<handle






    properties(Access=protected)
        mBlock;
        mUddParent;
        mBlockPrms;
        mPropAttribs;
        mPresence;
        mDispAttribList;
        mChildErrorDlgs;
    end


    properties(SetObservable=true,Hidden)
        mFilterStr;
        mSelectedTableRow;
        mSelectedItem;
    end


    properties(Access=private,Constant)

        MsgNoAttribAvailable=DAStudio.message('SimulinkDiscreteEvent:dialog:NoAttribsAvailable');
        MsgAttribSelectedFootnote=DAStudio.message('SimulinkDiscreteEvent:dialog:AttribSelectedFootnote');
        MsgAttribMissingFootnote=DAStudio.message('SimulinkDiscreteEvent:dialog:AttribMissingFootnote');
        MsgAvailableAttribs=DAStudio.message('SimulinkDiscreteEvent:dialog:AvailableAttribs');
        MsgFilterByName=DAStudio.message('SimulinkDiscreteEvent:dialog:FilterByName');
        MsgNumberEntitiesDeparted=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberEntitiesDeparted');
        MsgStatistics=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
        MsgMain=DAStudio.message('SimulinkDiscreteEvent:dialog:Main');


        MsgRefreshAttribList=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipRefreshAttribList');
        MsgAddSelectedToTable=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAddSelectedAttribToTable');
        MsgRemoveFromTable=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipRemoveSelectedAttribFromTable');
        MsgAddNewRow=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAddNewRowToTable');
        MsgCopySelectedRow=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipCopySelectedRowInTable');
        MsgDeleteSelectedRow=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipDeleteSelectedRowFromTable');
        MsgMoveSelectedRowUp=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowUp');
        MsgMoveSelectedRowDown=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowDown');
        MsgTipAttribMissing=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAttribMissingFootnote');
        MsgTipShowAllAttribs=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipShowAllAttribs');
        MsgTipFilterAttribs=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipFilterAttribs');
        MsgTipAttribList=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAttribList');
        MsgTipAttribListEmpty=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAttribListEmpty');


        MsgListColumnHeadings={...
        DAStudio.message('SimulinkDiscreteEvent:dialog:Selected'),...
        DAStudio.message('SimulinkDiscreteEvent:dialog:TAttributeName')};
    end


    properties(Access=private)
        mPropagate;
    end


    methods(Abstract)


        params=getAttributeParams(this);


        schema=getAttributeTableSchema(this);


        name=getDefaultBlockName(this)


        default=getParamDefaultValue(this,param);

    end


    methods


        function this=AttributeSelector(blk,udd)


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;
            this.mPropAttribs={};
            this.mDispAttribList={};
            this.mFilterStr='';
            this.mSelectedTableRow=0;
            this.mSelectedItem={};
            this.mChildErrorDlgs=[];
            this.mPropagate=true;


            tableParams=this.getAttributeParams();
            assert(any(strcmp(tableParams,'AttributeName')));
            initialTableVals=repmat({''},1,length(tableParams));
            this.mBlockPrms=cell2struct(initialTableVals,tableParams,2);

            this.cacheParams();
        end


        function schema=getDialogSchema(this)


            this.refreshPropagatedData();

            blockDesc=this.getBlockDescriptionSchema();
            mainTab=this.getMainTabSchema();
            statsTab=this.getStatisticsSchema();

            tabCont.Type='tab';
            tabCont.Tabs={mainTab,statsTab};
            tabCont.Name='';
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];

            schema.DialogTitle=DAStudio.message('Simulink:dialog:BlockParameters',this.mBlock.Name);
            schema.Items={blockDesc,tabCont};
            schema.DialogTag=this.mBlock.BlockType;
            schema.Source=this.mUddParent;
            schema.SmartApply=false;
            schema.HelpMethod='slhelp';
            schema.HelpArgs={this.mBlock.Handle};
            schema.HelpArgsDT={'double'};
            schema.OpenCallback=@(dialog)this.openCallback(dialog);
            schema.CloseMethod='doCloseCallback';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','string'};
            schema.PreApplyCallback='doPreApplyCallback';
            schema.PreApplyArgs={'%source','%dialog'};
            schema.PreApplyArgsDT={'handle','handle'};
        end

        function isValid=isValidProperty(~,propName)
            assert(strcmp(propName,'mFilterStr'));

            isValid=true;
        end

        function dataType=getPropDataType(~,propName)
            assert(strcmp(propName,'mFilterStr'));

            dataType='string';
        end


        function openCallback(~,dialog)



            dialog.selectTableRow('tableAttribs',0);
        end


        function closeCallback(this,dialog,~)



            for idx=1:length(this.mChildErrorDlgs)
                errDlg=this.mChildErrorDlgs(idx);
                if ishandle(errDlg)
                    delete(errDlg);
                end
            end
            this.mChildErrorDlgs=[];

            this.mUddParent.closeCallback(dialog);
            this.cacheParams();
            this.mFilterStr='';
        end


        function[status,msg]=preApplyCallback(this,dialog)


            try
                this.validateNonZeroRowsInTable();
                this.saveChangesToBlock();
                [status,msg]=this.mUddParent.preApplyCallback(dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end


        function refreshPropagatedData(this,force)



            if~exist('force','var')
                force=false;
            end
            if~this.mPropagate&&~force
                return;
            end
            this.mPropagate=false;

            try
                entityTypeNames=this.mBlock.InputEntityTypeNames;
                this.mPropAttribs=entityTypeNames.Attributes;
                propCommonAttribs=entityTypeNames.CommonAttributes;
            catch me %#ok<NASGU>
                this.mPropAttribs={};
                propCommonAttribs={};
            end

            if~isempty(this.mPropAttribs)
                fcnExistsInCommonSet=@(x)any(strcmp(propCommonAttribs,x));
                this.mPresence=cellfun(fcnExistsInCommonSet,this.mPropAttribs);
            else
                this.mPresence=0;
            end
        end


        function applyAttribFilter(this,dialog)





            str=dialog.getWidgetValue('editAttribName');
            this.mFilterStr=str;
            selectAttribInList(this,dialog,'','');


            if isempty(str)
                dialog.setWidgetValue('listSelect',[]);
                return;
            end
        end


        function clickButtonMoveRight(this,dialog)



            selRows=dialog.getSelectedTableRows('listSelect');
            if isempty(selRows)
                return;
            end

            if isempty(this.mSelectedItem)
                return;
            end


            newAttrib=this.mSelectedItem;
            attribs=this.mBlockPrms.AttributeName;
            newAttrib=setdiff(newAttrib,attribs);
            oldNumAtts=length(attribs);



            newAttribSet=[attribs,newAttrib];
            newNumAtts=length(newAttribSet);
            if newNumAtts>this.getMaxNumRowsAllowedInTable()
                this.mChildErrorDlgs=...
                this.errorDuringCallback(...
                dialog,...
                DAStudio.message(...
                'SimulinkDiscreteEvent:dialog:MaxTableSizeError',...
                this.getMaxNumRowsAllowedInTable()),...
                this.mChildErrorDlgs);
                return;
            end


            this.mBlockPrms.AttributeName=newAttribSet;
            params=setdiff(fields(this.mBlockPrms),'AttributeName');
            for idx=1:length(params)
                param=params{idx};
                defaultValue=this.getParamDefaultValue(param);
                this.mBlockPrms.(param)=[this.mBlockPrms.(param),...
                repmat({defaultValue},1,newNumAtts-oldNumAtts)];
            end
            this.assertAttribTableConsistency();


            this.mSelectedTableRow=newNumAtts-1;



            count=0;
            idx=max(selRows)+1;
            nextRowToSelect=0;
            found=false;
            while count<length(this.mDispAttribList)
                if idx>=length(this.mDispAttribList)
                    idx=0;
                end

                val=dialog.getTableItemValue('listSelect',idx,0);

                if isempty(val)

                    nextRowToSelect=idx;
                    found=true;
                    break;
                end
                count=count+1;
                idx=idx+1;
            end
            if~found
                nextRowToSelect=[];
            end

            nextDispAttribs=this.clean(this.mDispAttribList);
            dialog.selectTableRow('listSelect',nextRowToSelect);
            this.mSelectedItem=nextDispAttribs(nextRowToSelect+1);

            dialog.enableApplyButton(true);
        end


        function clickButtonMoveLeft(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            idxToRemove=this.mSelectedTableRow+1;


            params=fields(this.mBlockPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlockPrms.(param);
                value(idxToRemove)=[];
                this.mBlockPrms.(param)=value;
            end
            this.assertAttribTableConsistency();


            if~isempty(this.mBlockPrms.AttributeName)
                if min(this.mSelectedTableRow)>=length(this.mBlockPrms.AttributeName)-1
                    this.mSelectedTableRow=length(this.mBlockPrms.AttributeName)-1;
                else
                    this.mSelectedTableRow=min(this.mSelectedTableRow);
                end
            end

            dialog.enableApplyButton(true);
        end


        function clickButtonMoveUp(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end
            if any(this.mSelectedTableRow==0)
                return;
            end


            sourceRow=this.mSelectedTableRow+1;


            params=fields(this.mBlockPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlockPrms.(param);


                for selIdx=sort(sourceRow,'ascend')
                    value=swap(value,selIdx,selIdx-1);
                end
                this.mBlockPrms.(param)=value;
            end
            this.assertAttribTableConsistency();


            this.mSelectedTableRow=this.mSelectedTableRow-1;
            dialog.selectTableRows('tableAttribs',this.mSelectedTableRow);

            dialog.enableApplyButton(true);
        end


        function clickButtonMoveDown(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            numRows=length(this.mBlockPrms.AttributeName);
            if any(this.mSelectedTableRow==numRows-1)
                return;
            end


            sourceRow=this.mSelectedTableRow+1;


            params=fields(this.mBlockPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlockPrms.(param);


                for selIdx=sort(sourceRow,'descend')
                    value=swap(value,selIdx,selIdx+1);
                end
                this.mBlockPrms.(param)=value;
            end
            this.assertAttribTableConsistency();


            this.mSelectedTableRow=this.mSelectedTableRow+1;
            dialog.selectTableRows('tableAttribs',this.mSelectedTableRow);

            dialog.enableApplyButton(true);
        end


        function clickButtonAdd(this,dialog)


            attribs=this.mBlockPrms.AttributeName;
            oldNumAtts=length(attribs);


            newAttrib=['Attribute',num2str(oldNumAtts+1)];
            newAttribSet=[attribs,newAttrib];
            newNumAtts=length(newAttribSet);


            if newNumAtts>this.getMaxNumRowsAllowedInTable()
                this.mChildErrorDlgs=...
                this.errorDuringCallback(...
                dialog,...
                DAStudio.message('SimulinkDiscreteEvent:dialog:MaxTableSizeError',...
                this.getMaxNumRowsAllowedInTable()),...
                this.mChildErrorDlgs);
                return;
            end


            this.mBlockPrms.AttributeName=newAttribSet;
            params=setdiff(fields(this.mBlockPrms),'AttributeName');
            for idx=1:length(params)
                param=params{idx};
                defaultValue=this.getParamDefaultValue(param);
                this.mBlockPrms.(param)=[this.mBlockPrms.(param),...
                repmat({defaultValue},1,newNumAtts-oldNumAtts)];
            end
            this.assertAttribTableConsistency();

            this.mSelectedTableRow=newNumAtts-1;
            dialog.enableApplyButton(true);
        end


        function clickButtonCopy(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            idxToCopy=this.mSelectedTableRow+1;


            newAttrib=this.mBlockPrms.AttributeName{idxToCopy};
            attribs=this.mBlockPrms.AttributeName;
            newAttribSet=[attribs,newAttrib];
            newNumAtts=length(newAttribSet);


            if newNumAtts>this.getMaxNumRowsAllowedInTable()
                this.mChildErrorDlgs=...
                this.errorDuringCallback(...
                dialog,...
                DAStudio.message('SimulinkDiscreteEvent:dialog:MaxTableSizeError',...
                this.getMaxNumRowsAllowedInTable()),...
                this.mChildErrorDlgs);
                return;
            end


            this.mBlockPrms.AttributeName=newAttribSet;
            params=setdiff(fields(this.mBlockPrms),'AttributeName');
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlockPrms.(param);
                copy=value{idxToCopy};
                this.mBlockPrms.(param)=[value,copy];
            end
            this.assertAttribTableConsistency();

            this.mSelectedTableRow=newNumAtts-1;
            dialog.enableApplyButton(true);
        end


        function clickButtonDelete(this,dialog)


            this.clickButtonMoveLeft(dialog);
        end


        function selectAttribInList(this,dialog,row,col)



            unused_variable(row,col);

            entries=this.clean(this.mDispAttribList);
            rows=double(dialog.getSelectedTableRows('listSelect'));
            this.mSelectedItem={};

            if isempty(rows)
                dialog.setEnabled('buttonMoveRight',false);
            else

                for idx=1:length(rows)
                    row=rows(idx);
                    if row+1<=length(entries)
                        this.mSelectedItem=[this.mSelectedItem,entries{row+1}];
                    end
                end

                dialog.setEnabled('buttonMoveRight',...
                ~isempty(setdiff(this.mSelectedItem,...
                this.mBlockPrms.AttributeName)));
            end
        end


        function selectAttribInTable(this,dialog,row,col)


            unused_variable(row,col);

            selRows=double(dialog.getSelectedTableRows('tableAttribs'));
            this.mSelectedTableRow=selRows;

            numRows=length(this.mBlockPrms.AttributeName);
            dialog.setEnabled('buttonMoveUp',~any(selRows==0));
            dialog.setEnabled('buttonMoveDown',~any(selRows==numRows-1));
            dialog.setEnabled('buttonCopy',isscalar(selRows));
            dialog.setEnabled('buttonMoveLeft',this.getButtonMoveLeftEnableState());
        end

    end


    methods(Access=protected)


        function schema=getMainTabSchema(this)


            groupLeft=this.getAttributeSelectorSchema();
            groupRight=this.getAttributeTableSchema('tableAttribs');

            panel.Type='panel';
            panel.Items={groupLeft,groupRight};
            panel.RowSpan=[1,1];
            panel.ColSpan=[1,1];
            panel.LayoutGrid=[1,2];
            panel.ColStretch=[1,2];

            schema.Name=this.MsgMain;
            schema.Items={panel};
        end


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name=this.getDefaultBlockName();
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getAttributeSelectorSchema(this)


            imgFind.Type='image';
            imgFind.Tag='imageFind';
            imgFind.FilePath=this.getIconPath('FilterFunnel.png');
            imgFind.Enabled=~isempty(this.mPropAttribs);
            imgFind.RowSpan=[1,1];
            imgFind.ColSpan=[1,1];

            editFindAttrib.Type='edit';
            editFindAttrib.Tag='editAttribName';
            editFindAttrib.Name='';
            editFindAttrib.NameLocation=1;
            editFindAttrib.Source=this;
            editFindAttrib.ObjectProperty='mFilterStr';
            editFindAttrib.ObjectMethod='applyAttribFilter';
            editFindAttrib.MethodArgs={'%dialog'};
            editFindAttrib.ArgDataTypes={'handle'};
            editFindAttrib.Mode=true;
            editFindAttrib.RespondsToTextChanged=true;
            editFindAttrib.Clearable=true;
            editFindAttrib.PlaceholderText=this.MsgFilterByName;
            editFindAttrib.Enabled=~isempty(this.mPropAttribs);
            editFindAttrib.Graphical=true;
            editFindAttrib.ToolTip=this.MsgTipFilterAttribs;
            editFindAttrib.RowSpan=[1,1];
            editFindAttrib.ColSpan=[2,3];


            if~isempty(this.mPropAttribs)
                attribsMayBeMissing=this.mPropAttribs(~this.mPresence);
                attribList=this.mPropAttribs;


                if~isempty(this.mFilterStr)
                    idx=strfind(lower(this.mPropAttribs),lower(this.mFilterStr));
                    logIdx=cellfun(@(x)~isempty(x),idx);
                    attribList=this.mPropAttribs(logIdx);
                end


                for idx=1:length(attribList)
                    attribName=attribList{idx};
                    if~isempty(intersect(attribsMayBeMissing,attribName))
                        attribList{idx}=[attribName,this.getSymbolForMissingAttrib()];
                    end
                end

                if~isempty(attribList)&&isempty(this.mSelectedItem)
                    this.mSelectedItem=attribList{1};
                end
            else
                attribList={this.MsgNoAttribAvailable};
                attribsMayBeMissing={};
            end
            this.mDispAttribList=attribList;


            numRows=length(this.mDispAttribList);
            listData=cell(numRows,2);
            isAnyAttributeSelectedFromList=false;
            for idx=1:numRows

                attribName=this.clean(this.mDispAttribList{idx});
                isSelected=~isempty(intersect(this.mBlockPrms.AttributeName,attribName));

                cellSelected.Type='edit';
                cellSelected.Name='';

                if~isSelected
                    cellSelected.Value='';
                    cellSelected.Enabled=true;
                else
                    cellSelected.Value=this.getSymbolForSelectedAttrib();
                    cellSelected.Enabled=false;
                    isAnyAttributeSelectedFromList=true;
                end

                cellName.Type='edit';
                cellName.Name='';
                cellName.Value=this.mDispAttribList{idx};
                cellName.Enabled=cellSelected.Enabled;

                listData{idx,1}=cellSelected;
                listData{idx,2}=cellName;
            end

            listAttribs.Type='table';
            listAttribs.Tag='listSelect';
            listAttribs.Size=[numRows,2];
            listAttribs.Data=listData;
            listAttribs.Grid=false;
            listAttribs.SelectionBehavior='Row';
            listAttribs.HeaderVisibility=[0,0];
            listAttribs.ColumnHeaderHeight=0;
            listAttribs.ColHeader=this.MsgListColumnHeadings;
            listAttribs.RowHeaderWidth=0;
            listAttribs.Editable=false;
            listAttribs.Name='';
            listAttribs.HideName=true;
            listAttribs.Source=this;
            listAttribs.CurrentItemChangedCallback=@(d,r,c)this.selectAttribInList(d,r,c);
            listAttribs.Graphical=true;
            listAttribs.RowSpan=[2,7];
            listAttribs.ColSpan=[1,3];
            listAttribs.ColumnCharacterWidth=[2,10];
            listAttribs.DialogRefresh=1;
            listAttribs.ColumnStretchable=[0,1];
            listAttribs.Enabled=~isempty(this.mPropAttribs);
            if~listAttribs.Enabled
                listAttribs.SelectedRow=1;
                listAttribs.ToolTip=this.MsgTipAttribListEmpty;
            else
                listAttribs.ToolTip=this.MsgTipAttribList;
            end

            txtFootnoteSelected.Type='text';
            txtFootnoteSelected.Tag='txtFootnoteSelected';
            txtFootnoteSelected.Buddy='checkShowAllAttribs';
            txtFootnoteSelected.Name=[this.getSymbolForSelectedAttrib(),' ',this.MsgAttribSelectedFootnote];
            txtFootnoteSelected.Graphical=true;
            txtFootnoteSelected.Alignment=2;
            txtFootnoteSelected.Enabled=false;
            txtFootnoteSelected.Visible=~isempty(this.mPropAttribs)&&isAnyAttributeSelectedFromList;
            txtFootnoteSelected.RowSpan=[8,8];
            txtFootnoteSelected.ColSpan=[1,5];

            txtFootnoteMissing.Type='text';
            txtFootnoteMissing.Tag='txtFootnoteMissing';
            txtFootnoteMissing.Buddy='checkShowAllAttribs';
            txtFootnoteMissing.Graphical=true;
            txtFootnoteMissing.Name=[this.getSymbolForMissingAttrib(),' ',this.MsgAttribMissingFootnote];
            txtFootnoteMissing.Alignment=2;
            txtFootnoteMissing.Enabled=false;
            txtFootnoteMissing.Visible=~isempty(attribsMayBeMissing);
            txtFootnoteMissing.RowSpan=[9,9];
            txtFootnoteMissing.ColSpan=[1,4];

            buttonRefresh.Type='pushbutton';
            buttonRefresh.Tag='buttonRefresh';
            buttonRefresh.FilePath=this.getIconPath('refresh.png');
            buttonRefresh.ToolTip=this.MsgRefreshAttribList;
            buttonRefresh.ObjectMethod='refreshPropagatedData';
            buttonRefresh.Source=this;
            buttonRefresh.MethodArgs={true};
            buttonRefresh.ArgDataTypes={'bool'};
            buttonRefresh.RowSpan=[2,2];
            buttonRefresh.ColSpan=[4,4];
            buttonRefresh.DialogRefresh=true;

            buttonMoveRight.Type='pushbutton';
            buttonMoveRight.Tag='buttonMoveRight';
            buttonMoveRight.FilePath=this.getIconPath('move_right.gif');
            buttonMoveRight.ToolTip=this.MsgAddSelectedToTable;
            buttonMoveRight.ObjectMethod='clickButtonMoveRight';
            buttonMoveRight.Source=this;
            buttonMoveRight.MethodArgs={'%dialog'};
            buttonMoveRight.ArgDataTypes={'handle'};
            buttonMoveRight.RowSpan=[3,3];
            buttonMoveRight.ColSpan=[4,4];
            buttonMoveRight.Enabled=~isempty(this.mDispAttribList)&&~isempty(this.mSelectedItem)&&isempty(intersect(this.mSelectedItem,this.mBlockPrms.AttributeName));
            buttonMoveRight.DialogRefresh=true;
            buttonMoveRight.Graphical=false;

            buttonMoveLeft.Type='pushbutton';
            buttonMoveLeft.Tag='buttonMoveLeft';
            buttonMoveLeft.FilePath=this.getIconPath('move_left.gif');
            buttonMoveLeft.ToolTip=this.MsgRemoveFromTable;
            buttonMoveLeft.ObjectMethod='clickButtonMoveLeft';
            buttonMoveLeft.Source=this;
            buttonMoveLeft.MethodArgs={'%dialog'};
            buttonMoveLeft.ArgDataTypes={'handle'};
            buttonMoveLeft.RowSpan=[4,4];
            buttonMoveLeft.ColSpan=[4,4];
            buttonMoveLeft.Enabled=this.getButtonMoveLeftEnableState();
            buttonMoveLeft.DialogRefresh=true;
            buttonMoveLeft.Graphical=false;
            buttonMoveLeft.Visible=false;

            allItems={...
            imgFind,...
            editFindAttrib,...
            listAttribs,...
            buttonRefresh,...
            buttonMoveRight,...
            buttonMoveLeft,...
            txtFootnoteSelected,...
            txtFootnoteMissing};

            schema.Type='group';
            schema.Tag='groupAttribSelector';
            schema.Items=allItems;
            schema.Name=this.MsgAvailableAttribs;
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
            schema.LayoutGrid=[9,4];
            schema.RowStretch=[0,1,1,1,1,1,1,0,0];
            schema.ColStretch=[1,1,1,0];
        end


        function schema=getButtonAddRowSchema(this)


            schema.Type='pushbutton';
            schema.Tag='buttonAdd';
            schema.FilePath=this.getIconPath('add.png');
            schema.ToolTip=this.MsgAddNewRow;
            schema.ObjectMethod='clickButtonAdd';
            schema.Source=this;
            schema.MethodArgs={'%dialog'};
            schema.ArgDataTypes={'handle'};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
            schema.Visible=true;
            schema.Enabled=true;
            schema.DialogRefresh=true;
            schema.Graphical=false;
        end


        function schema=getButtonCopyRowSchema(this)


            schema.Type='pushbutton';
            schema.Tag='buttonCopy';
            schema.FilePath=this.getIconPath('copy.gif');
            schema.ToolTip=this.MsgCopySelectedRow;
            schema.ObjectMethod='clickButtonCopy';
            schema.Source=this;
            schema.MethodArgs={'%dialog'};
            schema.ArgDataTypes={'handle'};
            schema.RowSpan=[1,1];
            schema.ColSpan=[2,2];
            schema.Visible=true;
            schema.Enabled=~isempty(this.mBlockPrms.AttributeName)&&isscalar(this.mSelectedTableRow);
            schema.DialogRefresh=true;
            schema.Graphical=false;
        end


        function schema=getButtonDeleteRowSchema(this)


            schema.Type='pushbutton';
            schema.Tag='buttonDelete';
            schema.FilePath=this.getIconPath('delete.gif');
            schema.ToolTip=this.MsgDeleteSelectedRow;
            schema.ObjectMethod='clickButtonDelete';
            schema.Source=this;
            schema.MethodArgs={'%dialog'};
            schema.ArgDataTypes={'handle'};
            schema.RowSpan=[1,1];
            schema.ColSpan=[3,3];
            schema.Visible=true;
            schema.Enabled=~isempty(this.mBlockPrms.AttributeName);
            schema.DialogRefresh=true;
            schema.Graphical=false;
        end


        function schema=getButtonMoveRowUpSchema(this)


            numRows=length(this.mBlockPrms.AttributeName);

            schema.Type='pushbutton';
            schema.Tag='buttonMoveUp';
            schema.FilePath=this.getIconPath('move_up.gif');
            schema.ToolTip=this.MsgMoveSelectedRowUp;
            schema.ObjectMethod='clickButtonMoveUp';
            schema.Source=this;
            schema.MethodArgs={'%dialog'};
            schema.ArgDataTypes={'handle'};
            schema.RowSpan=[1,1];
            schema.ColSpan=[4,4];
            schema.Enabled=numRows>1&&all(this.mSelectedTableRow>0)&&all(this.mSelectedTableRow<numRows);
            schema.DialogRefresh=true;
            schema.Graphical=false;
            schema.Visible=false;
        end


        function schema=getButtonMoveRowDownSchema(this)


            numRows=length(this.mBlockPrms.AttributeName);

            schema.Type='pushbutton';
            schema.Tag='buttonMoveDown';
            schema.FilePath=this.getIconPath('move_down.gif');
            schema.ToolTip=this.MsgMoveSelectedRowDown;
            schema.ObjectMethod='clickButtonMoveDown';
            schema.Source=this;
            schema.MethodArgs={'%dialog'};
            schema.ArgDataTypes={'handle'};
            schema.RowSpan=[1,1];
            schema.ColSpan=[5,5];
            schema.Enabled=numRows>1&&all(this.mSelectedTableRow<numRows-1);
            schema.DialogRefresh=true;
            schema.Graphical=false;
            schema.Visible=false;
        end


        function schema=getStatisticsSchema(this)


            numDeparted.Type='checkbox';
            numDeparted.Tag='NumberEntitiesDeparted';
            numDeparted.Name=this.MsgNumberEntitiesDeparted;
            numDeparted.Source=this.mBlock;
            numDeparted.ObjectProperty='NumberEntitiesDeparted';
            numDeparted.Mode=true;
            numDeparted.RowSpan=[1,1];
            numDeparted.ColSpan=[1,1];

            spacer.Type='text';
            spacer.Name='';
            spacer.RowSpan=[2,8];
            spacer.ColSpan=[1,1];

            schema.Name=this.MsgStatistics;
            schema.Items={numDeparted,spacer};
        end


        function p=getIconPath(this,fName)


            unused_variable(this);
            switch fName
            case 'refresh.png'
                p=fullfile(matlabroot,'toolbox','shared','dastudio',...
                'resources','glue','Toolbars','16px','UpdateDiagram_16.png');
            otherwise
                p=fullfile(matlabroot,'toolbox','shared','dastudio','resources',fName);
            end
            assert(exist(p,'file')==2);
        end


        function validateNonZeroRowsInTable(this)



            if des.afb.isInsideAfb(this.mBlock.getFullName())
                return;
            end
            if isempty(this.mBlockPrms.AttributeName)
                DAStudio.error('SimulinkDiscreteEvent:block:TableSizeZeroAttribSelector');
            end
        end


        function cacheParams(this)


            params=fields(this.mBlockPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlock.(param);
                this.mBlockPrms.(param)=slde.util.cellpipe(value);
            end
            this.assertAttribTableConsistency();
            this.mSelectedTableRow=0;
            this.mSelectedItem={};
        end


        function saveChangesToBlock(this)


            setParamCmd='set_param(this.mBlock.Handle, ';
            atLeastOneChange=false;

            params=fields(this.mBlockPrms);
            for idx=1:length(params)
                param=params{idx};
                value=slde.util.cellpipe(this.mBlockPrms.(param));

                if~strcmp(this.mBlock.(param),value)
                    setParamCmd=cat(2,setParamCmd,['...\n\t''',param,''', ''',value,''', ']);
                    atLeastOneChange=true;
                end
            end

            if atLeastOneChange
                setParamCmd=cat(2,setParamCmd(1:end-2),');');
                setParamCmd=sprintf(setParamCmd);
                eval(setParamCmd);
            end
        end


        function assertAttribTableConsistency(this)



            params=fields(this.mBlockPrms);
            sz=cellfun(@(x)length(this.mBlockPrms.(x)),params);
            assert(isequal(sz,circshift(sz,1)));
        end


        function isEnabled=getButtonMoveLeftEnableState(this)


            if isempty(this.mSelectedTableRow)||...
                isempty(this.mBlockPrms.AttributeName)||...
                isempty(this.mPropAttribs)
                isEnabled=false;
            else
                selNames=this.mBlockPrms.AttributeName(this.mSelectedTableRow+1);
                isEnabled=~isempty(intersect(this.mPropAttribs,selNames));
            end
        end


        function result=isPropagatedAttribute(this,attribName)


            result=~isempty(intersect(this.mPropAttribs,attribName));
        end


        function sym=getSymbolForSelectedAttrib(~)


            sym='>';
        end


        function sym=getSymbolForMissingAttrib(~)


            sym='*';
        end


        function sym=getSymbolForUnrecognizedAttrib(~)



            sym='??';
        end


        function cleanedNames=clean(this,attribNames)


            cleanedNames=strrep(attribNames,this.getSymbolForMissingAttrib(),'');
        end


        function num=getMaxNumRowsAllowedInTable(~)


            num=32;
        end


        function[childErrDlgs]=errorDuringCallback(this,dialog,msg,childErrDlgs)




            unused_variable(this);

            dp=DAStudio.DialogProvider;


            msgError=DAStudio.message('Simulink:dialog:ErrorText');
            dialogTitle=[msgError,': ',dialog.getTitle()];


            hdl=dp.errordlg(msg,dialogTitle,true);



            childErrDlgs=[childErrDlgs,hdl];
        end
    end
end




function set=swap(set,i,j)

    temp=set{i};
    set{i}=set{j};
    set{j}=temp;
end


function unused_variable(varargin)
end





