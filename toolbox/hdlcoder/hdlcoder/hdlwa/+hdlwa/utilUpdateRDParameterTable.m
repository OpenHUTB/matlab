function utilUpdateRDParameterTable(mdladvObj,hDI)





    if~hDI.showReferenceDesignTasks
        return;
    end

    hRD=hDI.hIP.getReferenceDesignPlugin;
    if isempty(hRD)
        return;
    end

    tablesetting=hRD.drawParameterGUITable;


    tableInputParams=mdladvObj.getInputParameters('com.mathworks.HDL.SetTargetReferenceDesign');
    parameterTable=hdlwa.utilGetInputParameter(tableInputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputRDParameterTable'));

    parameterTable.TableSetting.Size=tablesetting.Size;
    parameterTable.TableSetting.Data=tablesetting.Data;
    parameterTable.TableSetting.ColHeader=tablesetting.ColHeader;
    parameterTable.TableSetting.ColumnCharacterWidth=tablesetting.ColumnCharacterWidth;


    parameterTable.TableSetting.ColumnHeaderHeight=tablesetting.ColumnHeaderHeight;
    parameterTable.TableSetting.HeaderVisibility=tablesetting.HeaderVisibility;
    parameterTable.TableSetting.ReadOnlyColumns=tablesetting.ReadOnlyColumns;
    parameterTable.TableSetting.MinimumSize=tablesetting.MinimumSize;


    parameterTable.Enable=~hRD.isParameterTableEmpty;
