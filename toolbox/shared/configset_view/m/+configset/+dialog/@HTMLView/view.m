function view(obj)




    switch configset.feature('ConfigSetWeb')
    case 1
        obj.launchQtDialog();
    case 2
        obj.launchCEFWindow();
    end

    if~obj.isWebPageReady
        waitfor(obj,'isWebPageReady');
    end


