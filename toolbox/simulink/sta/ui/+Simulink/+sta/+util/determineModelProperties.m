function[modelName,owningModel,owningFileFullPath]=determineModelProperties(modelNameToInit)







    modelName=modelNameToInit;
    owningModel='';
    owningFileFullPath='';
    if~isempty(modelNameToInit)&&bdIsLoaded(modelNameToInit)


        isHarnessStr=get_param(modelNameToInit,'IsHarness');

        if strcmp(isHarnessStr,'on')

            owningFileName=get_param(modelNameToInit,'OwnerFileName');

            [~,owningModel,~]=fileparts(owningFileName);

            harnessInfo=Simulink.harness.internal.getHarnessInfoForHarnessBD(modelNameToInit);
            owningFileFullPath=harnessInfo.ownerFullPath;
        end



    end

