function modelToUse=locateSessionModel(modelName,modelOwnerName,modelLastKnownLocation)





    if~isempty(modelOwnerName)

        modelName=modelOwnerName;

    end

    if isempty(modelName)&&isempty(modelLastKnownLocation)
        modelToUse='';
        return;
    end

    if exist(modelLastKnownLocation,'file')

        modelToUse=modelLastKnownLocation;
        return;
    else

        [~,mdlFileName,mdlExt]=fileparts(modelLastKnownLocation);

        fileFoundOnPath=which([modelName,mdlExt]);





        if~isempty(fileFoundOnPath)&&exist(fileFoundOnPath,'file')

            modelToUse=fileFoundOnPath;
            return;
        end


        throw(...
        MException(message('sl_sta_repository:sta_repository:scenarioDataModelNotFound',...
        mdlFileName,mdlFileName,modelLastKnownLocation))...
        );
    end

end

