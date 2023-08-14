classdef(Abstract)PlatformMappingSyncer<handle





    properties(SetAccess=private)
        DictImpl sl.interface.dict.InterfaceDictionary
DictionaryFileName
        SLDDConn Simulink.dd.Connection
    end

    methods(Abstract)
        dictionaryMapping=createPlatformMapping(this);
        syncInterface(this,ddEntry);
        syncDataType(this,ddEntry);
        getDictionaryMapping(this);
    end

    methods
        function this=PlatformMappingSyncer(dictImpl)
            this.DictImpl=dictImpl;
            dictFilePath=this.DictImpl.getDictionaryFilePath;
            [~,f,e]=fileparts(dictFilePath);
            this.DictionaryFileName=[f,e];
            this.SLDDConn=Simulink.dd.open(dictFilePath);
        end
    end

    methods(Static)
        function syncer=createSyncer(dictImpl,mappingKind)
            switch(mappingKind)
            case sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic
                syncer=autosar.dictionary.internal.ARClassicPlatformMappingSyncer(dictImpl);
            case sl.interface.dict.mapping.PlatformMappingKind.FunctionPlatform

                assert(false,'Should not be trying to create a mapping syncer for function platforms yet');
            otherwise
                assert(false,'Only AUTOSAR Classic is supported for platform mapping');
            end
        end
    end
end


