function schema=reqCopy(cbinfo)



    schema=sl_action_schema;
    chartId=SFStudio.Utils.getChartId(cbinfo);

    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);

    if~isReq
        return;
    end
    schema.tag='Simulink:Copy';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Copy');
    schema.icon='copy';
    schema.accelerator='Ctrl+C';
    schema.callback=@reqTableCopyCB;
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
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Copy');
    elseif selectionInfo.RowIndex(1)>-1&&selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqCopyCellActionText');
    elseif selectionInfo.RowIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqCopyRowActionText');
    elseif selectionInfo.ColumnIndex(1)>-1
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqCopyColumnActionText');
    end

    schema.state='Enabled';
    schema.autoDisableWhen='Never';
end

function reqTableCopyCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    if any(strcmp(cbinfo.Context.TypeChain,'ROW'))||any(strcmp(cbinfo.Context.TypeChain,'MULTIROW'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'copyRowCB'},false);
    elseif any(strcmp(cbinfo.Context.TypeChain,'COLUMN'))||any(strcmp(cbinfo.Context.TypeChain,'MULTICOLUMN'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'copyColumnCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'copyCellCB'},false);
    end
end
