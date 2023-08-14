function UD=dataSet_sync_menu_state(UD)




    dsCnt=length(UD.dataSet);

    if dsCnt==1
        hgObjs=[UD.menus.figmenu.GroupMenuDelete...
        ,UD.menus.figmenu.GroupMenuMoveRight...
        ,UD.menus.figmenu.GroupMenuMoveLeft...
        ,UD.menus.tabContext.GroupCntxtDelete...
        ,UD.menus.tabContext.GroupCntxtRight...
        ,UD.menus.tabContext.GroupCntxtLeft...
        ];
        set(hgObjs,'Enable','off');
    else
        set([UD.menus.figmenu.GroupMenuDelete,UD.menus.tabContext.GroupCntxtDelete],'Enable','on');
        if UD.current.dataSetIdx==1
            set([UD.menus.figmenu.GroupMenuMoveLeft,UD.menus.tabContext.GroupCntxtLeft],'Enable','off');
        else
            set([UD.menus.figmenu.GroupMenuMoveLeft,UD.menus.tabContext.GroupCntxtLeft],'Enable','on');
        end

        if UD.current.dataSetIdx==dsCnt
            set([UD.menus.figmenu.GroupMenuMoveRight,UD.menus.tabContext.GroupCntxtRight],'Enable','off');
        else
            set([UD.menus.figmenu.GroupMenuMoveRight,UD.menus.tabContext.GroupCntxtRight],'Enable','on');
        end
    end