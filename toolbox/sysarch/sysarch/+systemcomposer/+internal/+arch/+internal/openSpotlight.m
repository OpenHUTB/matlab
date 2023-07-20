function openSpotlight(appName,compToSpotlightUUID)



    app=systemcomposer.internal.arch.load(appName);
    compArchModel=app.getCompositionArchitectureModel;
    compToSpotlight=compArchModel.findElement(compToSpotlightUUID);

    app.openSpotlight('',compToSpotlight,'StudioDefault');

end

