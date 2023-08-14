function out=GRTInterfaceTag(cs,~)




    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out='Tag_ConfigSet_RTW_ERT_GRTInterface';
    else
        out='Tag_ConfigSet_RTW_GRT_GRTInterface';
    end