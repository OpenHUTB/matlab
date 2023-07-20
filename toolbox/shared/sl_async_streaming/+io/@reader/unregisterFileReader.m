function unregisterFileReader(this,ext)
    fImporter=Simulink.sdi.internal.import.FileImporter.getDefault();
    fImporter.unregisterCustomImporter(this,ext);
end
