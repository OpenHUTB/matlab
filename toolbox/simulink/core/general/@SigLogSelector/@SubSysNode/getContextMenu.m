function cm=getContextMenu(h,~)





    if isa(h,'SigLogSelector.SFObjectNode')
        cm=[];
        return;
    end


    me=SigLogSelector.getExplorer;
    am=DAStudio.ActionManager;
    cm=am.createPopupMenu(me);


    action=me.getAction('CONTEXT_OPEN');
    cm.addMenuItem(action);

    if~isa(h,'SigLogSelector.BdNode')
        action=me.getAction('CONTEXT_HIGHLIGHT');
        cm.addMenuItem(action);
    end

    action=me.getAction('CONTEXT_UNHIGHLIGHT');
    cm.addMenuItem(action);


    if isa(h,'SigLogSelector.SFChartNode')
        return;
    end

    cm.addSeparator;


    if me.displayFullMenus&&~isa(h,'SigLogSelector.MdlRefNode')


        sub_m=am.createPopupMenu(me);

        action=me.getAction('CONTEXT_ALL_IN');
        sub_m.addMenuItem(action);

        action=me.getAction('CONTEXT_ALL_IN_AND_BELOW');
        sub_m.addMenuItem(action);

        sub_m.addSeparator;

        action=me.getAction('CONTEXT_BOUNDARIES');
        sub_m.addMenuItem(action);

        sub_m.addSeparator;

        action=me.getAction('CONTEXT_ALL_NAMED_IN');
        sub_m.addMenuItem(action);

        action=me.getAction('CONTEXT_ALL_NAMED_IN_AND_BELOW');
        sub_m.addMenuItem(action);

        sub_m.addSeparator;

        action=me.getAction('CONTEXT_ALL_UNNAMED_IN');
        sub_m.addMenuItem(action);

        action=me.getAction('CONTEXT_ALL_UNNAMED_IN_AND_BELOW');
        sub_m.addMenuItem(action);

        cm.addSubMenu(sub_m,...
        DAStudio.message('Simulink:Logging:SigLogDlgEnableLoggingMenu'));


        sub_m=am.createPopupMenu(me);

        action=me.getAction('CONTEXT_ALL_IN_OFF');
        sub_m.addMenuItem(action);

        action=me.getAction('CONTEXT_ALL_IN_AND_BELOW_OFF');
        sub_m.addMenuItem(action);

        sub_m.addSeparator;

        action=me.getAction('CONTEXT_BOUNDARIES_OFF');
        sub_m.addMenuItem(action);

        sub_m.addSeparator;

        action=me.getAction('CONTEXT_ALL_NAMED_IN_OFF');
        sub_m.addMenuItem(action);

        action=me.getAction('CONTEXT_ALL_NAMED_IN_AND_BELOW_OFF');
        sub_m.addMenuItem(action);

        sub_m.addSeparator;

        action=me.getAction('CONTEXT_ALL_UNNAMED_IN_OFF');
        sub_m.addMenuItem(action);

        action=me.getAction('CONTEXT_ALL_UNNAMED_IN_AND_BELOW_OFF');
        sub_m.addMenuItem(action);

        cm.addSubMenu(sub_m,...
        DAStudio.message('Simulink:Logging:SigLogDlgDisableLoggingMenu'));

        cm.addSeparator;
    end


    if~isa(h,'SigLogSelector.BdNode')
        action=me.getAction('CONTEXT_PROPERTIES');
        cm.addMenuItem(action);
    end
end
