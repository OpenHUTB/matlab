function schema=reqPaste(cbinfo)



    schema=sl_action_schema;


    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    if~isReq
        return;
    end
    schema.tag='Simulink:Paste';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Paste');
    schema.icon='paste';
    schema.accelerator='Ctrl+V';
    schema.callback=@reqTablePasteCB;
    schema.refreshCategories={'GenericEvent:Clipboard'};

    if any(strcmp(cbinfo.Context.TypeChain,'ReqTableEditorAutoChartContext'))
        schema.state='Disabled';
        return;
    end

    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);

    if isempty(selectionInfo.RowIndex)||isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Paste');
    elseif~isempty(selectionInfo.RowIndex)&&~isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtPasteCellActionText');
    elseif~isempty(selectionInfo.RowIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtPasteRowActionText');
    elseif~isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtPasteColumnActionText');
    end

    if selectionInfo.CanPaste
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
    schema.autoDisableWhen='Locked';

end

function reqTablePasteCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    if any(strcmp(cbinfo.Context.TypeChain,'ROW'))||any(strcmp(cbinfo.Context.TypeChain,'MULTIROW'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'pasteRowCB'},false);
    elseif any(strcmp(cbinfo.Context.TypeChain,'COLUMN'))||any(strcmp(cbinfo.Context.TypeChain,'MULTICOLUMN'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'pasteColumnCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'pasteCellCB'},false);
    end
end
