function info=getSimulationDiagnosticsWidgets(hObj)




    info.ParameterGroups={};
    info.Parameters={};

    groupLabel='SimulationDiagnostics';
    info.ParameterGroups={groupLabel};
    info.Parameters={};

    label=DAStudio.message('codertarget:ui:SimDiagShowInSDILabel');
    toolTip=DAStudio.message('codertarget:ui:SimDiagShowInSDIToolTip');
    storage=DAStudio.message('codertarget:ui:SimDiagShowInSDIStorage');
    pSimShowInSDI.Name=label;
    pSimShowInSDI.ToolTip=toolTip;
    pSimShowInSDI.Type='checkbox';
    pSimShowInSDI.Tag='SOCB_Sim_Show_In_SDI';
    pSimShowInSDI.Enabled=true;
    pSimShowInSDI.Visible=true;
    pSimShowInSDI.Entries={};
    pSimShowInSDI.Value=true;
    pSimShowInSDI.Data={};
    pSimShowInSDI.RowSpan=[1,1];
    pSimShowInSDI.ColSpan=[1,3];
    pSimShowInSDI.Alignment=0;
    pSimShowInSDI.DialogRefresh=0;
    pSimShowInSDI.Storage=storage;
    pSimShowInSDI.DoNotStore=false;
    pSimShowInSDI.Callback='widgetChangedCallback';
    pSimShowInSDI.SaveValueAsString=true;
    pSimShowInSDI.ValueType='';
    pSimShowInSDI.ValueRange='';
    info.Parameters{1}{1}=pSimShowInSDI;

    label=DAStudio.message('codertarget:ui:SimDiagSaveToFileLabel');
    toolTip=DAStudio.message('codertarget:ui:SimDiagSaveToFileToolTip');
    storage=DAStudio.message('codertarget:ui:SimDiagSaveToFileStorage');
    pSimSaveToFile.Name=label;
    pSimSaveToFile.ToolTip=toolTip;
    pSimSaveToFile.Type='checkbox';
    pSimSaveToFile.Tag='SOCB_Sim_Write_To_File';
    pSimSaveToFile.Enabled=true;
    pSimSaveToFile.Visible=...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:SimDiagShowInSDIStorage'));
    pSimSaveToFile.Entries={};
    pSimSaveToFile.Value=true;
    pSimSaveToFile.Data={};
    pSimSaveToFile.RowSpan=[2,2];
    pSimSaveToFile.ColSpan=[1,1];
    pSimSaveToFile.Alignment=0;
    pSimSaveToFile.DialogRefresh=0;
    pSimSaveToFile.Storage=storage;
    pSimSaveToFile.DoNotStore=false;
    pSimSaveToFile.Callback='widgetChangedCallback';
    pSimSaveToFile.SaveValueAsString=true;
    pSimSaveToFile.ValueType='';
    pSimSaveToFile.ValueRange='';
    info.Parameters{1}{2}=pSimSaveToFile;

    label=DAStudio.message('codertarget:ui:SimDiagOverwriteFileLabel');
    toolTip=DAStudio.message('codertarget:ui:SimDiagOverwriteFileToolTip');
    storage=DAStudio.message('codertarget:ui:SimDiagOverwriteFileStorage');
    pSimOverwriteFile.Name=label;
    pSimOverwriteFile.ToolTip=toolTip;
    pSimOverwriteFile.Type='checkbox';
    pSimOverwriteFile.Tag='SOCB_Sim_Overwrite_File';
    pSimOverwriteFile.Enabled=true;
    pSimOverwriteFile.Visible=...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:SimDiagShowInSDIStorage'))&&...
    locIsParameterOn(hObj,...
    DAStudio.message('codertarget:ui:SimDiagSaveToFileStorage'));
    pSimOverwriteFile.Entries={};
    pSimOverwriteFile.Value=false;
    pSimOverwriteFile.Data={};
    pSimOverwriteFile.RowSpan=[2,2];
    pSimOverwriteFile.ColSpan=[2,2];
    pSimOverwriteFile.Alignment=0;
    pSimOverwriteFile.DialogRefresh=0;
    pSimOverwriteFile.Storage=storage;
    pSimOverwriteFile.DoNotStore=false;
    pSimOverwriteFile.Callback='widgetChangedCallback';
    pSimOverwriteFile.SaveValueAsString=true;
    pSimOverwriteFile.ValueType='';
    pSimOverwriteFile.ValueRange='';
    info.Parameters{1}{3}=pSimOverwriteFile;
end


function ret=locIsParameterOn(hObj,param)
    ret=codertarget.data.isParameterInitialized(hObj,param)&&...
    codertarget.data.getParameterValue(hObj,param);
end


