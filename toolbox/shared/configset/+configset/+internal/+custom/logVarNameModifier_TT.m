function tooltip=logVarNameModifier_TT(cs,~)

    key='RTW:configSet:ERTDialogMatNameToolTip';
    if strcmp(cs.get_param('IsERTTarget'),'off')
        key='RTW:configSet:GRTmatNameToolTip';
    end
    tooltip=message(key).getString;
