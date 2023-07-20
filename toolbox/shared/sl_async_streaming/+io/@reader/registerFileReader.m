function registerFileReader(this,ext)
    fImporter=Simulink.sdi.internal.import.FileImporter.getDefault();
    fImporter.registerCustomImporter(this,ext);
end
