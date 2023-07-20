function add_property_listeners(hProxy,hCore,name,refreshDialog)


    if isempty(hProxy.propProxyListeners)
        hProxy.propProxyListeners=containers.Map;
    end
    if isempty(hCore.propCoreListeners)
        hCore.propCoreListeners=containers.Map;
    end
    if isempty(hProxy.propRefreshDialogListeners)
        hProxy.propRefreshDialogListeners=containers.Map;
    end


    coreChanged=addlistener(hCore,name,'PostSet',@hProxy.cb_corePropChanged);
    hCore.propCoreListeners(name)=coreChanged;


    prop=find(hProxy.classhandle.properties,'name',name);
    proxyChanged=handle.listener(hProxy,prop,'PropertyPostSet',@hCore.cb_proxyPropChanged);
    hProxy.propProxyListeners(name)=proxyChanged;

    if refreshDialog
        refreshListener=handle.listener(hProxy,prop,'PropertyPostSet',@hProxy.cb_refreshDialog);
        hProxy.propRefreshDialogListeners(name)=refreshListener;
    end
end

