function doAllPendingLazyImport(this)
    this.safeTransaction(@locDoAllPendingLazyImport);
end

function locDoAllPendingLazyImport()
    Simulink.sdi.internal.import.WorkspaceParser.performLazyImport();
end
