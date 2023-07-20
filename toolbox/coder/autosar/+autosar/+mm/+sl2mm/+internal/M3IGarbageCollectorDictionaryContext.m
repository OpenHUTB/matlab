classdef M3IGarbageCollectorDictionaryContext<autosar.mm.sl2mm.internal.M3IGarbageCollectorContext







    properties(Access=private)
        DictionaryFullName;
    end

    methods
        function this=M3IGarbageCollectorDictionaryContext(dictFullName)
            assert(autosar.dictionary.Utils.isSharedAutosarDictionary(dictFullName),...
            '%s is not a valid AUTOSAR dictionary.',dictFullName);
            this.DictionaryFullName=dictFullName;
        end

        function m3iModel=getM3IModel(this)
            m3iModel=autosar.dictionary.Utils.getM3IModelForDictionaryFile(this.DictionaryFullName);
        end

        function cacheRestoreDirtyState(this)%#ok<MANU>

        end
    end
end



