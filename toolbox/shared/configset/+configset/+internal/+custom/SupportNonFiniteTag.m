function out=SupportNonFiniteTag(cs,~)




    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out='Tag_ConfigSet_RTW_ERT_SupportNonFinite';
    else
        out='Tag_ConfigSet_RTW_GRT_SupportNonFinite';
    end