function schema=reqAppend(cbinfo)




    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    schema=sl_action_schema;

    if~isReq
        return;
    end
    schema.tag='Simulink:Append';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:TtAppendRowActionText');
    schema.icon='appendRow';
    schema.callback=@reqTableAppendCB;
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




        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendColumnActionText');
        schema.icon='appendTransitionColumn';
        schema.state='Disabled';
        schema.callback=@reqTableAppendCB;
        return;
    end

    schema.state='Enabled';

    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    if~isempty(selectionInfo.RowIndex)&&isempty(selectionInfo.ColumnIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendRowActionText');
        schema.icon='appendRow';
        if~selectionInfo.IsAppendRowEnabled
            schema.state='Disabled';
        end
    elseif~isempty(selectionInfo.ColumnIndex)&&isempty(selectionInfo.RowIndex)
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendColumnActionText');
        schema.icon='appendTransitionColumn';
        if~selectionInfo.IsAppendColumnEnabled
            schema.state='Disabled';
        end
    elseif selectionInfo.CanAppendColumnFromCell
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendColumnActionText');
        schema.icon='appendTransitionColumn';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendColumnActionText');
        schema.icon='appendTransitionColumn';
        schema.state='Disabled';
    end
end

function reqTableAppendCB(cbinfo)

    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(subviewerId);
    if selectionInfo.CanAppendColumnFromCell
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'appendColumnFromCellCB'},false);
    elseif any(strcmp(cbinfo.Context.TypeChain,'ROW'))||any(strcmp(cbinfo.Context.TypeChain,'MULTIROW'))
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'appendRowCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'appendColumnCB'},false);
    end

end
