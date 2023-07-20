function UD=selectSignal(UD,chanIdx,axesIdx)





    if~isempty(axesIdx)
        UD.current.channel=chanIdx;
        mouseMode=3;
    else
        UD.current.channel=0;
        mouseMode=1;
    end
    UD=mouse_handler('ForceMode',[],UD,mouseMode);
    UD=update_channel_select(UD);
