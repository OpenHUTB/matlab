classdef ObserverSharedDictionary<autosar.mm.observer.Observer





    properties(SetAccess=immutable,GetAccess=private)
        DictionaryFile;
    end

    methods

        function this=ObserverSharedDictionary(dictFile)
            this.DictionaryFile=dictFile;
        end

        function observeChanges(this,report)%#ok<INUSD>
            Simulink.AutosarDictionary.ModelRegistry.setAutosarPartDirty(this.DictionaryFile);
        end
    end
end
