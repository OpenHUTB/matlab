function UD=reset_dirty_flag(UD)



    UD.common.dirtyFlag=0;
    titleStr=get(UD.dialog,'Name');
    if strcmp(titleStr((end-1):end),' *')
        set(UD.dialog,'Name',titleStr(1:(end-2)));
    end