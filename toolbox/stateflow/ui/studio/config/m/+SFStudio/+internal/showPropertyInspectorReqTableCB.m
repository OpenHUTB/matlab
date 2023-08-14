



function showPropertyInspectorReqTableCB(cbinfo)

    import Stateflow.ReqTable.internal.TableManager.*;
    studio=cbinfo.studio;
    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');

    sfObj=cbinfo.uiObject;
    chartId=sfprivate('getChartOf',sfObj.Id);
    tableData=getTableData(chartId);
    if~pi.isVisible
        req=getSelectedRows(chartId);
        studio.showComponent(pi);
        if isscalar(req)
            slReqBridge=tableData.slReqBridge;
            slReqBridge.updateSelection(req);
        end
    else
        studio.hideComponent(pi);
    end
end
