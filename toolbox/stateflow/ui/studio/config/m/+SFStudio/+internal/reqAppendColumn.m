function schema=reqAppendColumn(cbinfo)
    schema=sl_action_schema;
    chartId=SFStudio.Utils.getChartId(cbinfo);


    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:reqAppendColumnActionText');
    schema.icon='appendColumn';
    schema.autoDisableWhen='Locked';
    schema.callback=@reqTableAppendColumnCB;
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);

    if~isempty(selectionInfo.ColumnIndex)&&(selectionInfo.IsAppendColumnEnabled||...
        selectionInfo.CanAppendColumnFromCell)
        schema.state='Enabled';
        return;
    end
    schema.state='Disabled';

end


function reqTableAppendColumnCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(subviewerId);
    if contains(selectionInfo.TypeChain,'CELL')
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,...
        'evalContextMenuFunctions',{'appendColumnFromCellCB'},false);
    else
        Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,...
        'evalContextMenuFunctions',{'appendColumnCB'},false);
    end
end