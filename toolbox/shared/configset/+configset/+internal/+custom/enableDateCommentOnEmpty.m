function[status,dscr]=enableDateCommentOnEmpty(cs,name)




    dscr='';
    adp=configset.internal.getConfigSetAdapter(cs);
    param=adp.widgetToParam(name);

    modelName=get_param(cs.getModel,'Name');
    val=hdlget_param(modelName,'CustomFileHeaderComment');

    if isempty(val)
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.ReadOnly;
    end