function dlgDeleteStatic(dlgH,tag,key)















    if strcmpi(key,'del')
        dlgDelete(dlgH.getDialogSource,dlgH);
    end