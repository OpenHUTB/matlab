function schema=addDataForMonitoringRF(~,cbinfo)
    cbinfo.userdata='ChildActivity';
    objectId=SFStudio.Utils.getChartId(cbinfo);
    objH=sf('IdToHandle',double(objectId));
    schema=SFStudio.MenuBarMenus('MonitorSelfActivity',cbinfo);
    if objectId==0
        schema.state='Disabled';
        return;
    end
    cdUtils=Stateflow.ChartDialogUtils(objH,true);
    [chk,~]=cdUtils.should_monitoring_check_box_be_enabled();
    if~chk||objH.Iced
        schema.state='Disabled';
    end
    schema.icon='addOutportToSimulink';


end
