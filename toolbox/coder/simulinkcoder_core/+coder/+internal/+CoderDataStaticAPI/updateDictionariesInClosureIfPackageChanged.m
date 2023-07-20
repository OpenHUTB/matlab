function updateDictionariesInClosureIfPackageChanged(sourceDD)




    cdefSourcesNeedingUpdate=coder.internal.CoderDataStaticAPI.checkIfLegacyPackagesInClosureChanged(sourceDD);


    for i=1:length(cdefSourcesNeedingUpdate)
        currentCdef=cdefSourcesNeedingUpdate{i};
        cdict=coder.Dictionary(currentCdef);
        if strcmp(cdict.sourceDictionary.context,'model')
            mdlHandle=hex2num(cdict.sourceDictionary.ID);

            myStage=sldiagviewer.createStage(DAStudio.message('SimulinkCoderApp:codeperspective:DiagnosticViewerStageName'),...
            'ModelName',get_param(mdlHandle,'Name'));
            sldiagviewer.reportInfo(DAStudio.message('SimulinkCoderApp:data:PackageDefinitionsChanged',get_param(mdlHandle,'Name')));
            delete(myStage);
        elseif strcmp(cdict.sourceDictionary.context,'dictionary')
            sldiagviewer.reportInfo(DAStudio.message('SimulinkCoderApp:data:PackageDefinitionsChanged',cdict.sourceDictionary.ID));
        end
        isRefreshPackageList=false;
        coder.dictionary.internal.refreshPackage(cdict,isRefreshPackageList)
    end

end


