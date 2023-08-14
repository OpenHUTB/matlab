function tooltip=SILDebugging_TT(~,~)
    if ispc
        dbg=message('PIL:pil:MSVCName').getString;
    else
        dbg=message('PIL:pil:DataDisplayDebuggerName').getString;
    end
    tooltip=message('RTW:configSet:ERTDialogSILDebuggingToolTip',dbg).getString;