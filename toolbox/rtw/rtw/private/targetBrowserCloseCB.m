function[ok,errmsg]=targetBrowserCloseCB(hObj,val)



    ok=1;
    errmsg='';

    try
        hObj.getDialogSource.uploadTarget(val);
    catch exc
        ok=0;
        errmsg=exc.message;
    end
