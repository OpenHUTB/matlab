function UD=set_dirty_flag(UD,noMdlDirty)




    if UD.common.dirtyFlag==1
        return;
    end

    if nargin<2
        noMdlDirty=false;
    end

    UD.common.dirtyFlag=1;
    titleStr=get(UD.dialog,'Name');
    if~strcmp(titleStr((end-1):end),' *')
        set(UD.dialog,'Name',[titleStr,' *']);
    end

    if~isempty(UD.simulink)&&~noMdlDirty
        set_param(UD.simulink.modelH,'dirty','on');
    end