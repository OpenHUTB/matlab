function[out,dscr]=tlmgCompilerSelect_status(cs,name)


    dscr='';

    adp=configset.internal.data.ConfigSetAdapter(cs);
    w=adp.getWidgetDataList(name);
    w=w{1};
    vals=w.getAllowedValues(cs);
    if length(vals)<=1
        out=configset.internal.data.ParamStatus.ReadOnly;
    else
        out=configset.internal.data.ParamStatus.Normal;
    end
