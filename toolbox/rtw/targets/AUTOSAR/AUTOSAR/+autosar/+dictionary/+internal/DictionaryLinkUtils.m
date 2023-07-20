classdef DictionaryLinkUtils<handle






    methods(Static)
        function[isLinkedToDict,dictFiles]=isModelLinkedToAUTOSARInterfaceDictionary(modelName)


            [isLinkedToDict,dictFiles]=Simulink.interface.dictionary.internal.DictionaryClosureUtils.isModelLinkedToInterfaceDict(...
            modelName,WithPlatformMapping='AUTOSARClassic');
        end
    end
end


