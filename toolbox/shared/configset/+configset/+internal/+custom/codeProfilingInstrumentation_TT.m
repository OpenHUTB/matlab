function tooltip=codeProfilingInstrumentation_TT(~,~)
    taskName=message('RTW:configSet:ERTDialogSilPilExecProfiling').getString;
    tooltip=message('RTW:configSet:ERTDialogCodeProfInstrToolTip',taskName).getString;
