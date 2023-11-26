function startUI()
    connector.ensureServiceOn;
    releasemanagerInstance=multivercosim.internal.releasemanager.getInstance();
    releasemanagerInstance.createReleaseManagerHTML();
    releasemanagerInstance.view();
end