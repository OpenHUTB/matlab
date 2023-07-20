function mdlsToClose=loadAllModels(data)










    mdlsToClose={};

    try
        loadedModels=getfullname(Simulink.allBlockDiagrams('model'));
        if ischar(loadedModels)
            loadedModels={loadedModels};
        end

        modelName=data.ModelInformation.Name;
        if~bdIsLoaded(modelName)
            Sldv.load_system(modelName);
            mdlsToClose=[mdlsToClose,{modelName}];
        end





        refMdls=find_mdlrefs(modelName,...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'KeepModelsLoaded',true,...
        'ReturnTopModelAsLastElement',false);

        preLoadedRefMdls=contains(refMdls,loadedModels);
        mdlsToClose=[mdlsToClose,refMdls(~preLoadedRefMdls)];

        if(slfeature('ObserverSLDV')==1)
            modelH=get_param(modelName,'Handle');







            [obsModelNames,~,errMsg,errID]=Simulink.observer.internal.loadObserverModelsForBD(modelH);
            if~isempty(errMsg)&&~strcmp('Sldv:Observer:CtxMdlAlreadyOpenInAnotherContext',errID)

                error(errMsg);
            end


            preLoadedObsMdls=contains(obsModelNames,loadedModels);
            mdlsToClose=[mdlsToClose,obsModelNames(~preLoadedObsMdls)];
        end
    catch MEx



        warning(MEx.message);
    end
end
