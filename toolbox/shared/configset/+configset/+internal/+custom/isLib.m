function[status,dscr]=isLib(cs,name)




    dscr=[name,' is shown only if it is attached to a library'];

    isLib=false;
    hModel=cs.getModel;
    if~isempty(hModel)
        hModel=get_param(hModel,'Object');
        isLib=hModel.isLibrary;
    end

    if isLib
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.UnAvailable;
    end

