classdef EntityUnbatcher<slde.ddg.EventActionsTab





    properties(Access=public)
        mBlock;
        mUddParent;
        mChildErrorDlgs;
    end


    methods


        function this=EntityUnbatcher(blk,udd)

            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];


            this.evActionTabId=1;
        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();


            eventActionsTab=this.getEventActionsTabSchema();
            statsTab=this.getStatisticsSchema();

            tabCont.Type='tab';
            tabCont.Tabs={eventActionsTab,statsTab};
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



        function evActionAttribs=getEventActionAttributes(~)
            idx=1;


            evActionAttribs{idx}.Name='Entry';
            evActionAttribs{idx}.Tag='EntryAction';
            evActionAttribs{idx}.ObjectProperty='EntryAction';
            evActionAttribs{idx}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgEntryAction';
            evActionAttribs{idx}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipEntryAction';


            idx=idx+1;
            evActionAttribs{idx}.Name='Unbatch';
            evActionAttribs{idx}.Tag='UnbatchAction';
            evActionAttribs{idx}.ObjectProperty='UnbatchAction';
            evActionAttribs{idx}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgUnbatchComponentAction';
            evActionAttribs{idx}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipUnbatchComponentAction';


            idx=idx+1;
            evActionAttribs{idx}.Name='Exit';
            evActionAttribs{idx}.Tag='ExitAction';
            evActionAttribs{idx}.ObjectProperty='ExitAction';
            evActionAttribs{idx}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgExitAction';
            evActionAttribs{idx}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipExitAction';


            idx=idx+1;
            evActionAttribs{idx}.Name='Blocked';
            evActionAttribs{idx}.Tag='BlockedAction';
            evActionAttribs{idx}.ObjectProperty='BlockedAction';
            evActionAttribs{idx}.DefaultMsg='SimulinkDiscreteEvent:dialog:DefaultMsgBlockedAction';
            evActionAttribs{idx}.ToolTip='SimulinkDiscreteEvent:dialog:ToolTipBlockedAction';

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
            if this.selectedEvActionId==1
                sigHier=get_param(pHandles.Inport(1),'SignalHierarchy');
            else

                sigHier=get_param(pHandles.Outport(end),'SignalHierarchy');
            end

        end


    end



    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Entity Unbatcher';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getStatisticsSchema(this)



            rowIdx=1;
            NumArrived.Type='checkbox';
            NumArrived.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberEntitiesArrived');
            NumArrived.Mode=true;
            NumArrived.RowSpan=[rowIdx,rowIdx];
            NumArrived.ColSpan=[1,1];
            NumArrived.Tag='NumberOfEntitiesArrived';
            NumArrived.ObjectProperty='NumberOfEntitiesArrived';
            NumArrived.Source=this.mBlock;


            rowIdx=rowIdx+1;
            NumDeparted.Type='checkbox';
            NumDeparted.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberEntitiesDeparted');
            NumDeparted.Mode=true;
            NumDeparted.RowSpan=[rowIdx,rowIdx];
            NumDeparted.ColSpan=[1,1];
            NumDeparted.Tag='NumberOfEntitiesDeparted';
            NumDeparted.ObjectProperty='NumberOfEntitiesDeparted';
            NumDeparted.Source=this.mBlock;


            rowIdx=rowIdx+1;
            NumRemaining.Type='checkbox';
            NumRemaining.Name=DAStudio.message('SimulinkDiscreteEvent:EntityCombiner:NumberOfEntitiesWaitingToDepart');
            NumRemaining.Mode=true;
            NumRemaining.RowSpan=[rowIdx,rowIdx];
            NumRemaining.ColSpan=[1,1];
            NumRemaining.Tag='NumberOfEntitiesWaitingToDepart';
            NumRemaining.ObjectProperty='NumberOfEntitiesWaitingToDepart';
            NumRemaining.Source=this.mBlock;


            rowIdx=rowIdx+1;
            PendingEntity.Type='checkbox';
            PendingEntity.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:PendingEntity');
            PendingEntity.Mode=true;
            PendingEntity.RowSpan=[rowIdx,rowIdx];
            PendingEntity.ColSpan=[1,1];
            PendingEntity.Tag='PendingEntity';
            PendingEntity.ObjectProperty='PendingEntity';
            PendingEntity.Source=this.mBlock;

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={NumArrived,NumDeparted,NumRemaining,PendingEntity};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end


    end

end




