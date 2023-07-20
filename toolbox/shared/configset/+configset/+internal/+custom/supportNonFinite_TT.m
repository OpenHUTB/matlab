function tooltip=supportNonFinite_TT(cs,~)

    key='RTW:configSet:ERTDialogSupportNonFiniteToolTip';
    if strcmp(cs.get_param('IsERTTarget'),'off')
        key='RTW:configSet:GRTSupportNonFiniteToolTip';
    end
    if strcmp(cs.get_param('PurelyIntegerCode'),'on')&&strcmp(cs.get_param('SupportNonFinite'),'off')
        key=strrep(key,'NonFinite','NonFinited1');
    end
    tooltip=message(key).getString;
