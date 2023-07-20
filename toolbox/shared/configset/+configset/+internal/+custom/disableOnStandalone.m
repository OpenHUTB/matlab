function[status,dscr]=disableOnStandalone(cs,~)



    dscr='';
    mdl=cs.getModel;
    if isempty(mdl)
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end


