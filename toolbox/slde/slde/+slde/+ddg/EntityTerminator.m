classdef EntityTerminator<slde.ddg.EventActionsTab





    properties(Access=public)
        mBlock;
        mUddParent;
        mChildErrorDlgs;
    end


    methods


        function this=EntityTerminator(blk,udd)

            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];


            this.evActionTabId=0;
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
            schema.Name='Entity Terminator';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)



            rowIdx=1;
            wInputPortAvailable.Type='checkbox';
            wInputPortAvailable.Name=DAStudio.message('SimulinkDiscreteEvent:EntityTerminator:InputPortAvailable');
            wInputPortAvailable.Tag='InputPortAvailable';
            wInputPortAvailable.ObjectProperty='InputPortAvailable';
            wInputPortAvailable.Source=this.mBlock;
            wInputPortAvailable.RowSpan=[rowIdx,rowIdx];
            wInputPortAvailable.ColSpan=[1,1];
            wInputPortAvailable.MatlabMethod='handleCheckEvent';
            wInputPortAvailable.MatlabArgs={this.mUddParent,'%value',rowIdx-1,'%dialog'};
            wInputPortAvailable.Visible=false;

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Main');
            schema.Items={wInputPortAvailable};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
            schema.Visible=false;
        end


        function schema=getStatisticsSchema(this)



            rowIdx=1;
            wNumArrived.Type='checkbox';
            wNumArrived.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:NumberEntitiesArrived');
            wNumArrived.Mode=true;
            wNumArrived.RowSpan=[rowIdx,rowIdx];
            wNumArrived.ColSpan=[1,1];
            wNumArrived.Tag='NumberEntitiesArrived';
            wNumArrived.ObjectProperty='NumberEntitiesArrived';
            wNumArrived.Source=this.mBlock;

            schema.Name=DAStudio.message('SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={wNumArrived};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];
        end


    end

end




