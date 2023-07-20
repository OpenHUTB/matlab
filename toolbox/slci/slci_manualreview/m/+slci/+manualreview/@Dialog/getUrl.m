


function url=getUrl(obj)

    pm=slci.manualreview.Manager.getInstance;
    debugMode=pm.getDebugMode;
    if debugMode
        url=connector.getUrl(obj.fDebugUrl);
    else
        url=connector.getUrl(obj.fUrl);
    end

    readOnly=~slci.toolstrip.util.checkoutLicense;
    url=[url,'&channel=',obj.fChannel(2:end),'&readOnly=',num2str(readOnly)];