function dlgstruct=getMemoryDialogSchema(hView,Data,~)



    tagprefix='TargetPrefMemory_';

    MemDataContents.Name=hView.mLabels.Memory.BankContents;
    MemDataContents.Type='combobox';
    MemDataContents.Entries=Data.getMemoryBankContentsChoices();
    MemBankData=cell(Data.getNumMemoryBanks(),Data.getNumMemoryBankParameters());
    for i=1:Data.getNumMemoryBanks()
        MemData=Data.getMemoryBankInfo(i);
        MemBankData{i,1}.Value=MemData.Name;
        MemBankData{i,1}.Type='edit';
        MemBankData{i,1}.Enabled=hView.mController.isMemoryBankRemovable(i);
        MemBankData{i,1}.Bold=~MemBankData{i,1}.Enabled;
        MemBankData{i,2}=sprintf('0x%08x',MemData.Address);
        MemBankData{i,3}=sprintf('0x%08x',MemData.Length);
        MemBankData{i,4}=MemDataContents;
        MemBankData{i,4}.Value=hView.getMatchIdx(MemDataContents.Entries,MemData.Contents);
        MemBankData{i,4}.Enabled=MemData.ContentsChangeable;
    end

    MemBanks.Name=hView.mLabels.Memory.Banks;
    MemBanks.Type='table';
    MemBanks.Size=[Data.getNumMemoryBanks(),Data.getNumMemoryBankParameters()];
    MemBanks.Grid=1;
    MemBanks.FontFamily='Courier';
    MemBanks.HeaderVisibility=[0,1];
    MemBanks.Editable=1;
    MemBanks.ColHeader=Data.getMemoryBankParameters();
    MemBanks.Data=MemBankData;
    MemBanks.RowSpan=[1,4];
    MemBanks.ColSpan=[1,6];
    MemBanks.Tag=[tagprefix,'MemoryBank'];
    MemBanks.ListenToProperties={'mCustomMemBanks'};
    MemBanks.CurrentItemChangedCallback=@memoryBankSelectionChanged;
    MemBanks.ValueChangedCallback=@memoryBankItemChanged;
    MemBanks.SelectedRow=hView.mCurSelection.MemoryBank.Row;

    AddMemoryBank.Name=hView.mLabels.Memory.BankAdd;
    AddMemoryBank.Type='pushbutton';
    AddMemoryBank.Tag=[tagprefix,'AddMemoryBank'];
    AddMemoryBank.RowSpan=[5,5];
    AddMemoryBank.ColSpan=[1,1];
    AddMemoryBank.ToolTip=hView.mToolTips.Memory.BankAdd;

    AddMemoryBank=hView.addControllerCallBack(AddMemoryBank,'addMemoryBank',MemBanks.Tag);

    DeleteMemoryBank.Name=hView.mLabels.Memory.BankRemove;
    DeleteMemoryBank.Type='pushbutton';
    DeleteMemoryBank.Tag=[tagprefix,'DeleteMemoryBank'];
    DeleteMemoryBank.RowSpan=[5,5];
    DeleteMemoryBank.ColSpan=[2,2];
    DeleteMemoryBank.ToolTip=hView.mToolTips.Memory.BankRemove;
    DeleteMemoryBank.DialogRefresh=true;
    DeleteMemoryBank.Enabled=hView.mController.isMemoryBankRemovable(hView.mCurSelection.MemoryBank.Row+1);
    DeleteMemoryBank=hView.addControllerCallBack(DeleteMemoryBank,'deleteMemoryBank',MemBanks.Tag);

    PhyMemConfig.Name=hView.mLabels.Memory.PhysicalMemory;
    PhyMemConfig.Type='group';
    PhyMemConfig.Items={MemBanks,AddMemoryBank,DeleteMemoryBank};
    PhyMemConfig.LayoutGrid=[5,6];
    PhyMemConfig.ColStretch=[0,0,0,0,0,1];
    PhyMemConfig.RowSpan=[1,2];
    PhyMemConfig.ColSpan=[1,9];

    CacheConfigs.Name=hView.mLabels.Memory.CacheConfig;
    CacheConfigs.Type='combobox';
    DefaultCacheEntries=Data.getDefaultCacheConfigEntries();
    CurCacheConfigs=Data.getCurCacheConfigEntries();
    CacheData=cell(Data.getNumCacheEntries(),1);
    for i=1:Data.getNumCacheEntries()
        CacheData{i}=CacheConfigs;
        CacheData{i}.Entries=DefaultCacheEntries{i};
        CacheData{i}.Value=hView.getMatchIdx(DefaultCacheEntries{i},CurCacheConfigs{i});
    end

    CacheConfig.Name=hView.mLabels.Memory.Cache;
    CacheConfig.Type='table';
    CacheConfig.Size=[Data.getNumCacheEntries(),1];
    CacheConfig.Grid=1;
    CacheConfig.HeaderVisibility=[1,1];
    CacheConfig.Editable=1;
    CacheConfig.RowHeader=Data.getDefaultCacheLevelEntries();
    CacheConfig.ColHeader={hView.mLabels.Memory.CacheConfiguration};
    CacheConfig.Data=CacheData;
    CacheConfig.RowSpan=[3,3];
    CacheConfig.ColSpan=[1,5];
    CacheConfig.Tag=[tagprefix,'CacheConfig'];
    if~hView.mController.isCacheVisible()
        CacheConfig.Visible=false;
        CacheConfig.Name='';
    end
    CacheConfig.ValueChangedCallback=@cacheConfigItemChanged;


    MemorySchemaItems.Type='panel';
    MemorySchemaItems.Tag=[tagprefix,'panel'];
    MemorySchemaItems.Items={PhyMemConfig,CacheConfig};
    MemorySchemaItems.LayoutGrid=[3,6];
    MemorySchemaItems.RowStretch=[0,1,0];

    dlgstruct.Name=hView.mLabels.Memory.Name;
    dlgstruct.Items={MemorySchemaItems};


    function memoryBankSelectionChanged(dlg,row,col)%#ok<INUSD>

        cs=dlg.getDialogSource().getConfigSet();

        controller=get_param(cs,'TargetHardwareResourcesController');
        hView=controller.getView();
        hView.mCurSelection.MemoryBank.Row=row;
        dlg.setEnabled('TargetPrefMemory_DeleteMemoryBank',hView.mController.isMemoryBankRemovable(hView.mCurSelection.MemoryBank.Row+1));

        function memoryBankItemChanged(dlg,row,col,val)

            cs=dlg.getDialogSource().getConfigSet();

            controller=get_param(cs,'TargetHardwareResourcesController');
            hView=controller.getView();
            hView.mCurSelection.MemoryBank.Row=row;
            switch(col)
            case 0,
                hView.mController.setMemoryBankName(hView,dlg,'TargetPrefMemory_MemoryBank',row+1,val);
            case 1,
                hView.mController.setMemoryBankAddress(hView,dlg,'TargetPrefMemory_MemoryBank',row+1,val);
            case 2,
                hView.mController.setMemoryBankLength(hView,dlg,'TargetPrefMemory_MemoryBank',row+1,val);
            case 3,
                hView.mController.setMemoryBankContents(hView,dlg,'TargetPrefMemory_MemoryBank',row+1,val+1);
            end

            function sortedMemDataArray=sortMemInfo(MemDataArray,field)%#ok<DEFNU>
                [unused,order]=sort([MemDataArray(:).(field)]);%#ok<ASGLU>
                sortedMemDataArray=MemDataArray(order);

                function cacheConfigItemChanged(dlg,row,col,val)

                    source=dlg.getDialogSource().getConfigSet();
                    controller=get_param(source,'TargetHardwareResourcesController');
                    assert(col==0,DAStudio.message('ERRORHANDLER:tgtpref:DataInconsistent'));
                    controller.setCacheConfig(dlg,'TargetPrefMemory_CacheConfig',row+1,val+1);
