classdef DictionaryRegistry < handle







    properties ( Access = private )
        SlddFileSpecToDictObjMap
    end

    methods ( Access = private )

        function obj = DictionaryRegistry(  )
            obj.SlddFileSpecToDictObjMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
        end
    end

    methods ( Static )
        function registry = instance(  )
            persistent singleton
            if isempty( singleton )
                registry = Simulink.interface.dictionary.internal.DictionaryRegistry;
                singleton = registry;
            else
                registry = singleton;
            end
        end
    end

    methods ( Static )
        function dictObj = getOrOpenInterfaceDictionary( slddFile )
            registry = Simulink.interface.dictionary.internal.DictionaryRegistry.instance(  );
            slddFileSpec = Simulink.interface.dictionary.internal.Utils.getResolvedFilePath( slddFile );
            if isempty( slddFileSpec )
                DAStudio.error( 'SLDD:sldd:DictionaryNotFound', slddFile );
            end
            if registry.hasEntry( slddFileSpec )
                dictObj = registry.getEntry( slddFileSpec );
                if ~isvalid( dictObj.DictImpl )

                    registry.removeEntry( slddFileSpec );
                    dictObj = Simulink.interface.Dictionary( DictFileName = slddFileSpec );
                    registry.addEntry( slddFileSpec, dictObj );
                end
            else
                dictObj = Simulink.interface.Dictionary( DictFileName = slddFileSpec );
                registry.addEntry( slddFileSpec, dictObj );
            end
        end

        function handleDictShutDown( slddFileSpec )
            registry = Simulink.interface.dictionary.internal.DictionaryRegistry.instance(  );
            registry.removeEntry( slddFileSpec );
        end
    end

    methods ( Access = private )
        function addEntry( this, slddFileSpec, dictObj )
            arguments
                this
                slddFileSpec{ mustBeFile }
                dictObj( 1, 1 )Simulink.interface.Dictionary
            end
            this.SlddFileSpecToDictObjMap( slddFileSpec ) = dictObj;
        end

        function removeEntry( this, slddFileSpec )
            if this.hasEntry( slddFileSpec )
                this.SlddFileSpecToDictObjMap.remove( slddFileSpec );
            end
        end

        function tf = hasEntry( this, slddFileSpec )
            tf = this.SlddFileSpecToDictObjMap.isKey( slddFileSpec );
        end

        function dictObj = getEntry( this, slddFileSpec )
            dictObj = this.SlddFileSpecToDictObjMap( slddFileSpec );
        end
    end

    methods

        function entries = getEntries( this )
            entries = this.SlddFileSpecToDictObjMap.keys;
        end
    end
end


