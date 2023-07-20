function[status,dscr]=disableOnEmpty(cs,name)




    dscr='';
    adp=configset.internal.getConfigSetAdapter(cs);
    param=adp.widgetToParam(name);
    val=cs.getProp(param);
    if isempty(val)
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end


