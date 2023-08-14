function bool=getEnableAddObserverReference(modelName)
    if~startsWith(gcs+"/",modelName+"/")

        bool=false;
    else
        gcsO=get_param(gcs,'Object');
        bool=gcsO.Type=="block_diagram"&&~gcsO.isLibrary;
    end
end
