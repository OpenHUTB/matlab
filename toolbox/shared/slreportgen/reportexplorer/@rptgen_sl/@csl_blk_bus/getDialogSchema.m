function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    w=this.dlgWidget;

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    w.isHierarchy
    w.BusAnchor
    w.SignalAnchor
    w.ListTitle
    },getString(message('RptgenSL:rsl_csl_blk_bus:propertiesLabel')))
    });
