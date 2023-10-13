classdef M3IModelSLModelContext < autosar.api.internal.M3IModelContext

    properties ( Access = private )
        ModelName;
    end

    methods
        function this = M3IModelSLModelContext( modelName )
            this.ModelName = bdroot( modelName );
        end

        function isSubComponent = isContextMappedToSubComponent( this )
            isSubComponent = Simulink.CodeMapping.isMappedToAutosarSubComponent( this.ModelName );
        end

        function isAdaptive = isContextMappedToAdaptiveApplication( this )
            isAdaptive = autosarcore.ModelUtils.isMappedToAdaptiveApplication( this.ModelName );
        end

        function isComposition = isContextMappedToComposition( this )
            isComposition = autosarcore.ModelUtils.isMappedToComposition( this.ModelName );
        end

        function isArchModel = isContextArchitectureModel( this )
            isArchModel = Simulink.internal.isArchitectureModel( this.ModelName, 'AUTOSARArchitecture' );
        end

        function m3iModel = getM3IModel( this, namedargs )
            arguments
                this
                namedargs.ForXmlOptions = false;
            end

            m3iModel = autosar.api.Utils.m3iModel( this.ModelName );

            if ( namedargs.ForXmlOptions && ~this.isContextArchitectureModel(  ) )

                if autosar.dictionary.Utils.hasReferencedModels( m3iModel )
                    m3iModel = autosar.dictionary.Utils.getUniqueReferencedModel( m3iModel );
                end
            end
        end

        function [ hasMapping, mapping, m3iMappedComp ] = hasCompMapping( this )
            hasMapping = false;
            mapping = [  ];
            m3iMappedComp = [  ];
            if autosarcore.ModelUtils.isMapped( this.ModelName )
                mapping = autosarcore.ModelUtils.modelMapping( this.ModelName );
                hasMapping = ~isempty( mapping.MappedTo );
                if nargout > 2
                    m3iMappedComp = autosarcore.ModelUtils.m3iMappedComponent( this.ModelName );
                end
            end
        end

        function length = getMaxShortNameLength( this )
            length = get_param( this.ModelName, 'AutosarMaxShortNameLength' );
        end

        function schemaVer = getAutosarSchemaVersion( this )
            schemaVer = get_param( this.ModelName, 'AutosarSchemaVersion' );
        end

        function ddName = getDataDictionaryName( this )
            ddName = get_param( this.ModelName, 'DataDictionary' );
        end

        function name = getContextName( this )
            name = this.ModelName;
        end
    end
end



