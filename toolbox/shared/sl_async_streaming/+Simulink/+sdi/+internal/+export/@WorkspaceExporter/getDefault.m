function ret=getDefault()


mlock

    persistent defaultExporter
    if isempty(defaultExporter)
        defaultExporter=Simulink.sdi.internal.export.WorkspaceExporter;
    end

    ret=defaultExporter;
end
