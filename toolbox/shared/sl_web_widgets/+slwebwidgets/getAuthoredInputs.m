function authoredInputs=getAuthoredInputs(signalID)





    authoredInputs.dataString='';
    authoredInputs.timeString='';
    authoredInputs.dataTypeString='';

    repoUtil=starepository.RepositoryUtility;

    inputsFromRepo=getMetaDataByName(repoUtil,signalID,'AuthoringInputs');



    if~isempty(inputsFromRepo)
        authoredInputs.dataString=inputsFromRepo.dataString;
        authoredInputs.timeString=inputsFromRepo.timeString;

        if isfield(inputsFromRepo,'dataTypeString')
            authoredInputs.dataTypeString=inputsFromRepo.dataTypeString;
        else



            meta=getMetaDataStructure(repoUtil,signalID);

            if strcmp(meta.DataType,'logical')
                authoredInputs.dataTypeString='boolean';
            else
                authoredInputs.dataTypeString=meta.DataType;
            end

        end
    end

end

