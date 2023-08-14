function out=MatFileLoggingTag(cs,~)




    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out='Tag_ConfigSet_RTW_ERT_MatFileLogging';
    else
        out='Tag_ConfigSet_RTW_GRT_MatFileLogging';
    end