function[status,dscr]=disableOnInactiveOrDD(cs,~)








    dscr='';
    modelWithBWS=false;

    mdl=cs.getModel;
    if~isempty(mdl)
        modelWithBWS=strcmp(get_param(mdl,'HasAccessToBaseWorkSpace'),'on');
    end

    if cs.isActive&&modelWithBWS
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.ReadOnly;
    end


