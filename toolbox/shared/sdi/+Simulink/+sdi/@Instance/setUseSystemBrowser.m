function setUseSystemBrowser(useSystemBrowserParam)
    useSystemBrowserParam=logical(useSystemBrowserParam);
    useSystemBrowser=Simulink.sdi.getUseSystemBrowser;
    if useSystemBrowser~=useSystemBrowserParam
        isOpen=Simulink.sdi.Instance.isSDIRunning();
        Simulink.sdi.Instance.close();
        Simulink.sdi.Instance.getSetGUI([]);
        Simulink.sdi.setUseSystemBrowser(useSystemBrowserParam);
        if isOpen
            Simulink.sdi.Instance.open();
        end
    end
end
