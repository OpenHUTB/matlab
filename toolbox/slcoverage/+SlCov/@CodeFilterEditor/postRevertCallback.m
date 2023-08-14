function[status,errstr]=postRevertCallback(this,dlg)




    status=false;
    errstr='';

    try
        this.revert(dlg);
        this.needSave=false;
        status=true;
    catch MEx
        errstr=getString(message(MEx.identifier));
    end
