function out=CodeInterfacePackagingTag(cs,~)





    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out='Tag_ConfigSet_RTW_ERT_CodeInterfacePackaging';
    else
        out='Tag_ConfigSet_RTW_GRT_CodeInterfacePackaging';
    end

