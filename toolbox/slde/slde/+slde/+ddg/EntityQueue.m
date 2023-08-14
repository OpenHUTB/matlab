classdef EntityQueue<slde.ddg.EventActionsTab





    properties(Access=public)
        mBlock;
        mUddParent;
        mChildErrorDlgs;
mEditTimeAttribs
    end


    methods


        function this=EntityQueue(blk,udd)

            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];
            this.evActionTabId=1;
        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();
            this.mEditTimeAttribs=[this.getEditTimeAttributes(...
            this.getSigHierFromPort()),...
            'entitySys.priority'];


            mainTab=this.getMainTabSchema();
            eventActionsTab=this.getEventActionsTabSchema();
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
            schema.CloseMethod='doCloseCallback';
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','string'};
            schema.PreApplyCallback='doPreApplyCallback';
            schema.PreApplyArgs={'%source','%dialog'};
            schema.PreApplyArgsDT={'handle','handle'};
            schema.ExplicitShow=true;
        end


        function schema=getEventActionsTabSchema(this)
            schema=getEventActionsTabSchema@slde.ddg.EventActionsTab(this);
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


        function[status,msg]=preApplyCallback(this,dialog)

            try
                this.cacheEventAction();
                [status,msg]=this.mUddParent.preApplyCallback(dialog);
            catch me
                status=0;
                msg=me.message;
            end
        end


        function closeCallback(this,dialog,closeAction)



            for idx=1:length(this.mChildErrorDlgs)
                errDlg=this.mChildErrorDlgs(idx);
                if ishandle(errDlg)
                    delete(errDlg);
                end
            end
            this.mChildErrorDlgs=[];

            if strcmp(closeAction,'cancel')
                this.revertEventActions();
            end

            this.mUddParent.closeCallback(dialog);
        end



        function sigHier=getSigHierFromPort(this)
            pHandles=get_param(this.mBlock.Handle,'PortHandles');
            enArrivalSrc=get_param(this.mBlock.Handle,'EntityArrivalSource');
            if(strcmp(enArrivalSrc,'Multicast'))
                sigHier=[];
                for idx=1:numel(pHandles.Outport)
                    isMsg=get_param(pHandles.Outport(idx),'MessageMode');
                    if(strcmp(isMsg,'on')==1)
                        sigHier=get_param(pHandles.Outport(idx),...
                        'SignalHierarchy');
                        break;
                    end
                end
            else
                sigHier=get_param(pHandles.Inport(1),...
                'SignalHierarchy');
            end
        end


        function enabled=getIsEventActionVisible(this)

            enabled=~(this.getBufferMode());
        end


    end



    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Queue';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)



            rowIdx=1;
            wBufferMode.Type='checkbox';
            wBufferMode.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:OverwriteOldest');
            wBufferMode.Tag='OverwriteOldest';
            wBufferMode.ObjectProperty='OverwriteOldest';
            wBufferMode.Source=this.mBlock;
            wBufferMode.RowSpan=[rowIdx,rowIdx];
            wBufferMode.ColSpan=[1,1];
            wBufferMode.Mode=true;
            wBufferMode.DialogRefresh=true;
            wBufferMode.MatlabMethod='handleCheckEvent';
            wBufferMode.MatlabArgs={this.mUddParent,'%value',this.getPrmIdx(wBufferMode.ObjectProperty),'%dialog'};


            rowIdx=rowIdx+1;
            wCapacity.Type='edit';
            wCapacity.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Capacity');
            wCapacity.Tag='Capacity';
            wCapacity.ObjectProperty='Capacity';
            wCapacity.Source=this.mBlock;
            wCapacity.RowSpan=[rowIdx,rowIdx];
            wCapacity.ColSpan=[1,1];
            wCapacity.Mode=false;
            wCapacity.DialogRefresh=false;
            wCapacity.MatlabMethod='handleEditEvent';
            wCapacity.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wQueueType.Type='combobox';
            wQueueType.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:QueueType');
            if strcmp(this.mBlock.OverwriteOldest,'on')
                wQueueType.Entries={...
                DAStudio.message('SimulinkDiscreteEvent:dialog:FIFO'),...
                DAStudio.message('SimulinkDiscreteEvent:dialog:LIFO')};
            else
                wQueueType.Entries={...
                DAStudio.message('SimulinkDiscreteEvent:dialog:FIFO'),...
                DAStudio.message('SimulinkDiscreteEvent:dialog:LIFO'),...
                DAStudio.message('SimulinkDiscreteEvent:dialog:Priority')};
            end
            wQueueType.Tag='QueueType';
            wQueueType.ObjectProperty='QueueType';
            wQueueType.Source=this.mBlock;
            wQueueType.RowSpan=[rowIdx,rowIdx];
            wQueueType.ColSpan=[1,1];
            wQueueType.Mode=true;
            wQueueType.DialogRefresh=false;
            wQueueType.MatlabMethod='handleComboSelectionEvent';
            wQueueType.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wPrioritySource.Type='combobox';
            wPrioritySource.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:PrioritySource');
            wPrioritySource.Entries=this.mEditTimeAttribs;
            wPrioritySource.Tag='PrioritySource';
            wPrioritySource.ObjectProperty='PrioritySource';
            wPrioritySource.Source=this.mBlock;
            wPrioritySource.RowSpan=[rowIdx,rowIdx];
            wPrioritySource.ColSpan=[1,1];
            wPrioritySource.DialogRefresh=false;
            wPrioritySource.MatlabMethod='handleEditEvent';
            wPrioritySource.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wPrioritySource.Editable=true;


            rowIdx=rowIdx+1;
            wSortingDirection.Type='combobox';
            wSortingDirection.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:SortingDirection');
            wSortingDirection.Entries={...
            DAStudio.message('SimulinkDiscreteEvent:dialog:Ascending'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:Descending')};
            wSortingDirection.Tag='SortingDirection';
            wSortingDirection.ObjectProperty='SortingDirection';
            wSortingDirection.Source=this.mBlock;
            wSortingDirection.RowSpan=[rowIdx,rowIdx];
            wSortingDirection.ColSpan=[1,1];
            wSortingDirection.Mode=true;
            wSortingDirection.DialogRefresh=false;
            wSortingDirection.MatlabMethod='handleComboSelectionEvent';
            wSortingDirection.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};

            rowIdx=rowIdx+1;
            wEntitySource.Type='combobox';
            wEntitySource.Name=DAStudio.message('SimulinkDiscreteEvent:Multicast:EntitySource');
            wEntitySource.Entries={DAStudio.message('SimulinkDiscreteEvent:Multicast:InputPort')...
            ,DAStudio.message('SimulinkDiscreteEvent:Multicast:MulticastOpt')};
            wEntitySource.Tag='EntityArrivalSource';
            wEntitySource.ObjectProperty='EntityArrivalSource';
            wEntitySource.Source=this.mBlock;
            wEntitySource.RowSpan=[rowIdx,rowIdx];
            wEntitySource.ColSpan=[1,1];
            wEntitySource.Mode=true;
            wEntitySource.DialogRefresh=false;
            wEntitySource.MatlabMethod='handleComboSelectionEvent';
            wEntitySource.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};

            rowIdx=rowIdx+1;
            wMulticastSenderTag.Type='combobox';
            wMulticastSenderTag.Name=DAStudio.message('SimulinkDiscreteEvent:Multicast:Tag');
            wMulticastSenderTag.NameLocation=2;
            wMulticastSenderTag.Entries=get_param(this.mBlock.Handle,'AllMulticastTagsInModel');
            wMulticastSenderTag.Tag='MulticastTag';
            wMulticastSenderTag.ObjectProperty='MulticastTag';
            wMulticastSenderTag.Source=this.mBlock;
            wMulticastSenderTag.RowSpan=[rowIdx,rowIdx];
            wMulticastSenderTag.ColSpan=[1,1];
            wMulticastSenderTag.Mode=false;
            wMulticastSenderTag.DialogRefresh=false;
            wMulticastSenderTag.MatlabMethod='handleEditEvent';
            wMulticastSenderTag.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wMulticastSenderTag.Editable=true;

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Main');
            schema.Items={wBufferMode,wCapacity,wQueueType,wPrioritySource,...
            wSortingDirection,wEntitySource,wMulticastSenderTag};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end


        function schema=getStatisticsSchema(this)



            rowIdx=1;
            wNumDeparted.Type='checkbox';
            wNumDeparted.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberEntitiesDeparted');
            wNumDeparted.Mode=true;
            wNumDeparted.RowSpan=[rowIdx,rowIdx];
            wNumDeparted.ColSpan=[1,1];
            wNumDeparted.Tag='NumberEntitiesDeparted';
            wNumDeparted.ObjectProperty='NumberEntitiesDeparted';
            wNumDeparted.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wNumInBlock.Type='checkbox';
            wNumInBlock.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberEntitiesInBlock');
            wNumInBlock.Mode=true;
            wNumInBlock.RowSpan=[rowIdx,rowIdx];
            wNumInBlock.ColSpan=[1,1];
            wNumInBlock.Tag='NumberEntitiesInBlock';
            wNumInBlock.ObjectProperty='NumberEntitiesInBlock';
            wNumInBlock.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wAvgWait.Type='checkbox';
            wAvgWait.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:AverageWait');
            wAvgWait.Mode=true;
            wAvgWait.RowSpan=[rowIdx,rowIdx];
            wAvgWait.ColSpan=[1,1];
            wAvgWait.Tag='AverageWait';
            wAvgWait.ObjectProperty='AverageWait';
            wAvgWait.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wAvgQueueLength.Type='checkbox';
            wAvgQueueLength.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:AverageQueueLength');
            wAvgQueueLength.Mode=true;
            wAvgQueueLength.RowSpan=[rowIdx,rowIdx];
            wAvgQueueLength.ColSpan=[1,1];
            wAvgQueueLength.Tag='AverageQueueLength';
            wAvgQueueLength.ObjectProperty='AverageQueueLength';
            wAvgQueueLength.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wNumExtracted.Type='checkbox';
            wNumExtracted.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesExtracted');
            wNumExtracted.Mode=true;
            wNumExtracted.RowSpan=[rowIdx,rowIdx];
            wNumExtracted.ColSpan=[1,1];
            wNumExtracted.Tag='NumEntitiesExtracted';
            wNumExtracted.ObjectProperty='NumEntitiesExtracted';
            wNumExtracted.Source=this.mBlock;


            isVisible=~getBufferMode(this);
            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={wNumDeparted,wNumInBlock,wAvgWait,wAvgQueueLength,wNumExtracted};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
            schema.Visible=isVisible;
        end


        function status=getBufferMode(this)
            status=strcmp(this.mBlock.OverwriteOldest,'on');
        end


    end

end




