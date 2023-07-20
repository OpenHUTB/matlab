classdef Utils




    methods(Static,Access=public)
        function internalMappingType=getInternalMappingType(mappingType)

            switch mappingType
            case 'SimulinkCoderC'
                internalMappingType='SimulinkCoderCTarget';
            case 'EmbeddedCoderC'
                internalMappingType='CoderDictionary';
            case 'EmbeddedCoderCPP'
                internalMappingType='CppModelMapping';
            otherwise
                assert(false,'Unsupported mapping type');
            end
        end

        function externalMappingType=getExternalMappingType(mappingType)

            switch mappingType
            case 'SimulinkCoderCTarget'
                externalMappingType='SimulinkCoderC';
            case 'CoderDictionary'
                externalMappingType='EmbeddedCoderC';
            case 'CppModelMapping'
                externalMappingType='EmbeddedCoderCPP';
            otherwise
                externalMappingType=mappingType;
            end
        end

        function mappingType=getCurrentMappingType(model)

            mmgr=get_param(model,'MappingManager');
            mappingType=mmgr.getCurrentMapping();
        end

        function externalDepType=getExternalDeploymentType(depType)

            switch depType
            case 'Component'
                externalDepType='Component';
            case 'Subcomponent'
                externalDepType='Subcomponent';
            case 'Unset'
                externalDepType='Automatic';
            otherwise
                assert(false,'Invalid internal deployment type')
            end
        end

        function internalDepType=getInternalDeploymentType(depType)

            switch depType
            case 'Component'
                internalDepType='Component';
            case 'Subcomponent'
                internalDepType='Subcomponent';
            case 'Automatic'
                internalDepType='Unset';
            otherwise
                assert(false,'Invalid external deployment type')
            end
        end

        function depType=getCurrentDeploymentType(model,internalMappingType)

            mapping=coder.mapping.internal.MappingUtils.getModelMapping(...
            model,'',internalMappingType);
            depType=mapping.DeploymentType;
        end

        function out=getDuplicatesOfBEP(blockHandle)

            out=[];
            if codermapping.internal.bep.isMappableBEP(blockHandle)
                out=codermapping.internal.bep.getDuplicatesOfBEP(blockHandle);
            end
        end

        function mappingType=getCurrentExternalMappingType(model)

            internalMappingType=coder.mapping.internal.Utils.getCurrentMappingType(model);
            mappingType=coder.mapping.internal.Utils.getExternalMappingType(internalMappingType);
        end

        function types=getValidMappingTypes()

            types={'EmbeddedCoderC','SimulinkCoderC','EmbeddedCoderCPP'};
        end

        function res=escapeSimulinkName(pathStr)





            if isstring(pathStr)
                pathStr=convertStringsToChars(pathStr);
            end
            pathStr=strrep(pathStr,newline,' ');
            res=strrep(pathStr,'/','//');
        end

    end
end


