function[status,errstr]=postRevertCallback(this,dlg)




    try
        status=true;
        errstr='';

        this.revert(dlg);
    catch MEx
        status=false;
        errstr=getString(message(MEx.identifier));
    end
end
