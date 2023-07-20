function disabled=getDialogFinalDisabledStatus(hThis)






    isBlockLocked=pmsl_isblocklocked(hThis.BlockHandle);

    disabled=getDialogDisabledStatus(hThis);


    disabled=isBlockLocked||disabled;

end