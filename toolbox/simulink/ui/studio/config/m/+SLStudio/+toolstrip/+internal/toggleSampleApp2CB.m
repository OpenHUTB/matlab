function toggleSampleApp2CB(userdata,cbinfo)

    if isempty(cbinfo.EventData)
        show=true;
    else
        show=cbinfo.EventData;
    end

    c=dig.Configuration.get();
    app=c.getApp(userdata);

    if isempty(app)
        return;
    end

    customContext=testapps.SampleApp2Context();

    st=cbinfo.studio;
    sa=st.App;
    acm=sa.getAppContextManager;

    if show

        dig.tests.checkoutTestLicense('Test_License_1');
        dig.tests.checkoutTestLicense('Test_License_2');
        acm.activateApp(customContext);
    else
        acm.deactivateApp(app.name);
    end
end