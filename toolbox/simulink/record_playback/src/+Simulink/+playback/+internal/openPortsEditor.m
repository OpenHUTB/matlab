
function openPortsEditor(blkHandle)
    studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(blkHandle));
    if~isempty(studioApp)
        editor=studioApp.getActiveEditor;
        portEditor=RPStudio.internal.PortsEditor(blkHandle,editor);
        portEditor.show();
    end
end
