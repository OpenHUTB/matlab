function[status,dscr]=CodeHighlightOption_status(cs,~)



    dscr='';

    if cs.isActive&&~cs.isObjectLocked
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.ReadOnly;
    end