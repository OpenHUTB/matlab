function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;
    end

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgWidget('StateflowProperty')
    },getString(message('RptgenSL:rsf_csf_property:propertyToDisplayLabel')))
    this.vdGetDialogSchema(name)
    });





