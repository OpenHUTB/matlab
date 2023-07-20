function validateModel(modelName)






    try
        load_system(modelName)

        if~strcmp(get_param(modelName,'BlockDiagramType'),'model')
            hList=Simulink.harness.find(modelName);
            if(isempty(hList))
                error(message('stm:general:TestFileForLibrariesNotSupported',modelName));
            end
        end
    catch

        MException(message('stm:SystemUnderTestView:CannotLoadModel',modelName)).throw
    end
end

