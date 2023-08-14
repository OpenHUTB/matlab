function schema=reqDelete(cbinfo)



    schema=sl_action_schema;

    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    if~isReq
        return;
    end
    schema.tag='Simulink:Delete';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Delete');
    schema.icon='delete';
    schema.accelerator='delete';
    schema.callback=@reqTableDeleteCB;
    schema.autoDisableWhen='Locked';

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
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Delete');
    elseif~isempty(selectionInfo.RowIndex)&&~isempty(selectionInfo.ColumnIndex(1))
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqClearActionText');
        schema.icon='clear';
    elseif~isempty(selectionInfo.RowIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqDeleteRowActionText');
        schema.icon='deleteRow';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqDeleteColumnActionText');
        schema.icon='deleteColumn';
    end

    schema.state='Enabled';
end

function reqTableDeleteCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    if any(strcmp(cbinfo.Context.TypeChain,'ROW'))||any(strcmp(cbinfo.Context.TypeChain,'MULTIROW'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'deleteRowCB'},false);
    elseif any(strcmp(cbinfo.Context.TypeChain,'COLUMN'))||any(strcmp(cbinfo.Context.TypeChain,'MULTICOLUMN'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'deleteColumnCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'deleteCellCB'},false);
    end
end
