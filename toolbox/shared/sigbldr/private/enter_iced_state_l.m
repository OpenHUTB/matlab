function UD=enter_iced_state_l(UD)





    UD.current.state='ICED';
    set(UD.dialog,'UserData',UD);
    if~isempty(UD.axes)
        color_axes_l([UD.axes.handle],'ICED');
    end

    set(iced_menu_toolbar_list(UD.menus.figmenu,UD.menus.channelContext,UD.toolbar,UD.hgCtrls.tabselect),'enable','off');
    UD=update_channel_select(UD);
