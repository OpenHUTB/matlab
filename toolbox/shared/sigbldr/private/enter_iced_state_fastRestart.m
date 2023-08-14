function UD=enter_iced_state_fastRestart(UD)





    UD.current.state='ICED_FS';
    set(UD.dialog,'UserData',UD);
    if~isempty(UD.axes)
        color_axes_l([UD.axes.handle],'ICED_FS');
    end

    set(iced_menu_toolbar_list_fastRestart(UD.menus.figmenu,UD.menus.channelContext,UD.toolbar),'enable','off');
    UD=update_channel_select(UD);
