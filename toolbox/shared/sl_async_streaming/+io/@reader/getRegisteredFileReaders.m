function ret=getRegisteredFileReaders()



    fImporter=Simulink.sdi.internal.import.FileImporter.getDefault();
    ret=fImporter.getRegisteredFileImporters();
end
