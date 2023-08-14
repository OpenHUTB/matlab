function url=getURL(this,pagePath)

    if isempty(this.Port)
        [hostInfo]=connector.ensureServiceOn;
        this.Port=hostInfo.securePort;
    end
    if~slsvTestingHook('SDITreeTableTestingHook')
        url=connector.getUrl(pagePath);
    else
        url=connector.getUrl([pagePath,'?qeTestingMode=true']);
    end
end
