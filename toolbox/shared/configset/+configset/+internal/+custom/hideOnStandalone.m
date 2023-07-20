function[status,dscr]=hideOnStandalone(cs,~)



    dscr='';
    mdl=cs.getModel;
    if isempty(mdl)
        status=configset.internal.data.ParamStatus.UnAvailable;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end