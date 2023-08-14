function openSimulinkTestApp(model)

    ed=SLM3I.SLDomain.getLastActiveEditorFor(get_param(model,'handle'));
    if isempty(ed)
        return;
    end

    st=ed.getStudio();
    sa=st.App;
    acm=sa.getAppContextManager;

    c=dig.Configuration.get();
    app=c.getApp('testHarnessManagerApp');

    if isempty(app)
        return;
    end

    customContext=sltest.internal.menus.SLTContext(get_param(model,'Object'),app);

    cc=acm.getCustomContext('testHarnessManagerApp');
    if isempty(cc)

        acm.activateApp(customContext);
    else

        ts=st.getToolStrip;
        ts.ActiveTab=cc.DefaultTabName;
    end
end