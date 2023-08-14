classdef ObserverSharedDictionaryDuringBuild<M3I.M3IListener





    properties(SetAccess=immutable,GetAccess=private)
        InterfaceDictFilePath;
    end

    methods

        function this=ObserverSharedDictionaryDuringBuild(dictFilePath)
            this.InterfaceDictFilePath=dictFilePath;
        end

        function observeChanges(this,report)
            if autosar.mm.observer.ObserverSharedDictionaryDuringBuild.needToDirtyAUTOSARPart(report)
                Simulink.AutosarDictionary.ModelRegistry.setAutosarPartDirty(this.InterfaceDictFilePath);
            end
        end
    end

    methods(Static,Access=private)
        function shouldDirty=needToDirtyAUTOSARPart(report)














            shouldDirty=report.getAdded().size()>0;
        end
    end
end


