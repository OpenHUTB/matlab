function unregisterEnginePlugins(this)
    eng=Simulink.sdi.Instance.engine();
    if eng.IsMetaDataUpdateRegistered
        slInternal(...
        'unRegisterSimMetadataCallback',...
        'SDI_CALLBACK');
    end

    if~isempty(this.Listeners)
        delete(this.Listeners);
    end
end