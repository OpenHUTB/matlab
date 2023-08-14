function UD=enter_idle_state_l(UD)





    UD.current.state='IDLE';
    set(UD.dialog,'UserData',UD);
    if~isempty(UD.axes)
        color_axes_l([UD.axes.handle],'IDLE');
    end

    set(iced_menu_toolbar_list(UD.menus.figmenu,UD.menus.channelContext,UD.toolbar,UD.hgCtrls.tabselect),'enable','on');

    if isempty(UD.clipboard.content)
        objs=[UD.menus.channelContext.SignalCntxtPaste...
        ,UD.menus.figmenu.EditMenuPaste,UD.toolbar.paste];
        set(objs,'Enable','off');
    end
    UD=update_channel_select(UD);

