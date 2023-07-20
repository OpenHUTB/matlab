classdef(Abstract)PIMMapping<autosar.updater.ModelMappingMatcher






    properties(Access=protected)
UnmatchedArTypedPIM
UnmatchedStaticMemory
    end

    methods
        function this=PIMMapping(modelName)
            this=this@autosar.updater.ModelMappingMatcher(modelName);

            this.UnmatchedArTypedPIM=containers.Map();
            this.UnmatchedStaticMemory=containers.Map();
        end

        function pimInfo=findMapped(this,type,shortName)
            pimInfo=[];

            if nargin<3
                shortName='';
            end

            if autosar.api.Utils.isMapped(this.ModelName)
                mappingObj=autosar.api.getSimulinkMapping(this.ModelName);
            else
                return;
            end

            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            mappings=this.getPimMappings(modelMapping);
            for mappingIdx=1:length(mappings)
                mmPim=mappings(mappingIdx);

                if strcmp(mmPim.MappedTo.ArDataRole,'Auto')&&...
                    this.supportsLegacyMapping()
                    if this.isLegacyMappingValid(mmPim,shortName,type)
                        slObj=this.requiresSignalObject(mmPim);
                        info=this.generateLegacyPimInfo(mmPim,slObj);
                        pimInfo=[pimInfo,info];%#ok<AGROW>
                        continue;
                    end
                end

                if~strcmp(mmPim.MappedTo.ArDataRole,type)
                    continue;
                end
                arShortName=this.getShortNameFromMapping(mappingObj,mmPim);

                if isempty(arShortName)


                    arShortName=[this.ModelName,'_',mmPim.Name];
                end

                if~isempty(shortName)

                    if~strcmp(arShortName,shortName)
                        continue;
                    end
                end

                slObj=this.requiresSignalObject(mmPim);
                info=this.generatePimInfo(mmPim,slObj);
                pimInfo=[pimInfo,info];%#ok<AGROW>
            end
        end

        function logDeletions(this,changeLogger)
            this.logDeletionsGeneric(changeLogger,this.UnmatchedArTypedPIM);
            this.logDeletionsGeneric(changeLogger,this.UnmatchedStaticMemory);
        end

        function isValid=isLegacyMappingValid(this,mmPim,shortName,type)%#ok<INUSD>

            isValid=false;
        end
    end

    methods(Static)
        function supportsLegacyMapping=supportsLegacyMapping()

            supportsLegacyMapping=false;
        end

        function pimInfo=generateLegacyPimInfo(mmPim,slObj)%#ok<INUSD,STOUT>
            assert(false,'This should be overridden before execution');
        end
    end

    methods(Abstract)
        markAsUnmatched(this)
        [isMapped,varargout]=isMapped(this,varargin)
        updateMapping(this,pimInfo,m3iObj)
        requiresSignalObject=requiresSignalObject(this,mmPim)
    end

    methods(Abstract,Access=protected)
        logDeletionsGeneric(this,changeLogger,pimMap)
    end

    methods(Abstract,Static)
        pimInfo=generatePimInfo(mmPim,slObj)
        modelMappings=getPimMappings(modelMapping)
        arShortName=getShortNameFromMapping(mmPim)
    end
end


