function dlgstruct=getRTOSDialogSchema(hView,Data,name)




    tagprefix='TargetPrefRTOS_';
    switch(Data.getCurOS())
    case 'DSP/BIOS',
        RTOSSchemaItems=getDSPBIOS(hView,Data,name);
    case 'Linux',
        RTOSSchemaItems=getLinux(hView,Data,name);
    case 'Windows',
        RTOSSchemaItems=getWindows(hView,Data,name);
    case 'VxWorks',
        RTOSSchemaItems=getLinux(hView,Data,name);
    otherwise,
        spacer.Type='panel';
        spacer.RowSpan=[1,6];
        spacer.ColSpan=[1,9];

        RTOSSchemaItems.Type='panel';
        RTOSSchemaItems.Tag=[tagprefix,'panel'];
        RTOSSchemaItems.Items={spacer};
        RTOSSchemaItems.LayoutGrid=[6,6];
        RTOSSchemaItems.RowStretch=[0,0,0,0,0,1];
    end

    dlgstruct.Name=Data.getCurOS();
    dlgstruct.Items={RTOSSchemaItems};


    function RTOSSchemaItems=getLinux(hView,Data,name)
        tagprefix='TargetPrefRTOS_';
        SchedulingModeLabel.Name=hView.mLabels.RTOS.SchedulingMode;
        SchedulingModeLabel.Type='text';
        SchedulingModeLabel.RowSpan=[1,1];
        SchedulingModeLabel.ColSpan=[1,3];
        SchedulingModeLabel.Buddy=[tagprefix,'SchedulingMode'];

        SchedulingMode.Type='combobox';
        SchedulingMode.Entries=Data.getOSSchedulingModes();
        SchedulingMode.Value=Data.getCurOSSchedulingMode();
        SchedulingMode.Tag=[tagprefix,'SchedulingMode'];
        SchedulingMode.ToolTip=hView.mToolTips.RTOS.SchedulingMode;
        SchedulingMode.DialogRefresh=true;
        SchedulingMode.RowSpan=[1,1];
        SchedulingMode.ColSpan=[4,4];
        SchedulingMode.ListenToProperties={'mCustomMemBanks'};
        SchedulingMode=hView.addControllerCallBack(SchedulingMode,'setOSSchedulingMode','%value');

        BaseRatePriorityLabel.Name=hView.mLabels.RTOS.BaseRatePriority;
        BaseRatePriorityLabel.Type='text';
        BaseRatePriorityLabel.RowSpan=[2,2];
        BaseRatePriorityLabel.ColSpan=[1,3];
        BaseRatePriorityLabel.Buddy=[tagprefix,'BaseRatePriority'];

        BaseRatePriority.Type='edit';
        BaseRatePriority.Value=Data.getOSBaseRatePriority();
        BaseRatePriority.Tag=[tagprefix,'BaseRatePriority'];
        BaseRatePriority.ToolTip=hView.mToolTips.RTOS.BaseRatePriority;
        BaseRatePriority.DialogRefresh=false;
        BaseRatePriority.RowSpan=[2,2];
        BaseRatePriority.ColSpan=[4,4];
        BaseRatePriority=hView.addControllerCallBack(BaseRatePriority,'setOSBaseRatePriority','%value');

        ScheduleManagement.Name=hView.mLabels.RTOS.ScheduleManagement;
        ScheduleManagement.Type='group';
        ScheduleManagement.Items={SchedulingModeLabel,SchedulingMode,BaseRatePriorityLabel,BaseRatePriority};
        ScheduleManagement.LayoutGrid=[2,6];
        ScheduleManagement.ColStretch=[0,0,0,0,0,1];
        ScheduleManagement.RowSpan=[1,2];
        ScheduleManagement.ColSpan=[1,9];

        spacer.Type='panel';
        spacer.RowSpan=[4,6];
        spacer.ColSpan=[1,9];

        RTOSSchemaItems.Type='panel';
        RTOSSchemaItems.Tag=[tagprefix,'panel'];
        RTOSSchemaItems.Items={ScheduleManagement,spacer};
        RTOSSchemaItems.LayoutGrid=[6,6];
        RTOSSchemaItems.RowStretch=[0,0,0,0,0,1];


        function RTOSSchemaItems=getWindows(hView,Data,name)
            tagprefix='TargetPrefRTOS_';
            SchedulingModeLabel.Name=hView.mLabels.RTOS.SchedulingMode;
            SchedulingModeLabel.Type='text';
            SchedulingModeLabel.RowSpan=[1,1];
            SchedulingModeLabel.ColSpan=[1,3];
            SchedulingModeLabel.Buddy=[tagprefix,'SchedulingMode'];

            SchedulingMode.Type='combobox';
            SchedulingMode.Entries=Data.getOSSchedulingModes();
            SchedulingMode.Value=Data.getCurOSSchedulingMode();
            SchedulingMode.Tag=[tagprefix,'SchedulingMode'];
            SchedulingMode.ToolTip=hView.mToolTips.RTOS.SchedulingMode;
            SchedulingMode.DialogRefresh=true;
            SchedulingMode.RowSpan=[1,1];
            SchedulingMode.ColSpan=[4,4];
            SchedulingMode.ListenToProperties={'mCustomMemBanks'};
            SchedulingMode=hView.addControllerCallBack(SchedulingMode,'setOSSchedulingMode','%value');

            ScheduleManagement.Name=hView.mLabels.RTOS.ScheduleManagement;
            ScheduleManagement.Type='group';
            ScheduleManagement.Items={SchedulingModeLabel,SchedulingMode};
            ScheduleManagement.LayoutGrid=[2,6];
            ScheduleManagement.ColStretch=[0,0,0,0,0,1];
            ScheduleManagement.RowSpan=[1,2];
            ScheduleManagement.ColSpan=[1,9];

            spacer.Type='panel';
            spacer.RowSpan=[3,6];
            spacer.ColSpan=[1,9];

            RTOSSchemaItems.Type='panel';
            RTOSSchemaItems.Tag=[tagprefix,'panel'];
            RTOSSchemaItems.Items={ScheduleManagement,spacer};
            RTOSSchemaItems.LayoutGrid=[6,6];
            RTOSSchemaItems.RowStretch=[0,0,0,0,0,1];



            function RTOSSchemaItems=getDSPBIOS(hView,Data,name)
                tagprefix='TargetPrefRTOS_';
                BanksForHeap=Data.getMemoryBankNamesForRTOSData();
                Parameters=Data.getRTOSHeapParameters();
                HeapInfoData=cell(numel(BanksForHeap),numel(Parameters));
                for i=1:numel(BanksForHeap)
                    HeapInfoData{i,1}.Name=Parameters{1};
                    HeapInfoData{i,1}.Value=Data.getRTOSHeapCreate(BanksForHeap{i});
                    HeapInfoData{i,1}.Type='checkbox';
                    HeapInfoData{i,2}.Name=Parameters{2};
                    HeapInfoData{i,2}.Value=Data.getRTOSHeapLabelFor(BanksForHeap{i});
                    HeapInfoData{i,2}.Enabled=HeapInfoData{i,1}.Value;
                    HeapInfoData{i,2}.Type='edit';
                    HeapInfoData{i,3}.Name=Parameters{3};
                    HeapInfoData{i,3}.Value=sprintf('0x%08x',Data.getRTOSHeapSizeFor(BanksForHeap{i}));
                    HeapInfoData{i,3}.Type='edit';
                    HeapInfoData{i,3}.Enabled=HeapInfoData{i,1}.Value;
                end


                HeapAssign.Type='table';
                HeapAssign.Size=[numel(BanksForHeap),Data.getNumRTOSHeapParameters()];
                HeapAssign.Data=HeapInfoData;
                HeapAssign.Grid=1;
                HeapAssign.FontFamily='Courier';
                HeapAssign.HeaderVisibility=[1,1];
                HeapAssign.Editable=1;
                HeapAssign.RowHeader=Data.getMemoryBankNamesForRTOSData();
                HeapAssign.ColHeader=Data.getRTOSHeapParameters();
                HeapAssign.RowHeaderWidth=max(cellfun(@length,Parameters))*2;
                HeapAssign.RowSpan=[1,4];
                HeapAssign.ColSpan=[1,6];
                HeapAssign.Tag=[tagprefix,'HeapAssign'];
                HeapAssign.ListenToProperties={'mCustomMemBanks'};
                HeapAssign.ValueChangedCallback=@rtosHeapItemChanged;
                HeapAssign.SelectedRow=hView.mCurSelection.RTOS.Row;

                Heap.Name=hView.mLabels.RTOS.Heap;
                Heap.Type='group';
                Heap.Items={HeapAssign};
                Heap.LayoutGrid=[5,6];
                Heap.ColStretch=[0,0,0,0,0,1];
                Heap.RowSpan=[1,3];
                Heap.ColSpan=[1,9];

                DataPlacementLabel.Name=hView.mLabels.RTOS.DataPlacement;
                DataPlacementLabel.Type='text';
                DataPlacementLabel.RowSpan=[1,1];
                DataPlacementLabel.ColSpan=[1,1];
                DataPlacementLabel.Buddy=[tagprefix,'DataPlacement'];

                DataPlacement.Type='combobox';
                DataPlacement.Entries=Data.getMemoryBankNamesForRTOSData();
                DataPlacement.Value=Data.getRTOSDataObjectPlacement();
                DataPlacement.Tag=[tagprefix,'DataPlacement'];
                DataPlacement.ToolTip=hView.mToolTips.RTOS.DataPlacement;
                DataPlacement.DialogRefresh=true;
                DataPlacement.RowSpan=[1,1];
                DataPlacement.ColSpan=[2,2];
                DataPlacement.ListenToProperties={'mCustomMemBanks'};
                DataPlacement=hView.addControllerCallBack(DataPlacement,'setRTOSDataPlacement','%value');

                CodePlacementLabel.Name=hView.mLabels.RTOS.CodePlacement;
                CodePlacementLabel.Type='text';
                CodePlacementLabel.RowSpan=[2,2];
                CodePlacementLabel.ColSpan=[1,1];
                CodePlacementLabel.Buddy=[tagprefix,'CodePlacement'];

                CodePlacement.Type='combobox';
                CodePlacement.Entries=Data.getMemoryBankNamesForRTOSCode();
                CodePlacement.Value=Data.getRTOSCodeObjectPlacement();
                CodePlacement.Tag=[tagprefix,'CodePlacement'];
                CodePlacement.ToolTip=hView.mToolTips.RTOS.CodePlacement;
                CodePlacement.DialogRefresh=true;
                CodePlacement.RowSpan=[2,2];
                CodePlacement.ColSpan=[2,2];
                CodePlacement.ListenToProperties={'mCustomMemBanks'};
                CodePlacement=hView.addControllerCallBack(CodePlacement,'setRTOSCodePlacement','%value');

                Placement.Name=hView.mLabels.RTOS.Placement;
                Placement.Type='group';
                Placement.Items={DataPlacementLabel,DataPlacement,CodePlacementLabel,CodePlacement};
                Placement.LayoutGrid=[2,6];
                Placement.ColStretch=[0,0,0,0,0,1];
                Placement.RowSpan=[4,4];
                Placement.ColSpan=[1,9];

                StackSizeLabel.Name=hView.mLabels.RTOS.StackSize;
                StackSizeLabel.Type='text';
                StackSizeLabel.RowSpan=[1,1];
                StackSizeLabel.ColSpan=[1,3];
                StackSizeLabel.Buddy=[tagprefix,'StackSize'];

                StackSize.Type='edit';
                StackSize.Value=Data.getRTOSStackSize();
                StackSize.Tag=[tagprefix,'StackSize'];
                StackSize.DialogRefresh=true;
                StackSize.RowSpan=[1,1];
                StackSize.ColSpan=[4,4];
                StackSize.ToolTip=hView.mToolTips.RTOS.StackSize;
                StackSize=hView.addControllerCallBack(StackSize,'setRTOSStackSize','%value');

                StaticTasksLabel.Name=hView.mLabels.RTOS.StaticTasks;
                StaticTasksLabel.Type='text';
                StaticTasksLabel.RowSpan=[2,2];
                StaticTasksLabel.ColSpan=[1,3];
                StaticTasksLabel.Buddy=[tagprefix,'StaticTasks'];

                StaticTasks.Type='combobox';
                StaticTasks.Entries=Data.getMemoryBankNamesForRTOSData();
                StaticTasks.Value=Data.getRTOSStaticStackPlacement();
                StaticTasks.Tag=[tagprefix,'StaticTasks'];
                StaticTasks.ToolTip=hView.mToolTips.RTOS.StaticTasks;
                StaticTasks.DialogRefresh=true;
                StaticTasks.RowSpan=[2,2];
                StaticTasks.ColSpan=[4,4];
                StaticTasks.ListenToProperties={'mCustomMemBanks'};
                StaticTasks=hView.addControllerCallBack(StaticTasks,'setRTOSStaticTasks','%value');

                DynamicTasksLabel.Name=hView.mLabels.RTOS.DynamicTasks;
                DynamicTasksLabel.Type='text';
                DynamicTasksLabel.RowSpan=[3,3];
                DynamicTasksLabel.ColSpan=[1,3];
                DynamicTasksLabel.Buddy=[tagprefix,'DynamicTasks'];

                DynamicTasks.Type='combobox';
                DynamicTasks.Entries=Data.getMemoryBankNamesForRTOSDynamicStack();
                DynamicTasks.Value=Data.getRTOSDynamicStackPlacement();
                DynamicTasks.Tag=[tagprefix,'DynamicTasks'];
                DynamicTasks.ToolTip=hView.mToolTips.RTOS.DynamicTasks;
                DynamicTasks.DialogRefresh=true;
                DynamicTasks.RowSpan=[3,3];
                DynamicTasks.ColSpan=[4,4];
                DynamicTasks.Enabled=hView.mController.isRTOSDynamicTasksEnabled();
                DynamicTasks.ListenToProperties={'mCustomMemBanks'};
                DynamicTasks=hView.addControllerCallBack(DynamicTasks,'setRTOSDynamicTasks','%value');

                TaskManagement.Name=hView.mLabels.RTOS.TaskManagement;
                TaskManagement.Type='group';
                TaskManagement.Items={StackSizeLabel,StackSize,...
                StaticTasksLabel,StaticTasks,DynamicTasksLabel,DynamicTasks};
                TaskManagement.LayoutGrid=[3,6];
                TaskManagement.ColStretch=[0,0,0,0,0,1];
                TaskManagement.RowSpan=[5,5];
                TaskManagement.ColSpan=[1,9];

                spacer.Type='panel';
                spacer.RowSpan=[6,6];
                spacer.ColSpan=[1,9];

                RTOSSchemaItems.Type='panel';
                RTOSSchemaItems.Tag=[tagprefix,'panel'];
                RTOSSchemaItems.Items={Heap,Placement,TaskManagement,spacer};
                RTOSSchemaItems.LayoutGrid=[6,6];
                RTOSSchemaItems.RowStretch=[0,0,0,0,0,1];



                function rtosHeapItemChanged(dlg,row,col,val)

                    cs=dlg.getDialogSource().getConfigSet();
                    controller=get_param(cs,'TargetHardwareResourcesController');
                    hView=controller.getView();
                    hView.mCurSelection.RTOS.Row=row;
                    switch(col)
                    case 0,
                        hView.mController.setRTOSHeapCreate(hView,dlg,'TargetPrefRTOS_HeapAssign',row+1,val);
                    case 1,
                        hView.mController.setRTOSHeapLabel(hView,dlg,'TargetPrefRTOS_HeapAssign',row+1,val);
                    case 2,
                        hView.mController.setRTOSHeapSize(hView,dlg,'TargetPrefRTOS_HeapAssign',row+1,val);
                    end
                    controller.getData().save(cs);
