function schema=reqUncomment(cbinfo)



    schema=sl_action_schema;

    chartId=SFStudio.Utils.getChartId(cbinfo);
    isReq=Stateflow.ReqTable.internal.isRequirementsTable(chartId);
    if~isReq
        return;
    end
    schema.icon='comment';
    schema.callback=@reqUncommentCB;
    schema.autoDisableWhen='Locked';

    schema.state='Enabled';
    schema.icon='commentOutRemove';
    selectionInfo=Stateflow.ReqTable.internal.TableManager.getSelectionInfo(chartId);
    if isempty(selectionInfo.RowIndex)||~isempty(selectionInfo.ColumnIndex)
        schema.state='Disabled';
    else
        rows=Stateflow.ReqTable.internal.TableManager.getSelectedRows(chartId);
        allRowsUnCommented=all(arrayfun(@(x)x.commentOut~=true,rows));
        if allRowsUnCommented
            schema.state='Disabled';
        end
    end

end

function reqUncommentCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
    Stateflow.ReqTable.internal.TableManager.dispatchUIRequest(subviewerId,'evalContextMenuFunctions',{'commentRowCB'},false);

end
