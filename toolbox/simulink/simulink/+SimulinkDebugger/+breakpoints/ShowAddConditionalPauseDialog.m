function ShowAddConditionalPauseDialog(modelH,portH,bpIdx)





    condStatus.index=bpIdx;
    deletedVal=3;
    condStatus.status=deletedVal;
    set_param(portH,'ConditionalPauseStatus',condStatus)


    SLStudio.ShowAddConditionalPauseDialog(modelH,portH)
end