classdef FcnCallInport<autosar.updater.ModelMappingMatcher






    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=FcnCallInport(modelName)
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
            for ii=1:length(modelMapping.FcnCallInports)
                this.UnmatchedElements.set(modelMapping.FcnCallInports(ii).Block);
            end
        end

        function[isMapped,blockPath]=isMapped(this,varargin)

            isMapped=false;
            blockPath=[];

            m3iRunnable=varargin{1};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            for ii=1:length(modelMapping.FcnCallInports)
                if strcmp(modelMapping.FcnCallInports(ii).MappedTo.Runnable,m3iRunnable.Name)
                    isMapped=true;
                    blockPath=modelMapping.FcnCallInports(ii).Block;
                    this.UnmatchedElements.remove(blockPath);
                    return;
                end
            end
        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'Runnable','MarkBlockForDelete',changeLogger);
        end
    end
end
