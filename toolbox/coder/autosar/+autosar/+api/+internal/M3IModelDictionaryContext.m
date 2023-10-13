classdef M3IModelDictionaryContext < autosar.api.internal.M3IModelContext

    properties ( Access = private )
        DictionaryFullName;
    end

    properties ( Hidden, Constant )
        MaxShortNameLength = 128;
    end

    methods ( Access = public )
        function this = M3IModelDictionaryContext( dictFullName )
            if sl.interface.dict.api.isInterfaceDictionary( dictFullName )
                dictAPI = Simulink.interface.dictionary.open( dictFullName );
                this.DictionaryFullName = dictAPI.filepath(  );




                if ~autosar.dictionary.Utils.isSharedAutosarDictionary( this.DictionaryFullName )
                    autosar.validation.AutosarUtils.reportErrorWithFixit(  ...
                        'autosarstandard:dictionary:InterfaceDictNoAUTOSARClassicMapping',  ...
                        autosar.utils.File.dropPath( dictFullName ) );
                end
            else
                assert( autosar.dictionary.Utils.isSharedAutosarDictionary( dictFullName ),  ...
                    '%s is not a valid AUTOSAR dictionary.', dictFullName );
                this.DictionaryFullName = dictFullName;
            end
        end

        function isSubComponent = isContextMappedToSubComponent( this )%#ok<MANU>
            isSubComponent = false;
        end

        function isAdaptive = isContextMappedToAdaptiveApplication( this )%#ok<MANU>
            isAdaptive = false;
        end

        function isComposition = isContextMappedToComposition( this )%#ok<MANU>
            isComposition = false;
        end

        function isArchModel = isContextArchitectureModel( this )%#ok<MANU>
            isArchModel = false;
        end

        function m3iModel = getM3IModel( this, namedargs )
            arguments
                this
                namedargs.ForXmlOptions = false;%#ok<INUSA>
            end

            m3iModel = autosar.dictionary.Utils.getM3IModelForDictionaryFile( this.DictionaryFullName );
        end

        function [ hasMapping, mapping, m3iMappedComp ] = hasCompMapping( this )%#ok<MANU>
            hasMapping = false;
            mapping = [  ];
            m3iMappedComp = [  ];
        end

        function length = getMaxShortNameLength( this )%#ok<MANU>
            length = autosar.api.internal.M3IModelDictionaryContext.MaxShortNameLength;
        end

        function schemaVer = getAutosarSchemaVersion( this )
            m3iModel = this.getM3IModel(  );
            schemaVer = autosar.ui.utils.getAutosarSchemaVersion( m3iModel );
        end

        function ddName = getDataDictionaryName( this )
            [ ~, f, e ] = fileparts( this.DictionaryFullName );
            ddName = [ f, e ];

        end

        function name = getContextName( this )
            name = this.DictionaryFullName;
        end
    end
end



