function[ret,langConstraint]=isCompliantWithTargetLang(h,hTarget)





    ret=true;
    isMatlabCoder=false;


    targetLang={'C','C89/C90 (ANSI)'};

    if~(isprop(hTarget,'IsERTTarget')||isfield(hTarget,'IsERTTarget'))
        return;
    end

    if isa(hTarget,'Simulink.ConfigComponent')
        hConfigSet=hTarget.getConfigSet();
        if~isempty(hConfigSet)
            targetLang={get_param(hConfigSet,'TargetLang')...
            ,get_param(hConfigSet,'TargetLangStandard')};
        end
    elseif isprop(hTarget,'TargetLang')||isfield(hTarget,'TargetLang')
        isMatlabCoder=true;
        targetLang={hTarget.TargetLang...
        ,hTarget.TargetLangStandard};
    end

    [ret,langConstraint]=rtwprivate('isTargetLangSupportedByTFL',h,targetLang,isMatlabCoder);


