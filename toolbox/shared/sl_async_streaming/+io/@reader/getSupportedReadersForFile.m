function ret=getSupportedReadersForFile(fname)



    fImporter=Simulink.sdi.internal.import.FileImporter.getDefault();
    ret=fImporter.getSupportedImportersForFile(fname);
end
