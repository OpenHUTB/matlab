function[UD,modified]=changeIndexSignal(UD,newIdx,chanIdx)







    if(chanIdx==newIdx)
        modified=0;
        return;
    end
    UD=update_undo(UD,'move','channel',newIdx,chanIdx);
    UD=change_channel_index(UD,newIdx,chanIdx);
    UD=update_show_menu(UD);
    modified=1;
    UD=set_dirty_flag(UD);