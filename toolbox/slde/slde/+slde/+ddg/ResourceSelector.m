classdef ResourceSelector<handle





    properties(Access=protected)
        mBlock;
        mUddParent;
        mBlockPrms;
        mAllResources;
        mDispResourceList;
        mChildErrorDlgs;
        mDispTable;

        MsgParameters=DAStudio.message('SimulinkDiscreteEvent:dialog:Parameters');
        MsgSelectedResources=DAStudio.message('SimulinkDiscreteEvent:dialog:SelectedResources');
        MsgStatNumberDeparted=DAStudio.message('SimulinkDiscreteEvent:dialog:StatNumberDeparted');
        MsgStatistics=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
    end


    properties(SetObservable=true,Hidden)
        mFilterStr;
        mSelectedTableRow;
        mSelectedItem;
    end


    properties(Access=private,Constant)

        MsgNoResourceAvailable=DAStudio.message('SimulinkDiscreteEvent:dialog:NoResourcesAvailable');
        MsgResourceSelectedFootnote=DAStudio.message('SimulinkDiscreteEvent:dialog:ResourceSelectedFootnote');
        MsgResourceMissingFootnote=DAStudio.message('SimulinkDiscreteEvent:dialog:ResourceMissingFootnote');
        MsgAvailableResources=DAStudio.message('SimulinkDiscreteEvent:dialog:AvailableResources');
        MsgFilterByName=DAStudio.message('SimulinkDiscreteEvent:dialog:FilterByName');
        MsgMain=DAStudio.message('SimulinkDiscreteEvent:dialog:Main');


        MsgRefreshResourceList=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipRefreshResourceList');
        MsgAddSelectedToTable=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAddSelectedResourceToTable');
        MsgRemoveFromTable=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipRemoveSelectedResourceFromTable');
        MsgAddNewRow=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAddNewRowToTable');
        MsgCopySelectedRow=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipCopySelectedRowInTable');
        MsgDeleteSelectedRow=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipDeleteSelectedRowFromTable');
        MsgMoveSelectedRowUp=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowUp');
        MsgMoveSelectedRowDown=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipMoveSelectedRowDown');
        MsgTipResourceMissing=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipResourceMissingFootnote');
        MsgTipShowAllResources=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipShowAllResources');
        MsgTipFilterResources=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipFilterResources');
        MsgTipResourceList=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipResourceList');
        MsgTipResourceListEmpty=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipResourceListEmpty');


        MsgListColumnHeadings={...
        DAStudio.message('SimulinkDiscreteEvent:dialog:Selected'),...
        DAStudio.message('SimulinkDiscreteEvent:dialog:TResourceName')};
    end


    properties(Access=private)
        mPropagate;
    end


    methods(Abstract)


        params=getResourceParams(this);


        schema=getGeneralParamSchema(this);


        schema=getStatisticsSchema(this);


        schema=getResourceTableSchema(this);


        name=getDefaultBlockName(this)


        default=getParamDefaultValue(this,param);


        allowed=getIsEmptyResourceTableAllowed(this);

    end


    methods


        function this=ResourceSelector(blk,udd)


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;
            this.mAllResources={};
            this.mDispResourceList={};
            this.mFilterStr='';
            this.mSelectedTableRow=0;
            this.mSelectedItem={};
            this.mChildErrorDlgs=[];
            this.mPropagate=true;
            this.mDispTable=true;


            tableParams=this.getResourceParams();
            assert(any(strcmp(tableParams,'ResourceName')));
            initialTableVals=repmat({''},1,length(tableParams));
            this.mBlockPrms=cell2struct(initialTableVals,tableParams,2);

            this.cacheParams();
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



            dialog.selectTableRow('tableResources',0);
        end


        function closeCallback(this,dialog)



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

            end
            this.mPropagate=false;

            try
                allPools=[];
                rootHdl=bdroot(this.mBlock.Handle);
                parentSS=get_param(this.mBlock.Handle,'Parent');
                parentHdl=get_param(parentSS,'Handle');
                while true
                    curPools=find_system(parentHdl,...
                    'LookUnderMasks','all',...
                    'FollowLinks','on',...
                    'SearchDepth','1',...
                    'BlockType','EntityResourcePool');
                    allPools=union(allPools,curPools);
                    if(parentHdl==rootHdl)
                        break;
                    else
                        parentSS=get_param(parentHdl,'Parent');
                        parentHdl=get_param(parentSS,'Handle');
                    end
                end

                allModelPools=find_system(rootHdl,'LookUnderMasks',...
                'all','FollowLinks','on','SearchDepth','Inf',...
                'BlockType','EntityResourcePool');

                globalPools=[];
                for i=1:length(allModelPools)
                    vis=get_param(allModelPools(i),'PoolVisibility');
                    if strcmp(vis,'Global')
                        globalPools=[globalPools,allModelPools(i)];
                    end
                end

                allPools=union(allPools,globalPools);

                if isempty(allPools)
                    this.mAllResources={};
                else
                    allTypes=get_param(allPools,'ResourceName');
                    if length(allPools)>1
                        allTypes=unique(allTypes);
                    else
                        allTypes={allTypes};
                    end
                    this.mAllResources=allTypes;
                end
            catch me %#ok<NASGU>
                this.mAllResources={};
            end
        end


        function applyResourceFilter(this,dialog)





            str=dialog.getWidgetValue('editResourceName');
            this.mFilterStr=str;
            selectResourceInList(this,dialog,'','');


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


            newResource=this.mSelectedItem;
            resources=this.mBlockPrms.ResourceName;
            newResource=setdiff(newResource,resources);
            oldNumAtts=length(resources);



            newResourceSet=[resources,newResource];
            newNumAtts=length(newResourceSet);


            this.mBlockPrms.ResourceName=newResourceSet;
            params=setdiff(fields(this.mBlockPrms),'ResourceName');
            for idx=1:length(params)
                param=params{idx};
                defaultValue=this.getParamDefaultValue(param);
                this.mBlockPrms.(param)=[this.mBlockPrms.(param),...
                repmat({defaultValue},1,newNumAtts-oldNumAtts)];
            end
            this.assertResourceTableConsistency();


            this.mSelectedTableRow=newNumAtts-1;



            count=0;
            idx=max(selRows)+1;
            nextRowToSelect=0;
            found=false;
            while count<length(this.mDispResourceList)
                if idx>=length(this.mDispResourceList)
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

            nextDispResources=this.clean(this.mDispResourceList);
            dialog.selectTableRow('listSelect',nextRowToSelect);
            this.mSelectedItem=nextDispResources(nextRowToSelect+1);

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
            this.assertResourceTableConsistency();


            if~isempty(this.mBlockPrms.ResourceName)
                if min(this.mSelectedTableRow)>=length(this.mBlockPrms.ResourceName)-1
                    this.mSelectedTableRow=length(this.mBlockPrms.ResourceName)-1;
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
            this.assertResourceTableConsistency();


            this.mSelectedTableRow=this.mSelectedTableRow-1;
            dialog.selectTableRows('tableResources',this.mSelectedTableRow);

            dialog.enableApplyButton(true);
        end


        function clickButtonMoveDown(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            numRows=length(this.mBlockPrms.ResourceName);
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
            this.assertResourceTableConsistency();


            this.mSelectedTableRow=this.mSelectedTableRow+1;
            dialog.selectTableRows('tableResources',this.mSelectedTableRow);

            dialog.enableApplyButton(true);
        end


        function clickButtonAdd(this,dialog)


            resources=this.mBlockPrms.ResourceName;
            oldNumAtts=length(resources);


            newResource=['Resource',num2str(oldNumAtts+1)];
            newResourceSet=[resources,newResource];
            newNumAtts=length(newResourceSet);


            this.mBlockPrms.ResourceName=newResourceSet;
            params=setdiff(fields(this.mBlockPrms),'ResourceName');
            for idx=1:length(params)
                param=params{idx};
                defaultValue=this.getParamDefaultValue(param);
                this.mBlockPrms.(param)=[this.mBlockPrms.(param),...
                repmat({defaultValue},1,newNumAtts-oldNumAtts)];
            end
            this.assertResourceTableConsistency();

            this.mSelectedTableRow=newNumAtts-1;
            dialog.enableApplyButton(true);
        end


        function clickButtonCopy(this,dialog)


            if isempty(this.mSelectedTableRow)
                return;
            end


            idxToCopy=this.mSelectedTableRow+1;


            newResource=this.mBlockPrms.ResourceName{idxToCopy};
            resources=this.mBlockPrms.ResourceName;
            newResourceSet=[resources,newResource];
            newNumAtts=length(newResourceSet);


            this.mBlockPrms.ResourceName=newResourceSet;
            params=setdiff(fields(this.mBlockPrms),'ResourceName');
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlockPrms.(param);
                copy=value{idxToCopy};
                this.mBlockPrms.(param)=[value,copy];
            end
            this.assertResourceTableConsistency();

            this.mSelectedTableRow=newNumAtts-1;
            dialog.enableApplyButton(true);
        end


        function clickButtonDelete(this,dialog)


            this.clickButtonMoveLeft(dialog);
        end


        function selectResourceInList(this,dialog,row,col)



            unused_variable(row,col);

            entries=this.clean(this.mDispResourceList);
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
                this.mBlockPrms.ResourceName)));
            end
        end


        function selectResourceInTable(this,dialog,row,col)


            unused_variable(row,col);

            selRows=double(dialog.getSelectedTableRows('tableResources'));
            this.mSelectedTableRow=selRows;

            numRows=length(this.mBlockPrms.ResourceName);
            dialog.setEnabled('buttonMoveUp',~any(selRows==0));
            dialog.setEnabled('buttonMoveDown',~any(selRows==numRows-1));
            dialog.setEnabled('buttonCopy',isscalar(selRows));
            dialog.setEnabled('buttonMoveLeft',this.getButtonMoveLeftEnableState());
        end

    end


    methods(Access=protected)


        function schema=getMainTabSchema(this)


            groupT=this.getGeneralParamSchema();
            groupBL=this.getResourceSelectorSchema();
            groupBR=this.getResourceTableSchema('tableResources');

            panelT.Type='panel';
            panelT.Items={groupT};
            panelT.RowSpan=[1,1];
            panelT.ColSpan=[1,1];
            panelT.LayoutGrid=[1,1];

            panelB.Type='panel';
            panelB.Items={groupBL,groupBR};
            panelB.RowSpan=[2,2];
            panelB.ColSpan=[1,1];
            panelB.LayoutGrid=[1,2];
            panelB.ColStretch=[1,2];
            panelB.Visible=this.mDispTable;

            panel.Type='panel';
            panel.Items={panelT,panelB};
            panel.RowSpan=[1,1];
            panel.ColSpan=[1,1];
            panel.LayoutGrid=[2,1];
            panel.RowStretch=[0,1];

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


        function schema=getResourceSelectorSchema(this)


            imgFind.Type='image';
            imgFind.Tag='imageFind';
            imgFind.FilePath=this.getIconPath('FilterFunnel.png');
            imgFind.Enabled=~isempty(this.mAllResources);
            imgFind.RowSpan=[1,1];
            imgFind.ColSpan=[1,1];

            editFindResource.Type='edit';
            editFindResource.Tag='editResourceName';
            editFindResource.Name='';
            editFindResource.NameLocation=1;
            editFindResource.Source=this;
            editFindResource.ObjectProperty='mFilterStr';
            editFindResource.ObjectMethod='applyResourceFilter';
            editFindResource.MethodArgs={'%dialog'};
            editFindResource.ArgDataTypes={'handle'};
            editFindResource.Mode=true;
            editFindResource.RespondsToTextChanged=true;
            editFindResource.Clearable=true;
            editFindResource.PlaceholderText=this.MsgFilterByName;
            editFindResource.Enabled=~isempty(this.mAllResources);
            editFindResource.Graphical=true;
            editFindResource.ToolTip=this.MsgTipFilterResources;
            editFindResource.RowSpan=[1,1];
            editFindResource.ColSpan=[2,3];


            if~isempty(this.mAllResources)
                resourceList=this.mAllResources;


                if~isempty(this.mFilterStr)
                    idx=strfind(lower(this.mAllResources),...
                    lower(this.mFilterStr));
                    logIdx=cellfun(@(x)~isempty(x),idx);
                    resourceList=this.mAllResources(logIdx);
                end

                if~isempty(resourceList)&&isempty(this.mSelectedItem)
                    this.mSelectedItem=resourceList{1};
                end
            else
                resourceList={this.MsgNoResourceAvailable};
            end
            this.mDispResourceList=resourceList;


            numRows=length(this.mDispResourceList);
            listData=cell(numRows,2);
            isAnyResourceSelectedFromList=false;
            for idx=1:numRows

                resourceName=this.clean(this.mDispResourceList{idx});
                isSelected=~isempty(intersect(...
                this.mBlockPrms.ResourceName,resourceName));

                cellSelected.Type='edit';
                cellSelected.Name='';

                if~isSelected
                    cellSelected.Value='';
                    cellSelected.Enabled=true;
                else
                    cellSelected.Value=this.getSymbolForSelectedResource();
                    cellSelected.Enabled=false;
                    isAnyResourceSelectedFromList=true;
                end

                cellName.Type='edit';
                cellName.Name='';
                cellName.Value=this.mDispResourceList{idx};
                cellName.Enabled=cellSelected.Enabled;

                listData{idx,1}=cellSelected;
                listData{idx,2}=cellName;
            end

            listResources.Type='table';
            listResources.Tag='listSelect';
            listResources.Size=[numRows,2];
            listResources.Data=listData;
            listResources.Grid=false;
            listResources.SelectionBehavior='Row';
            listResources.HeaderVisibility=[0,0];
            listResources.ColumnHeaderHeight=0;
            listResources.ColHeader=this.MsgListColumnHeadings;
            listResources.RowHeaderWidth=0;
            listResources.Editable=false;
            listResources.Name='';
            listResources.HideName=true;
            listResources.Source=this;
            listResources.CurrentItemChangedCallback=...
            @(d,r,c)this.selectResourceInList(d,r,c);
            listResources.Graphical=true;
            listResources.RowSpan=[2,7];
            listResources.ColSpan=[1,3];
            listResources.ColumnCharacterWidth=[2,10];
            listResources.DialogRefresh=1;
            listResources.ColumnStretchable=[0,1];
            listResources.Enabled=~isempty(this.mAllResources);
            if~listResources.Enabled
                listResources.SelectedRow=1;
                listResources.ToolTip=this.MsgTipResourceListEmpty;
            else
                listResources.ToolTip=this.MsgTipResourceList;
            end

            txtFootnoteSelected.Type='text';
            txtFootnoteSelected.Tag='txtFootnoteSelected';
            txtFootnoteSelected.Buddy='checkShowAllResources';
            txtFootnoteSelected.Name=[...
            this.getSymbolForSelectedResource(),' '...
            ,this.MsgResourceSelectedFootnote];
            txtFootnoteSelected.Graphical=true;
            txtFootnoteSelected.Alignment=2;
            txtFootnoteSelected.Enabled=false;
            txtFootnoteSelected.Visible=~isempty(this.mAllResources)...
            &&isAnyResourceSelectedFromList;
            txtFootnoteSelected.RowSpan=[8,8];
            txtFootnoteSelected.ColSpan=[1,5];

            txtFootnoteMissing.Type='text';
            txtFootnoteMissing.Tag='txtFootnoteMissing';
            txtFootnoteMissing.Buddy='checkShowAllResources';
            txtFootnoteMissing.Graphical=true;
            txtFootnoteMissing.Name=[...
            this.getSymbolForMissingResource(),' '...
            ,this.MsgResourceMissingFootnote];
            txtFootnoteMissing.Alignment=2;
            txtFootnoteMissing.Enabled=false;
            txtFootnoteMissing.Visible=false;
            txtFootnoteMissing.RowSpan=[9,9];
            txtFootnoteMissing.ColSpan=[1,4];

            buttonRefresh.Type='pushbutton';
            buttonRefresh.Tag='buttonRefresh';
            buttonRefresh.FilePath=this.getIconPath('refresh.png');
            buttonRefresh.ToolTip=this.MsgRefreshResourceList;
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
            buttonMoveRight.Enabled=~isempty(this.mDispResourceList)...
            &&~isempty(this.mSelectedItem)...
            &&isempty(intersect(this.mSelectedItem,...
            this.mBlockPrms.ResourceName));
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
            buttonMoveLeft.Visible=true;

            allItems={...
            imgFind,...
            editFindResource,...
            listResources,...
            buttonRefresh,...
            buttonMoveRight,...
            buttonMoveLeft,...
            txtFootnoteSelected,...
            txtFootnoteMissing};

            schema.Type='group';
            schema.Tag='groupResourceSelector';
            schema.Items=allItems;
            schema.Name=this.MsgAvailableResources;
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
            schema.Enabled=~isempty(this.mBlockPrms.ResourceName)&&...
            isscalar(this.mSelectedTableRow);
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
            schema.Enabled=~isempty(this.mBlockPrms.ResourceName);
            schema.DialogRefresh=true;
            schema.Graphical=false;
        end


        function schema=getButtonMoveRowUpSchema(this)


            numRows=length(this.mBlockPrms.ResourceName);

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
            schema.Enabled=numRows>1&&...
            all(this.mSelectedTableRow>0)&&...
            all(this.mSelectedTableRow<numRows);
            schema.DialogRefresh=true;
            schema.Graphical=false;

        end


        function schema=getButtonMoveRowDownSchema(this)


            numRows=length(this.mBlockPrms.ResourceName);

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



            if getIsEmptyResourceTableAllowed(this)
                return;
            end
            if isempty(this.mBlockPrms.ResourceName)
                DAStudio.error('SimulinkDiscreteEvent:block:TableSizeZeroResourceSelector');
            end
        end


        function cacheParams(this)


            params=fields(this.mBlockPrms);
            for idx=1:length(params)
                param=params{idx};
                value=this.mBlock.(param);
                this.mBlockPrms.(param)=slde.util.cellpipe(value);
            end
            this.assertResourceTableConsistency();
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
                    setParamCmd=cat(2,setParamCmd,...
                    ['...\n\t''',param,''', ''',value,''', ']);
                    atLeastOneChange=true;
                end
            end

            if atLeastOneChange
                setParamCmd=cat(2,setParamCmd(1:end-2),');');
                setParamCmd=sprintf(setParamCmd);
                eval(setParamCmd);
            end
        end


        function assertResourceTableConsistency(this)



            params=fields(this.mBlockPrms);
            sz=cellfun(@(x)length(this.mBlockPrms.(x)),params);
            assert(isequal(sz,circshift(sz,1)));
        end


        function isEnabled=getButtonMoveLeftEnableState(this)


            if isempty(this.mSelectedTableRow)||...
                isempty(this.mBlockPrms.ResourceName)||...
                isempty(this.mAllResources)
                isEnabled=false;
            else
                selNames=this.mBlockPrms.ResourceName(this.mSelectedTableRow+1);
                isEnabled=~isempty(intersect(this.mAllResources,selNames));
            end
        end


        function result=isPropagatedResource(this,resourceName)


            result=~isempty(intersect(this.mAllResources,resourceName));
        end


        function sym=getSymbolForSelectedResource(~)


            sym='>';
        end


        function sym=getSymbolForMissingResource(~)


            sym='*';
        end


        function sym=getSymbolForUnrecognizedResource(~)



            sym='??';
        end


        function cleanedNames=clean(this,resourceNames)


            cleanedNames=strrep(resourceNames,...
            this.getSymbolForMissingResource(),'');
        end


        function[childErrDlgs]=errorDuringCallback(this,dialog,...
            msg,childErrDlgs)




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

