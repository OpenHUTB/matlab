function settingsDebugCB(cbinfo)
    model=cbinfo.studio.App.blockDiagramHandle;

    if~isempty(model)
        cs=getActiveConfigSet(model);
        configset.showParameterGroup(cs,'Diagnostics');
    end
end
