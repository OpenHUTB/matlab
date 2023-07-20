function ret=getDefault()


mlock

    persistent defaultImporter
    if isempty(defaultImporter)
        defaultImporter=Simulink.sdi.internal.import.WorkspaceParser;
    end

    ret=defaultImporter;
end
