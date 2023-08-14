function tooltip=rtwUseSimCustomCode_TT(cs,~)
    isLib=false;
    mdl=cs.getModel;
    if~isempty(mdl)
        hMdl=get_param(mdl,'Object');
        isLib=hMdl.isLibrary;
    end

    tooltip=message('RTW:configSet:usSimCustomCodeToolTip').getString;
    if isLib
        tooltip=[tooltip,' ',message('RTW:configSet:usSimCustomCodeToolTip2').getString];
    end
