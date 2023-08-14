function loadModel(modelPath)




    [~,modelName]=fileparts(modelPath);
    if bdIsLoaded(modelName)


        if~xmlcomp.internal.compareFilenames(modelPath,get_param(modelName,'FileName'))
            slxmlcomp.internal.error('reverseannotation:WrongFileLoaded',modelName);
        end
        unlockLibrary(modelName);
    else
        load_system(modelPath);
        if(excludeFromSimulinkRecentList(modelPath))
            slhistory.exclude.set(get_param(modelName,'Handle'));
        end

        unlockLibrary(modelName);
    end

end


function unlockLibrary(modelName)

    if~strcmp(get_param(modelName,'blockdiagramtype'),'library')
        return
    end



    slxmlcomp.internal.testharness.closeAll(modelName);



    set_param(modelName,'Lock','off');
end

function exclude=excludeFromSimulinkRecentList(modelPath)
    strPath=string(modelPath);
    exclude=strPath.startsWith(tempdir);
end
