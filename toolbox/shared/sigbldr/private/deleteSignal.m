function[UD,modified]=deleteSignal(UD,chanIdx,dialog)








    UD.adjust.XDisp=[];
    UD.adjust.YDisp=[];

    UD=update_undo(UD,'delete','channel',chanIdx,[]);

    groupSignalRemove(UD.sbobj,chanIdx);
    UD=remove_channel(UD,chanIdx);

    UD=mouse_handler('ForceMode',dialog,UD,1);
    UD=set_dirty_flag(UD);

    modified=1;
