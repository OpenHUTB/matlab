function toggleSampleAppCB(userdata,cbinfo)

    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end

    appInfo=strsplit(userdata,',');
    c=dig.Configuration.get();
    app=c.getApp(appInfo{1});

    if isempty(app)
        return;
    end

    if numel(appInfo)>1
        contextName=['testapps.',appInfo{2}];
        customContext=feval(contextName);
    else
        customContext=testapps.SampleAppContext();
    end

    st=cbinfo.studio;
    sa=st.App;
    acm=sa.getAppContextManager;

    if show
        acm.activateApp(customContext);
    else
        acm.deactivateApp(app.name);
    end
end