function[status,dscr]=connectInputButtonStatus(cs,~)



    dscr='';
    mdl=cs.getModel;
    if isempty(mdl)||isempty(cs.getConfigSet)||~cs.isActive
        status=configset.internal.data.ParamStatus.ReadOnly;
    else








        status=configset.internal.data.ParamStatus.Normal;
    end


