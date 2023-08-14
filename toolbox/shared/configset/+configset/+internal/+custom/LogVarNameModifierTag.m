function out=LogVarNameModifierTag(cs,~)




    if strcmp(cs.getProp('SystemTargetFile'),'rsim.tlc')
        out='Tag_ConfigSet_Target_RSIM_LogVarNameModifier';
        return;
    end


    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out='Tag_ConfigSet_RTW_ERT_LogVarNameModifier';
    else
        out='Tag_ConfigSet_RTW_GRT_LogVarNameModifier';
    end