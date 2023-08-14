function dlgStruct=getDialogSchema(this,~)
































    this.paramsMap=this.getDialogParams;


    h=this.getBlock;


    try
        dlgStruct=this.createBusDialog(h);
    catch ME
        dlgStruct=this.errorDlg(h,ME.message);
    end
end


