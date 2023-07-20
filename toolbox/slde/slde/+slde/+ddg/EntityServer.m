classdef EntityServer<slde.ddg.EventActionsTab






    properties(Access=public)

        mBlock;
        mUddParent;
        mChildErrorDlgs;
        mEditTimeAttribs;
        mEditTimeAttribsAndPriority;
    end


    methods


        function this=EntityServer(blk,udd)



            this@slde.ddg.EventActionsTab(blk,udd);


            this.mBlock=get_param(blk,'Object');
            this.mUddParent=udd;

            this.mChildErrorDlgs=[];


            this.evActionTabId=1;

        end


        function schema=getDialogSchema(this)


            blockDesc=this.getBlockDescriptionSchema();
            this.mEditTimeAttribsAndPriority=[this.getEditTimeAttributes(...
            this.getSigHierFromPort()),...
            'entitySys.priority'];
            this.mEditTimeAttribs=this.getEditTimeAttributes(...
            this.getSigHierFromPort());

            mainTab=this.getMainTabSchema();
            eventActionsTab=this.getEventActionsTabSchema();
            advControlTab=this.getAdvancedControlSchema();
            statsTab=this.getStatisticsSchema();

            tabCont.Type='tab';
            tabCont.Tabs={...
            mainTab,...
            eventActionsTab,...
            advControlTab,...
            statsTab};
            tabCont.Name='';
            tabCont.RowSpan=[2,2];
            tabCont.ColSpan=[1,1];

            schema.DialogTitle=DAStudio.message(...
            'Simulink:dialog:BlockParameters',this.mBlock.Name);
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

            unused_variable(this);
            evActionAttribs{1}.Name='Entry';
            evActionAttribs{1}.Tag='EntryAction';
            evActionAttribs{1}.ObjectProperty='EntryAction';
            evActionAttribs{1}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgEntryAction';
            evActionAttribs{1}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipEntryAction';


            evActionAttribs{2}.Name='Service complete';
            evActionAttribs{2}.Tag='ServiceCompleteAction';
            evActionAttribs{2}.ObjectProperty='ServiceCompleteAction';
            evActionAttribs{2}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgServiceCompleteAction';
            evActionAttribs{2}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipServiceCompleteAction';


            evActionAttribs{3}.Name='Exit';
            evActionAttribs{3}.Tag='ExitAction';
            evActionAttribs{3}.ObjectProperty='ExitAction';
            evActionAttribs{3}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgExitAction';
            evActionAttribs{3}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipExitAction';


            evActionAttribs{4}.Name='Blocked';
            evActionAttribs{4}.Tag='BlockedAction';
            evActionAttribs{4}.ObjectProperty='BlockedAction';
            evActionAttribs{4}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgBlockedAction';
            evActionAttribs{4}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipBlockedAction';


            evActionAttribs{5}.Name='Preempt';
            evActionAttribs{5}.Tag='PreemptAction';
            evActionAttribs{5}.ObjectProperty='PreemptAction';
            evActionAttribs{5}.DefaultMsg=...
            'SimulinkDiscreteEvent:dialog:DefaultMsgPreemptAction';
            evActionAttribs{5}.ToolTip=...
            'SimulinkDiscreteEvent:dialog:ToolTipPreemptAction';

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


        function editTimeAttribs=getEditTimeSignalHierarchy(this)

            editTimeAttribs=...
            getEditTimeSignalHierarchy@slde.ddg.EventActionsTab(this);

        end


        function sigHier=getSigHierFromPort(this)

            pHandles=get_param(this.mBlock.Handle,'PortHandles');
            sigHier=get_param(pHandles.Inport(1),...
            'SignalHierarchy');

        end


        function launchServiceTimeWidget(this,dialog)

            unused_variable(this);
            pttrnAssistant=slde.ddg.PatternAssistant(dialog,...
            'ServiceTimeAction',this);
            pttrnDlg=DAStudio.Dialog(pttrnAssistant);

        end



    end


    methods(Access=private)


        function schema=getBlockDescriptionSchema(this)



            blockDesc.Type='text';
            blockDesc.Name=this.mBlock.BlockDescription;
            blockDesc.WordWrap=true;

            schema.Type='group';
            schema.Name='Entity Server';
            schema.Items={blockDesc};
            schema.RowSpan=[1,1];
            schema.ColSpan=[1,1];
        end


        function schema=getMainTabSchema(this)



            rowIdx=1;
            wCapacity.Type='edit';
            wCapacity.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:Capacity');
            wCapacity.NameLocation=2;
            wCapacity.Tag='Capacity';
            wCapacity.ObjectProperty='Capacity';
            wCapacity.Source=this.mBlock;
            wCapacity.RowSpan=[rowIdx,rowIdx];
            wCapacity.ColSpan=[1,1];
            wCapacity.Mode=false;
            wCapacity.DialogRefresh=false;
            wCapacity.MatlabMethod='handleEditEvent';
            wCapacity.MatlabArgs={this.mUddParent,'%value',...
            rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wServiceTimeSource.Type='combobox';
            wServiceTimeSource.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:ServiceTimeSource');
            wServiceTimeSource.Entries={...
            DAStudio.message('SimulinkDiscreteEvent:dialog:Dialog'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:SignalPort'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:Attribute'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:EventAction')};
            wServiceTimeSource.Tag='ServiceTimeSource';
            wServiceTimeSource.ObjectProperty='ServiceTimeSource';
            wServiceTimeSource.Source=this.mBlock;
            wServiceTimeSource.RowSpan=[rowIdx,rowIdx];
            wServiceTimeSource.ColSpan=[1,1];
            wServiceTimeSource.Mode=true;
            wServiceTimeSource.DialogRefresh=true;
            wServiceTimeSource.MatlabMethod='handleComboSelectionEvent';
            wServiceTimeSource.MatlabArgs={this.mUddParent,...
            '%value',rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wServiceTimeValue.Type='edit';
            wServiceTimeValue.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:ServiceTimeValue');
            wServiceTimeValue.NameLocation=2;
            wServiceTimeValue.Tag='ServiceTimeValue';
            wServiceTimeValue.ObjectProperty='ServiceTimeValue';
            wServiceTimeValue.Source=this.mBlock;
            wServiceTimeValue.RowSpan=[rowIdx,rowIdx];
            wServiceTimeValue.ColSpan=[1,1];
            wServiceTimeValue.Mode=false;
            wServiceTimeValue.DialogRefresh=false;
            wServiceTimeValue.MatlabMethod='handleEditEvent';
            wServiceTimeValue.MatlabArgs={this.mUddParent,...
            '%value',rowIdx-1,'%dialog'};


            rowIdx=rowIdx+1;
            wServiceAttribName.Type='combobox';
            wServiceAttribName.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:ServiceTimeAttributeName');
            wServiceAttribName.Entries=this.mEditTimeAttribs;
            wServiceAttribName.Tag='ServiceTimeAttributeName';
            wServiceAttribName.ObjectProperty='ServiceTimeAttributeName';
            wServiceAttribName.Source=this.mBlock;
            wServiceAttribName.RowSpan=[rowIdx,rowIdx];
            wServiceAttribName.ColSpan=[1,1];
            wServiceAttribName.DialogRefresh=false;
            wServiceAttribName.MatlabMethod='handleEditEvent';
            wServiceAttribName.MatlabArgs={this.mUddParent,...
            '%value',rowIdx-1,'%dialog'};
            wServiceAttribName.Editable=true;


            rowIdx=rowIdx+1;
            wSvcTimeEditor.Type='matlabeditor';
            wSvcTimeEditor.Name='Service time action:';
            wSvcTimeEditor.Tag='ServiceTimeAction';
            wSvcTimeEditor.Mode=false;
            wSvcTimeEditor.ToolTip=sprintf(['Tip: Use ',...
            'MATLAB code to set the value of service time.\n',...
            'e.g. dt = rand(1, 1) + entity.Attribute1;']);
            wSvcTimeEditor.ObjectProperty='ServiceTimeAction';
            wSvcTimeEditor.Source=this.mBlock;
            wSvcTimeEditor.MatlabMethod='handleEditEvent';
            wSvcTimeEditor.MatlabArgs={this.mUddParent,...
            '%value',rowIdx-1,'%dialog'};
            wSvcTimeEditor.MatlabEditorFeatures={...
            'SyntaxHilighting',...
            'LineNumber',...
            'GoToLine',...
            'TabCompletion'};
            wSvcTimeEditor.RowSpan=[rowIdx,rowIdx];
            wSvcTimeEditor.ColSpan=[1,1];
            wSvcTimeEditor.Visible=Simulink.isParameterVisible(...
            this.mBlock.Handle,wSvcTimeEditor.ObjectProperty);
            wSvcTimeEditor.Enabled=strcmpi(get_param(...
            bdroot(this.mBlock.getFullName),'SimulationStatus'),...
            'stopped');

            rowIdx=rowIdx+1;
            btnPttrnAsst.Type='pushbutton';
            btnPttrnAsst.Tag='PttrnAsstServTimeSrcSrvr';
            btnPttrnAsst.Name='Insert pattern ...';
            btnPttrnAsst.ToolTip='Open pattern assistant';
            btnPttrnAsst.ObjectMethod='launchServiceTimeWidget';
            btnPttrnAsst.Source=this;
            btnPttrnAsst.MethodArgs={'%dialog'};
            btnPttrnAsst.ArgDataTypes={'handle'};
            btnPttrnAsst.DialogRefresh=false;
            btnPttrnAsst.Graphical=true;
            btnPttrnAsst.Visible=wSvcTimeEditor.Visible;
            btnPttrnAsst.RowSpan=[rowIdx,rowIdx];
            btnPttrnAsst.ColSpan=[1,1];
            btnPttrnAsst.Alignment=10;

            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:Main_Tab');
            schema.Items={...
            wCapacity,...
            wServiceTimeSource,...
            wServiceTimeValue,...
            wServiceAttribName,...
            wSvcTimeEditor,...
            btnPttrnAsst};

            schema.LayoutGrid=[length(schema.Items),1];
            schema.RowStretch=[0,0,0,0,1,0];

        end


        function schema=getAdvancedControlSchema(this)


            rowIdx=1;
            wEnablePreemption.Type='checkbox';
            wEnablePreemption.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:PermitPreemptionBasedOnAttribute');
            wEnablePreemption.Tag=...
            'PermitPreemptionBasedOnAttribute';
            wEnablePreemption.ObjectProperty=...
            'PermitPreemptionBasedOnAttribute';
            wEnablePreemption.Source=this.mBlock;
            wEnablePreemption.Mode=true;
            wEnablePreemption.RowSpan=[rowIdx,rowIdx];
            wEnablePreemption.ColSpan=[1,1];
            wEnablePreemption.MatlabMethod='handleCheckEvent';
            wEnablePreemption.MatlabArgs={this.mUddParent,...
            '%value',...
            this.getPrmIdx(wEnablePreemption.ObjectProperty),...
            '%dialog'};


            rowIdx=rowIdx+1;
            wPriorityAttribName.Type='combobox';
            wPriorityAttribName.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:SortingAttributeName');
            wPriorityAttribName.ObjectProperty='SortingAttributeName';
            wPriorityAttribName.Tag='SortingAttributeName';
            wPriorityAttribName.MatlabMethod='handleEditEvent';
            wPriorityAttribName.MatlabArgs={this.mUddParent,...
            '%value',...
            this.getPrmIdx(wPriorityAttribName.ObjectProperty),...
            '%dialog'};
            wPriorityAttribName.Entries=this.mEditTimeAttribsAndPriority;
            wPriorityAttribName.Editable=true;
            wPriorityAttribName.Source=this.mBlock;
            wPriorityAttribName.RowSpan=[rowIdx,rowIdx];
            wPriorityAttribName.ColSpan=[1,1];
            wPriorityAttribName.Mode=false;


            rowIdx=rowIdx+1;
            wSortingDirection.Type='combobox';
            wSortingDirection.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:SortingDirection');
            wSortingDirection.Entries={...
            DAStudio.message('SimulinkDiscreteEvent:dialog:Ascending'),...
            DAStudio.message('SimulinkDiscreteEvent:dialog:Descending')};
            wSortingDirection.Tag='SortingDirection';
            wSortingDirection.ObjectProperty='SortingDirection';
            wSortingDirection.Source=this.mBlock;
            wSortingDirection.RowSpan=[rowIdx,rowIdx];
            wSortingDirection.ColSpan=[1,1];
            wSortingDirection.Mode=true;
            wSortingDirection.MatlabMethod='handleComboSelectionEvent';
            wSortingDirection.MatlabArgs={this.mUddParent,...
            '%value',...
            this.getPrmIdx(wSortingDirection.ObjectProperty),...
            '%dialog'};


            rowIdx=rowIdx+1;
            wSaveResidualTimeToAttr.Type='checkbox';
            wSaveResidualTimeToAttr.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:WriteResidualTimeToAttribute');
            wSaveResidualTimeToAttr.Tag='WriteResidualTimeToAttribute';
            wSaveResidualTimeToAttr.ObjectProperty='WriteResidualTimeToAttribute';
            wSaveResidualTimeToAttr.Source=this.mBlock;
            wSaveResidualTimeToAttr.Mode=true;
            wSaveResidualTimeToAttr.RowSpan=[rowIdx,rowIdx];
            wSaveResidualTimeToAttr.ColSpan=[1,1];
            wSaveResidualTimeToAttr.MatlabMethod='handleCheckEvent';
            wSaveResidualTimeToAttr.MatlabArgs={this.mUddParent,...
            '%value',...
            this.getPrmIdx(wSaveResidualTimeToAttr.ObjectProperty),...
            '%dialog'};


            rowIdx=rowIdx+1;
            wResidualTimeAttribName.Type='combobox';
            wResidualTimeAttribName.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:ResidualTimeAttributeName');
            wResidualTimeAttribName.Entries=this.mEditTimeAttribs;
            wResidualTimeAttribName.Tag='ResidualTimeAttributeName';
            wResidualTimeAttribName.ObjectProperty='ResidualTimeAttributeName';
            wResidualTimeAttribName.Source=this.mBlock;
            wResidualTimeAttribName.RowSpan=[rowIdx,rowIdx];
            wResidualTimeAttribName.ColSpan=[1,1];
            wResidualTimeAttribName.Mode=true;
            wResidualTimeAttribName.MatlabMethod='handleEditEvent';
            wResidualTimeAttribName.MatlabArgs={this.mUddParent,...
            '%value',...
            this.getPrmIdx(wResidualTimeAttribName.ObjectProperty),...
            '%dialog'};
            wResidualTimeAttribName.Editable=true;


            rowIdx=rowIdx+1;
            wCreateAttrib.Type='checkbox';
            wCreateAttrib.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:CreateAttribute');
            wCreateAttrib.Mode=true;
            wCreateAttrib.RowSpan=[rowIdx,rowIdx];
            wCreateAttrib.ColSpan=[1,1];
            wCreateAttrib.Tag='CreateAttribute';
            wCreateAttrib.ObjectProperty='CreateAttribute';
            wCreateAttrib.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wTimeoutPort.Type='checkbox';
            wTimeoutPort.Tag='TimeoutPort';
            wTimeoutPort.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:TimeoutPort');
            wTimeoutPort.Source=this.mBlock;
            wTimeoutPort.ObjectProperty='TimeoutPort';
            wTimeoutPort.RowSpan=[rowIdx,rowIdx];
            wTimeoutPort.ColSpan=[1,1];


            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:Preemption_Tab');
            schema.Items={...
            wEnablePreemption,...
            wPriorityAttribName,...
            wSortingDirection,...
            wSaveResidualTimeToAttr,...
            wResidualTimeAttribName};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];

        end


        function schema=getStatisticsSchema(this)



            rowIdx=1;
            numDeparted.Type='checkbox';
            numDeparted.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:NumberEntitiesDeparted');
            numDeparted.Mode=true;
            numDeparted.RowSpan=[rowIdx,rowIdx];
            numDeparted.ColSpan=[1,1];
            numDeparted.Tag='NumberEntitiesDeparted';
            numDeparted.ObjectProperty='NumberEntitiesDeparted';
            numDeparted.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wNumInBlock.Type='checkbox';
            wNumInBlock.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:NumberEntitiesInBlock');
            wNumInBlock.Mode=true;
            wNumInBlock.RowSpan=[rowIdx,rowIdx];
            wNumInBlock.ColSpan=[1,1];
            wNumInBlock.Tag='NumberEntitiesInBlock';
            wNumInBlock.ObjectProperty='NumberEntitiesInBlock';
            wNumInBlock.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wPendPresent.Type='checkbox';
            wPendPresent.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:PendingEntity');
            wPendPresent.Mode=true;
            wPendPresent.RowSpan=[rowIdx,rowIdx];
            wPendPresent.ColSpan=[1,1];
            wPendPresent.Tag='PendingEntityPresentInBlock';
            wPendPresent.ObjectProperty='PendingEntityPresentInBlock';
            wPendPresent.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wNumPending.Type='checkbox';
            wNumPending.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:NumberEntitiesPending');
            wNumPending.Mode=true;
            wNumPending.RowSpan=[rowIdx,rowIdx];
            wNumPending.ColSpan=[1,1];
            wNumPending.Tag='NumberEntitiesPending';
            wNumPending.ObjectProperty='NumberEntitiesPending';
            wNumPending.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wAvgWait.Type='checkbox';
            wAvgWait.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:AverageWait');
            wAvgWait.Mode=true;
            wAvgWait.RowSpan=[rowIdx,rowIdx];
            wAvgWait.ColSpan=[1,1];
            wAvgWait.Tag='AverageWait';
            wAvgWait.ObjectProperty='AverageWait';
            wAvgWait.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wUtilization.Type='checkbox';
            wUtilization.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Utilization');
            wUtilization.Mode=true;
            wUtilization.RowSpan=[rowIdx,rowIdx];
            wUtilization.ColSpan=[1,1];
            wUtilization.Tag='Utilization';
            wUtilization.ObjectProperty='Utilization';
            wUtilization.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wNumPreempted.Type='checkbox';
            wNumPreempted.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:Server:NumberEntitiesPreempted');
            wNumPreempted.Mode=true;
            wNumPreempted.RowSpan=[rowIdx,rowIdx];
            wNumPreempted.ColSpan=[1,1];
            wNumPreempted.Tag='NumberEntitiesPreempted';
            wNumPreempted.ObjectProperty='NumberEntitiesPreempted';
            wNumPreempted.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wNumTimedout.Type='checkbox';
            wNumTimedout.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:NumberEntitiesTimedOut');
            wNumTimedout.Mode=true;
            wNumTimedout.RowSpan=[rowIdx,rowIdx];
            wNumTimedout.ColSpan=[1,1];
            wNumTimedout.Tag='NumberEntitiesTimedout';
            wNumTimedout.ObjectProperty='NumberEntitiesTimedout';
            wNumTimedout.Source=this.mBlock;
            wNumTimedout.Visible=false;


            rowIdx=rowIdx+1;
            wNumExtracted.Type='checkbox';
            wNumExtracted.Name=DAStudio.message('SimulinkDiscreteEvent:FindEntity:NumberEntitiesExtracted');
            wNumExtracted.Mode=true;
            wNumExtracted.RowSpan=[rowIdx,rowIdx];
            wNumExtracted.ColSpan=[1,1];
            wNumExtracted.Tag='NumEntitiesExtracted';
            wNumExtracted.ObjectProperty='NumEntitiesExtracted';
            wNumExtracted.Source=this.mBlock;


            rowIdx=rowIdx+1;
            wOccupancy.Type='checkbox';
            wOccupancy.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Occupancy');
            wOccupancy.Mode=true;
            wOccupancy.RowSpan=[rowIdx,rowIdx];
            wOccupancy.ColSpan=[1,1];
            wOccupancy.Tag='ServerOccupancy';
            wOccupancy.ObjectProperty='ServerOccupancy';
            wOccupancy.Source=this.mBlock;


            schema.Name=DAStudio.message(...
            'SimulinkDiscreteEvent:dialog:Statistics');
            schema.Items={...
            numDeparted,...
            wNumInBlock,...
            wPendPresent,...
            wNumPending,...
            wAvgWait,...
            wUtilization,...
            wNumPreempted,...
            wNumTimedout,...
            wNumExtracted};
            schema.LayoutGrid=[length(schema.Items)+1,1];
            schema.RowStretch=[zeros(1,length(schema.Items)),1];

        end



    end



end




function unused_variable(varargin)

end


