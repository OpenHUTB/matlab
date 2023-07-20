function schema=reqInsert(cbinfo)




    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    schema=sl_action_schema;

    if~isReq
        return;
    end
    schema.tag='Simulink:Insert';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqInsertRowActionText');
    schema.icon='insertRow';
    schema.callback=@reqTableInsertCB;
    schema.autoDisableWhen='Locked';

    if any(strcmp(cbinfo.Context.TypeChain,'ReqTableEditorAutoChartContext'))
        schema.state='Disabled';
        return;
    end
    typeChain=cbinfo.Context.TypeChain;
    if size(typeChain,1)<3
        schema.state='Disabled';
        return;
    elseif any(strcmp(cbinfo.Context.TypeChain,'TABLE'))




        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendRowActionText');
        schema.icon='appendRow';
        schema.state='Disabled';
        schema.callback=@reqTableAppendRowCB;
        return;
    end


    schema.state='Enabled';

    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    if~isempty(selectionInfo.RowIndex)&&isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqInsertRowActionText');
        schema.icon='insertRow';
        if~selectionInfo.IsInsertRowEnabled
            schema.state='Disabled';
        end
    elseif~isempty(selectionInfo.ColumnIndex)&&isempty(selectionInfo.RowIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqInsertColumnActionText');
        schema.icon='insertTransitionColumn';
        if~selectionInfo.IsInsertColumnEnabled
            schema.state='Disabled';
        end
    elseif selectionInfo.CanAppendRowFromCell
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendRowActionText');
        schema.icon='appendRow';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqInsertRowActionText');
        schema.icon='insertRow';
        schema.state='Disabled';
    end
end

function reqTableInsertCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(subviewerId);
    if selectionInfo.CanAppendRowFromCell
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'appendRowFromCellCB'},false);
    elseif any(strcmp(cbinfo.Context.TypeChain,'ROW'))||any(strcmp(cbinfo.Context.TypeChain,'MULTIROW'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'insertRowCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'insertColumnCB'},false);
    end

end

function reqTableAppendRowCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'appendRowCB'},false);

end
