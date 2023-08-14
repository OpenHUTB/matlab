classdef ResourceAcquire<slde.ddg.ResourceSelector&slde.ddg.EventActionsTab





    properties(Access=private,Constant)

        AmountSourceOptions=slde.ddg.EnumStrs(...
        'SimulinkDiscreteEvent:dialog:Dialog',...
        'SimulinkDiscreteEvent:dialog:Attribute',...
        slde.ddg.EnumStrs.ZeroBased);

        AmountSource_Dialog=0;
        AmountSource_Signal=1;

        ResourceParams={...
        'ResourceName',...
        'ResourceAmountSource',...
        'ResourceAmount'};

        MsgTableColumnHeadings={...
        DAStudio.message('SimulinkDiscreteEvent:dialog:TResourceName'),...
        DAStudio.message('SimulinkDiscreteEvent:dialog:TResourceAmountSource'),...
        DAStudio.message('SimulinkDiscreteEvent:dialog:TResourceAmountValue')};

        IdxType=0;
        IdxFrom=1;
        IdxValue=2;
        NumColumns=3;

        MsgUnused=DAStudio.message('SimulinkDiscreteEvent:dialog:unused');
        MsgDefaultBlockName=DAStudio.message('SimulinkDiscreteEvent:dialog:ResourceAcquire');
        MsgTipResourceTable=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipResourceAcquireTable');
        MsgTipUnrecogResource=DAStudio.message('SimulinkDiscreteEvent:dialog:ToolTipAcquireUnrecognizedResource');

        MsgCapacity=DAStudio.message('SimulinkDiscreteEvent:dialog:MaxNumberEntities');
        MsgOnEntityEntryFunc=DAStudio.message('SimulinkDiscreteEvent:dialog:OnEntityEntryFunction');
        MsgOnEntityExitFunc=DAStudio.message('SimulinkDiscreteEvent:dialog:OnEntityExitFunction');
        MsgTimeout=DAStudio.message('SimulinkDiscreteEvent:dialog:Timeout');
        MsgEnableTOPort=DAStudio.message('SimulinkDiscreteEvent:dialog:EnableTOPort');
        MsgStatNumberInBlock=DAStudio.message('SimulinkDiscreteEvent:dialog:StatNumberInBlock');
        MsgStatAverageWait=DAStudio.message('SimulinkDiscreteEvent:dialog:StatAverageWait');
        MsgStatNumberTimedout=DAStudio.message('SimulinkDiscreteEvent:dialog:StatNumberTimedout');
    end


    properties(Access=private)
        mTableTag;
    end


    methods


        function this=ResourceAcquire(blk,udd)


            this@slde.ddg.ResourceSelector(blk,udd);
            this@slde.ddg.EventActionsTab(blk,udd);

            this.mTableTag='';
            this.mUddParent=udd;


            this.evActionTabId=1;
        end


        function schema=getDialogSchema(this)


            this.refreshPropagatedData();

            blockDesc=this.getBlockDescriptionSchema();
            mainTab=this.getMainTabSchema();
            eventActionsTab=this.getEventActionsTabSchema();
            timeoutTab=this.getTimeoutTabSchema();
            statsTab=this.getStatisticsSchema();

            tabCont.Type='tab';
            tabCont.Tabs={mainTab,eventActionsTab,statsTab};
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
            schema.ExplicitShow=true;
        end


        function schema=getGeneralParamSchema(this)


            FcnPrototypes=get_param(this.mBlock.Handle,'EditTimeFcn');

            capacity.Type='edit';
            capacity.Tag='NumberWaitingEntities';
            capacity.Name=this.MsgCapacity;
            capacity.Source=this.mBlock;
            capacity.ObjectProperty='NumberWaitingEntities';
            capacity.RowSpan=[1,1];
            capacity.ColSpan=[1,1];

            schema.Type='group';
            schema.Name=this.MsgParameters;
            schema.Items={capacity};
            schema.LayoutGrid=[2,1];
            schema.RowSpan=[2,1];
            schema.ColSpan=[1,1];
        end



        function schema=getEventActionsTabSchema(this)
            schema=getEventActionsTabSchema@slde.ddg.EventActionsTab(this);
        end


        function schema=getTimeoutTabSchema(this)


            enableTOPort.Type='checkbox';
            enableTOPort.Tag='EnableTOPort';
            enableTOPort.Name=this.MsgEnableTOPort;
            enableTOPort.Source=this.mBlock;
            enableTOPort.ObjectProperty='EnableTOPort';
            enableTOPort.RowSpan=[1,1];
            enableTOPort.ColSpan=[1,1];

            spacer.Type='text';
            spacer.Name='';
            spacer.RowSpan=[2,8];
            spacer.ColSpan=[1,1];

            schema.Name=this.MsgTimeout;
            schema.Items={enableTOPort,spacer};
        end


        function schema=getStatisticsSchema(this)


            numDeparted.Type='checkbox';
            numDeparted.Tag='NumberEntitiesDeparted';
            numDeparted.Name=this.MsgStatNumberDeparted;
            numDeparted.Source=this.mBlock;
            numDeparted.ObjectProperty='NumberEntitiesDeparted';
            numDeparted.RowSpan=[1,1];
            numDeparted.ColSpan=[1,1];

            numInBlock.Type='checkbox';
            numInBlock.Tag='NumberEntitiesInBlock';
            numInBlock.Name=this.MsgStatNumberInBlock;
            numInBlock.Source=this.mBlock;
            numInBlock.ObjectProperty='NumberEntitiesInBlock';
            numInBlock.RowSpan=[2,2];
            numInBlock.ColSpan=[1,1];

            averageWait.Type='checkbox';
            averageWait.Tag='AverageWait';
            averageWait.Name=this.MsgStatAverageWait;
            averageWait.Source=this.mBlock;
            averageWait.ObjectProperty='AverageWait';
            averageWait.RowSpan=[3,3];
            averageWait.ColSpan=[1,1];

            numExtracted.Type='checkbox';
            numExtracted.Tag='NumEntitiesExtracted';
            numExtracted.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesExtracted');
            numExtracted.Source=this.mBlock;
            numExtracted.ObjectProperty='NumEntitiesExtracted';
            numExtracted.RowSpan=[4,4];
            numExtracted.ColSpan=[1,1];

            spacer.Type='text';
            spacer.Name='';
            spacer.RowSpan=[5,8];
            spacer.ColSpan=[1,1];

            schema.Name=this.MsgStatistics;
            schema.Items={numDeparted,numInBlock,averageWait,numExtracted,spacer};

        end


        function schema=getResourceTableSchema(this,tag)


            this.mTableTag=tag;

            numRows=length(this.mBlockPrms.ResourceName);
            numCols=this.NumColumns;

            tableData=cell(numRows,numCols);
            rowHeader=arrayfun(@(x)num2str(x),1:numRows,'uniformoutput',false);
            rowHeaderWidth=2;
            hasUnrecognizedResourceNames=false;

            for i=1:numRows
                resourceName=this.mBlockPrms.ResourceName{i};
                if~this.isPropagatedResource(resourceName)
                    rowHeader{i}=strcat(rowHeader{i},...
                    [' ',this.getSymbolForUnrecognizedResource()]);
                    rowHeaderWidth=3;
                    hasUnrecognizedResourceNames=true;
                end

                cellResourceName.Type='edit';
                cellResourceName.Name='';
                cellResourceName.Value=resourceName;

                fromOptStr=this.mBlockPrms.ResourceAmountSource{i};

                cellAmountSource.Type='combobox';
                cellAmountSource.Entries=this.AmountSourceOptions.getStrs();
                cellAmountSource.Value=this.AmountSourceOptions.strToEnum(fromOptStr);
                cellAmountSource.Enabled=true;

                val=this.mBlockPrms.ResourceAmount{i};
                cellAmountVal.Type='combobox';
                cellAmountVal.Name='';
                cellAmountVal.Value=val;
                cellAmountVal.Enabled=true;
                cellAmountVal.Editable=true;
                if isequal(cellAmountSource.Value,1)
                    vals=this.getEditTimeAttributes(this.getSigHierFromPort());
                    cellAmountVal.Entries=vals;
                    if isvarname(val)
                        cellAmountVal.Entries=[val,vals];
                    end
                elseif isequal(cellAmountSource.Value,0)
                    cellAmountVal.Entries={val};
                end

                tableData{i,this.IdxType+1}=cellResourceName;
                tableData{i,this.IdxFrom+1}=cellAmountSource;
                tableData{i,this.IdxValue+1}=cellAmountVal;
            end

            tableResources.Type='table';
            tableResources.Tag=this.mTableTag;
            tableResources.Size=[numRows,numCols];
            tableResources.Data=tableData;
            tableResources.Grid=true;
            tableResources.SelectionBehavior='Row';
            tableResources.HeaderVisibility=[1,1];
            tableResources.ColHeader=this.MsgTableColumnHeadings;
            tableResources.RowHeader=rowHeader;
            tableResources.ColumnHeaderHeight=2;
            tableResources.RowHeaderWidth=rowHeaderWidth;
            tableResources.Editable=true;
            tableResources.CurrentItemChangedCallback=@(d,r,c)this.selectResourceInTable(d,r,c);
            tableResources.ValueChangedCallback=@(d,r,c,v)this.resourceTableValueChanged(d,r,c,v);
            tableResources.RowSpan=[2,7];
            tableResources.ColSpan=[1,12];
            tableResources.MinimumSize=[350,250];
            tableResources.DialogRefresh=1;
            tableResources.ColumnStretchable=[1,1,1,0];
            tableResources.ColumnCharacterWidth=[15,15,20,8];
            if isscalar(this.mSelectedTableRow)
                tableResources.SelectedRow=double(this.mSelectedTableRow);
            end

            buttonAdd=this.getButtonAddRowSchema();
            buttonCopy=this.getButtonCopyRowSchema();
            buttonDelete=this.getButtonDeleteRowSchema();
            buttonMoveUp=this.getButtonMoveRowUpSchema();
            buttonMoveDown=this.getButtonMoveRowDownSchema();

            items={...
            tableResources,...
            buttonAdd,...
            buttonCopy,...
            buttonDelete,...
            buttonMoveUp,...
            buttonMoveDown};

            schema.Type='group';
            schema.Tag='groupResourceAcquire';
            schema.Name=this.MsgSelectedResources;
            schema.Items=items;
            schema.RowSpan=[1,1];
            schema.ColSpan=[2,2];
            schema.LayoutGrid=[7,12];
            schema.RowStretch=[0,1,1,1,1,1,1];
            schema.ColStretch=[0,0,0,0,0,1,1,1,1,1,1,1];

            if hasUnrecognizedResourceNames
                schema.ToolTip=sprintf('%s\n"%s" - %s',...
                this.MsgTipResourceTable,...
                this.getSymbolForUnrecognizedResource(),...
                this.MsgTipUnrecogResource);
            else
                schema.ToolTip=this.MsgTipResourceTable;
            end
        end


        function resourceTableValueChanged(this,dialog,row,col,value)


            unused_variable(dialog);

            switch col

            case this.IdxType
                this.mBlockPrms.ResourceName{row+1}=value;
                dialog.refresh();

            case this.IdxFrom
                valStr=this.AmountSourceOptions.enumToStr(value);
                selRows=dialog.getSelectedTableRows(this.mTableTag);
                for row=selRows
                    this.mBlockPrms.ResourceAmountSource{row+1}=valStr;
                end
                dialog.refresh();

            case this.IdxValue
                this.mBlockPrms.ResourceAmount{row+1}=value;

            end
        end


        function params=getResourceParams(this)


            params=this.ResourceParams;
        end


        function defaultValue=getParamDefaultValue(this,param)


            unused_variable(this);

            switch param
            case 'ResourceAmountSource'
                defaultValue=this.AmountSourceOptions.enumToStr(...
                this.AmountSource_Dialog);

            case 'ResourceAmount'
                defaultValue='1';

            otherwise
                assert(false);
            end
        end


        function name=getDefaultBlockName(this)



            name=this.MsgDefaultBlockName;
        end


        function allowed=getIsEmptyResourceTableAllowed(this)


            unused_variable(this);
            allowed=false;
        end



        function evActionAttribs=getEventActionAttributes(this)

            evActionAttribs{1}.Name='Entry';
            evActionAttribs{1}.Tag='EntryAction';
            evActionAttribs{1}.ObjectProperty='EntryAction';
            evActionAttribs{1}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgEntryAction';
            evActionAttribs{1}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipEntryAction';


            evActionAttribs{2}.Name='Exit';
            evActionAttribs{2}.Tag='ExitAction';
            evActionAttribs{2}.ObjectProperty='ExitAction';
            evActionAttribs{2}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgExitAction';
            evActionAttribs{2}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipExitAction';


            evActionAttribs{3}.Name='Blocked';
            evActionAttribs{3}.Tag='BlockedAction';
            evActionAttribs{3}.ObjectProperty='BlockedAction';
            evActionAttribs{3}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgBlockedAction';
            evActionAttribs{3}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipBlockedAction';
        end


        function closeCallback(this,dialog,closeAction)


            if strcmp(closeAction,'cancel')
                this.revertEventActions();
            end

            closeCallback@slde.ddg.ResourceSelector(this,dialog)

        end


        function[status,msg]=preApplyCallback(this,dialog)

            try
                this.cacheEventAction();
                [status,msg]=preApplyCallback@slde.ddg.ResourceSelector(this,dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end



        function sigHier=getSigHierFromPort(this)
            pHandles=get_param(this.mBlock.Handle,'PortHandles');
            sigHier=get_param(pHandles.Inport(1),...
            'SignalHierarchy');
        end

    end

end


function unused_variable(varargin)
end


