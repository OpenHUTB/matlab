function success=setModelEditingMode_simulinkMenu(this,hModel,requestedMode)






    try
        success=this.setModelEditingMode(hModel,requestedMode);
    catch exception
        showErrorDlg(exception.message);
        success=false;
    end








