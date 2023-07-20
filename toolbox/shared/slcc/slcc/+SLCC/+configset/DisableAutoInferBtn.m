function[status,dscr]=DisableAutoInferBtn(cs,~)



    dscr='';
    srcFiles=strip(cs.get_param('SimUserSources'));
    if isempty(srcFiles)
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end