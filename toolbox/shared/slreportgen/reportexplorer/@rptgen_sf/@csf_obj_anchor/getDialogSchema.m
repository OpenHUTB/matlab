function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    w=this.dlgWidget;

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    w.LinkText
    },getString(message('RptgenSL:rsf_csf_obj_anchor:propertiesLabel')))
    });
