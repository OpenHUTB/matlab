function toggleSampleApp3CB(userdata,cbinfo)

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

    customContext=testapps.SampleApp3Context();

    st=cbinfo.studio;
    sa=st.App;
    acm=sa.getAppContextManager;

    if show

        licenses=testapps.SampleApp3Context.licensesToCheckout();
        for ii=1:length(licenses)
            lic=licenses{ii};
            if strcmpi(lic,'matlab')||strcmpi(lic,'simulink')
                license('checkout',lic);
            else
                dig.tests.checkoutTestLicense(lic);
            end
        end
        acm.activateApp(customContext);
    else
        acm.deactivateApp(app.name);
    end
end