function UD=copySignal(UD,chanIdx)





    ActiveGroup=UD.sbobj.ActiveGroup;
    UD.clipboard.type='channel';
    UD.clipboard.content=UD.channels(chanIdx);
    UD.clipboard.content.xData=UD.sbobj.Groups(ActiveGroup).Signals(chanIdx).XData;
    UD.clipboard.content.yData=UD.sbobj.Groups(ActiveGroup).Signals(chanIdx).YData;
    UD.clipboard.content.lineH=[];
    UD.clipboard.content.axesInd=[];
    UD=enable_channel_paste(UD);

end

function UD=enable_channel_paste(UD)

    objs=[UD.menus.channelContext.SignalCntxtPaste...
    ,UD.menus.figmenu.EditMenuPaste,UD.toolbar.paste];
    set(objs,'Enable','on');
end

