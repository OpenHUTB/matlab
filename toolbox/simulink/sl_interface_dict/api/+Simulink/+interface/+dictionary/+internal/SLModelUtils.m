classdef SLModelUtils<handle




    methods(Static)
        function showLinkedInterfaceDictionary(slModel)


            import Simulink.interface.dictionary.internal.DictionaryClosureUtils



            [isLinked,dictFilePath]=DictionaryClosureUtils.isModelLinkedToInterfaceDict(slModel);
            assert(isLinked,'model %s is not linked to an interface dictionary.',getfullname(slModel));


            dictFilePath=dictFilePath{1};
            dictAPI=Simulink.interface.dictionary.open(dictFilePath);
            dictAPI.show();
            guiObj=sl.interface.dictionaryApp.StudioApp.findStudioAppForDict(dictAPI.filepath());
            guiObj.changePlatform('AUTOSARClassic');
        end
    end
end
