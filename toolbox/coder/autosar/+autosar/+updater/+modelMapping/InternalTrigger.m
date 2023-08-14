classdef InternalTrigger<autosar.updater.ModelMappingMatcher





    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=InternalTrigger(modelName)
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
            for ii=1:length(modelMapping.FunctionCallers)
                fcnCallerPath=modelMapping.FunctionCallers(ii).Block;
                if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(fcnCallerPath)
                    this.UnmatchedElements.set(fcnCallerPath);
                end
            end
        end

        function[isMapped,blks]=isMapped(this,varargin)

            isMapped=false;
            blks={};

            m3iTrigPoint=varargin{1};
            m3iTriggeringRun=varargin{2};
            triggeringRunPath=varargin{3};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);


            triggeringRunPath=strrep(triggeringRunPath,newline,' ');
            for ii=1:length(modelMapping.FunctionCallers)
                blockMapping=modelMapping.FunctionCallers(ii);


                if strncmp(blockMapping.Block,triggeringRunPath,length(triggeringRunPath))&&...
                    autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(blockMapping.Block)
                    if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlockMapped(...
                        blockMapping.Block,m3iTriggeringRun.symbol,m3iTrigPoint.Name)
                        isMapped=true;
                        blk=blockMapping.Block;
                        blks=[blks,blk];%#ok<AGROW>
                        this.UnmatchedElements.remove(blk);
                    end
                end
            end
        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'Internal Trigger','MarkBlockForDelete',changeLogger);
        end
    end
end
