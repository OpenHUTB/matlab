function schema=reqCut(cbinfo)



    schema=sl_action_schema;
    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    if~isReq
        return;
    end
    schema.tag='Simulink:Cut';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Cut');
    schema.icon='cut';
    schema.accelerator='Ctrl+X';
    schema.callback=@reqTableCutCB;
    schema.refreshCategories={'interval#12','GenericEvent:Clipboard','GenericEvent:Select','SelectionChanged'};

    if any(strcmp(cbinfo.Context.TypeChain,'ReqTableEditorAutoChartContext'))
        schema.state='Disabled';
        return;
    end

    typeChain=cbinfo.Context.TypeChain;

    if size(typeChain,1)<3
        schema.state='Disabled';
        return;
    end

    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);

    if isempty(selectionInfo.RowIndex)||isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Cut');
    elseif selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqCutCellActionText');
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqCutRowActionText');
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqCutColumnActionText');
    end

    if selectionInfo.IsAllTopRowsSelected
        schema.state='Disabled';
        return;
    end

    schema.state='Enabled';
    schema.autoDisableWhen='Busy';
    schema.autoDisableWhen='Locked';

end

function reqTableCutCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    if any(strcmp(cbinfo.Context.TypeChain,'ROW'))||any(strcmp(cbinfo.Context.TypeChain,'MULTIROW'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'cutRowCB'},false);
    elseif any(strcmp(cbinfo.Context.TypeChain,'COLUMN'))||any(strcmp(cbinfo.Context.TypeChain,'MULTICOLUMN'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'cutColumnCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'cutCellCB'},false);
    end

end
