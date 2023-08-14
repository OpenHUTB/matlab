function url=makeConnectorUrl(controller,debug)





    baseUrl=dependencies.internal.viewer.makeBaseUrl(controller,Debug=debug);

    connector.ensureServiceOn();
    url=connector.getUrl(baseUrl);

end
