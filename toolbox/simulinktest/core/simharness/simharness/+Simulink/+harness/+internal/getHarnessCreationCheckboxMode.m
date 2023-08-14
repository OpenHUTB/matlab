classdef getHarnessCreationCheckboxMode<int32




    enumeration
        ALLOW_SELECTION(0)
        SAVED_EXTERNALLY(1)
        SAVED_INTERNALLY(2)
    end

    methods(Static)

        function result=saveExtCheckboxMode(modelName)


















            assert(bdIsLoaded(modelName),['Model ',modelName,' not loaded.'])

            [~,~,fileExt]=fileparts(get_param(modelName,'FileName'));
            isMDLfile=strcmpi(fileExt,'.mdl');


            if isMDLfile
                result=Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_EXTERNALLY;
                return
            end

            if Simulink.harness.internal.isSavedIndependently(modelName)


                result=Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_EXTERNALLY;
            elseif~isempty(Simulink.harness.internal.getHarnessList(modelName))

                result=Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_INTERNALLY;
            else

                assert(isempty(Simulink.harness.internal.getHarnessList(modelName)),...
                'Expected no harnesses to be associated')

                hasCodeContexts=false;
                if bdIsLibrary(modelName)
                    codeContexts=Simulink.libcodegen.internal.getAllCodeContexts(modelName);
                    hasCodeContexts=~isempty(codeContexts);
                end

                if hasCodeContexts
                    result=Simulink.harness.internal.getHarnessCreationCheckboxMode.SAVED_INTERNALLY;
                else
                    result=Simulink.harness.internal.getHarnessCreationCheckboxMode.ALLOW_SELECTION;
                end
            end
        end
    end

end




