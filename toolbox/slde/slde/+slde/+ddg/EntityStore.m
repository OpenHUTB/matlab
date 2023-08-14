classdef EntityStore<slde.ddg.EventActionsTab





    properties(Access=public)
        mBlock;
        mUddParent;
        mChildErrorDlgs;
    end


    methods


        function this=EntityStore(blk,udd)

            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];


            this.evActionTabId=1;
        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();


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
            sigHier=get_param(pHandles.Inport(1),...
            'SignalHierarchy');

        end


    end



    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Entity Store';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)



            rowIdx=1;
            wCapacity.Type='edit';
            wCapacity.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Capacity');
            wCapacity.NameLocation=2;
            wCapacity.Tag='Capacity';
            wCapacity.ObjectProperty='Capacity';
            wCapacity.Source=this.mBlock;
            wCapacity.RowSpan=[rowIdx,rowIdx];
            wCapacity.ColSpan=[1,1];
            wCapacity.Mode=false;
            wCapacity.DialogRefresh=false;
            wCapacity.MatlabMethod='handleEditEvent';
            wCapacity.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};


            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Main');
            schema.Items={wCapacity};

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
            wAvgQueueLength.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:AverageStoreSize');
            wAvgQueueLength.Mode=true;
            wAvgQueueLength.RowSpan=[rowIdx,rowIdx];
            wAvgQueueLength.ColSpan=[1,1];
            wAvgQueueLength.Tag='AverageStoreSize';
            wAvgQueueLength.ObjectProperty='AverageStoreSize';
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

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={wNumDeparted,wNumInBlock,wAvgWait,wAvgQueueLength,wNumExtracted};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end


    end

end




