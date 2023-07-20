classdef RateTransition<autosar.updater.ModelMappingMatcher




    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=RateTransition(modelName)
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

            if~isempty(modelMapping.FcnCallInports)

                return;
            end

            for ii=1:length(modelMapping.RateTransition)
                this.UnmatchedElements.set(modelMapping.RateTransition(ii).Block);
            end
        end

        function[isMapped,blockPath]=isMapped(this,varargin)

            isMapped=false;
            blockPath='';

            m3iIrvData=varargin{1};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            for ii=1:length(modelMapping.RateTransition)
                rtb=modelMapping.RateTransition(ii);
                if strcmp(m3iIrvData.Name,rtb.MappedTo.IrvName)
                    isMapped=true;
                    blockPath=rtb.Block;
                    this.UnmatchedElements.remove(blockPath);
                    break
                end
            end
        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'DataTransfer','NoMark',changeLogger);
        end
    end
end
