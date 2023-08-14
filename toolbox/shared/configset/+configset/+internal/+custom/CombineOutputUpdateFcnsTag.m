function out=CombineOutputUpdateFcnsTag(cs,~)




    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out='Tag_ConfigSet_RTW_ERT_CombineOutputUpdateFcns';
    else
        out='Tag_ConfigSet_RTW_GRT_CombineOutputUpdateFcns';
    end