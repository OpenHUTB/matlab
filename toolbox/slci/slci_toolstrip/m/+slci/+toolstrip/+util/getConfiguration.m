

function conf=getConfiguration(studio)
    src=slci.view.internal.getSource(studio);
    conf=slci.Configuration.loadObjFromFile(src.modelName);
    if isempty(conf)
        conf=slci.Configuration(src.modelName);
    end


    slci.toolstrip.util.saveSLCIConfigurationData(conf,studio);
end