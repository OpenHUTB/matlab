classdef ModelScopedParameter<autosar.updater.ModelMappingMatcher






    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=ModelScopedParameter(modelName)
            this=this@autosar.updater.ModelMappingMatcher(modelName);

            this.UnmatchedElements=autosar.mm.util.Set(...
            'InitCapacity',40,...
            'KeyType','char',...
            'HashFcn',@(x)x);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            if autosar.api.Utils.isMappedToAdaptiveApplication(this.ModelName)


                return;
            end

            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);
            for ii=1:length(modelMapping.ModelScopedParameters)
                this.UnmatchedElements.set(modelMapping.ModelScopedParameters(ii).Parameter);
            end
        end

        function isMapped=isMapped(this,varargin)

            isMapped=false;
            paramName=varargin{1};
            if this.UnmatchedElements.isKey(paramName)
                this.UnmatchedElements.remove(paramName);
                isMapped=true;
            end
        end

        function logDeletions(this,changeLogger,~)
            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            paramNames=this.UnmatchedElements.getKeys();
            for paramIdx=1:numel(paramNames)
                paramName=paramNames{paramIdx};
                currentMapping=slMapping.getParameter(paramName);
                if~strcmp(currentMapping,'Auto')
                    slMapping.mapParameter(paramName,'Auto');
                    changeLogger.logModification('Automatic','Mapping',...
                    sprintf('parameter "%s" in model workspace',paramName),...
                    '',currentMapping,'Auto');
                end
            end
        end
    end
end
