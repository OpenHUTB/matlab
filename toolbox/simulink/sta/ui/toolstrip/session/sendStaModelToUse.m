function sendStaModelToUse(modelName,modelOwner,modelOwnerFullPath,appInstanceID)




    if isempty(modelOwner)

        [~,modelNameOnly,~]=fileparts(modelName);


        if~isempty(modelName)&&~bdIsLoaded(modelNameOnly)


            load_system(modelName);

        end

    else

        [~,modelOwnerNameOnly,~]=fileparts(modelOwner);
        [~,modelNameOnly,~]=fileparts(modelName);

        if~isempty(modelOwner)&&~bdIsLoaded(modelOwnerNameOnly)


            load_system(modelOwner);
        end

        if~bdIsLoaded(modelNameOnly)

            Simulink.harness.load(modelOwnerFullPath,modelNameOnly);
        end

    end
    modelStructToSend.modelName=modelNameOnly;
    modelStructToSend.owningModelName=modelOwner;
    modelStructToSend.owningModelFullPath=modelOwnerFullPath;


    fullChannel=sprintf('/sta%s/%s',appInstanceID,'sta/modeltouse');
    message.publish(fullChannel,modelStructToSend);


    fullChannel=sprintf('/sta%s/%s',appInstanceID,'sta/updateModel');
    message.publish(fullChannel,modelNameOnly);

