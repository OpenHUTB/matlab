function out=SupportNonFinitePrompt(cs,~)




    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if isERT
        out=message('RTW:configSet:ERTDialogSupportNonFiniteName').getString;
    else
        out=message('RTW:configSet:GRTSupportNonFiniteName').getString;
    end