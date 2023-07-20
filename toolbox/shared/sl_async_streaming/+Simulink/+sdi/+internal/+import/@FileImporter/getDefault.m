function ret=getDefault()


mlock

    persistent defaultImporter
    if isempty(defaultImporter)
        defaultImporter=Simulink.sdi.internal.import.FileImporter;
    end

    ret=defaultImporter;
end
