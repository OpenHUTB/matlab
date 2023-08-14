function dlgStruct=getDialogSchema(this,name)




    dlgStruct=this.dlgMain(name,this.dlgContainer({
    this.dlgText(getString(message('rptgen:RptgenML_Library:dragComponentsMsg')))
    }));

    dlgStruct.DialogTitle=getString(message('rptgen:RptgenML_Library:availableComponentsLabel'));
