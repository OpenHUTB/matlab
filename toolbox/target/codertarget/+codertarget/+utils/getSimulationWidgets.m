function info=getSimulationWidgets(hObj)




    info.ParameterGroups={};
    info.Parameters={};

    groupLabel=DAStudio.message('codertarget:ui:SimulationGroupLabel');
    info.ParameterGroups={groupLabel};
    info.Parameters={};

    label=DAStudio.message('codertarget:ui:SetSeedLabel');
    toolTip=DAStudio.message('codertarget:ui:SetSeedToolTip');
    storage=DAStudio.message('codertarget:ui:SetSeedStorage');
    pRNG.Name=label;
    pRNG.ToolTip=toolTip;
    pRNG.Type='checkbox';
    pRNG.Tag='SOCB_Set_RNG';
    pRNG.Enabled=true;
    pRNG.Visible=true;
    pRNG.Entries={};
    pRNG.Value=false;
    pRNG.Data={};
    pRNG.RowSpan=[3,3];
    pRNG.ColSpan=[1,3];
    pRNG.Alignment=0;
    pRNG.DialogRefresh=0;
    pRNG.Storage=storage;
    pRNG.DoNotStore=false;
    pRNG.Callback='widgetChangedCallback';
    pRNG.SaveValueAsString=true;
    pRNG.ValueType='';
    pRNG.ValueRange='';
    info.Parameters{1}{1}=pRNG;

    label=DAStudio.message('codertarget:ui:RNGSeedLabel');
    toolTip=DAStudio.message('codertarget:ui:RNGSeedToolTip');
    storage=DAStudio.message('codertarget:ui:RNGSeedStorage');
    pSeed.Name=label;
    pSeed.ToolTip=toolTip;
    pSeed.Type='edit';
    pSeed.Tag='SOCB_RNG_Seed';
    pSeed.Enabled=true;
    pSeed.Visible=true;
    pSeed.Entries={};
    pSeed.Value='default';
    pSeed.Data={};
    pSeed.RowSpan=[4,4];
    pSeed.ColSpan=[1,3];
    pSeed.Alignment=0;
    pSeed.DialogRefresh=0;
    pSeed.Storage=storage;
    pSeed.DoNotStore=false;
    pSeed.Callback='soc.internal.dialog.seedValueCallback';
    pSeed.SaveValueAsString=true;
    pSeed.ValueType='';
    pSeed.ValueRange='';
    info.Parameters{1}{2}=pSeed;

    label=DAStudio.message('codertarget:ui:CacheDataLabel');
    toolTip=DAStudio.message('codertarget:ui:CacheDataToolTip');
    storage=DAStudio.message('codertarget:ui:CacheDataStorage');
    pCacheData.Name=label;
    pCacheData.ToolTip=toolTip;
    pCacheData.Type='checkbox';
    pCacheData.Tag='SOCB_Cache_Data';
    pCacheData.Enabled=true;
    pCacheData.Visible=true;
    pCacheData.Entries={};
    pCacheData.Value=false;
    pCacheData.Data={};
    pCacheData.RowSpan=[5,5];
    pCacheData.ColSpan=[1,3];
    pCacheData.Alignment=0;
    pCacheData.DialogRefresh=0;
    pCacheData.Storage=storage;
    pCacheData.DoNotStore=false;
    pCacheData.Callback='widgetChangedCallback';
    pCacheData.SaveValueAsString=true;
    pCacheData.ValueType='';
    pCacheData.ValueRange='';
    info.Parameters{1}{3}=pCacheData;

    label='ScheduleEditorScheduleReset';
    toolTip='ScheduleEditorScheduleReset';
    storage='ESB.ScheduleEditorScheduleReset';
    pSchedEditor.Name=label;
    pSchedEditor.ToolTip=toolTip;
    pSchedEditor.Type='checkbox';
    pSchedEditor.Tag='SOCB_ScheduleEditorScheduleReset';
    pSchedEditor.Enabled=true;
    pSchedEditor.Visible=false;
    pSchedEditor.Entries={};
    pSchedEditor.Value=false;
    pSchedEditor.Data={};
    pSchedEditor.RowSpan=[6,6];
    pSchedEditor.ColSpan=[1,3];
    pSchedEditor.Alignment=0;
    pSchedEditor.DialogRefresh=0;
    pSchedEditor.Storage=storage;
    pSchedEditor.DoNotStore=false;
    pSchedEditor.Callback='widgetChangedCallback';
    pSchedEditor.SaveValueAsString=true;
    pSchedEditor.ValueType='';
    pSchedEditor.ValueRange='';
    info.Parameters{1}{4}=pSchedEditor;

end



function ret=locIsParameterOn(hObj,param)
    ret=codertarget.data.isParameterInitialized(hObj,param)&&...
    codertarget.data.getParameterValue(hObj,param);
end


