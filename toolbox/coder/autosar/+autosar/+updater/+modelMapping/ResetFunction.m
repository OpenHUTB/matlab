classdef ResetFunction<autosar.updater.ModelMappingMatcher






    methods
        function this=ResetFunction(modelName)
            this=this@autosar.updater.ModelMappingMatcher(modelName);
        end

        function markAsUnmatched(~)

        end

        function[isMapped,blockPath]=isMapped(this,varargin)

            isMapped=false;
            blockPath=[];

            m3iRunnable=varargin{1};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            for ii=1:length(modelMapping.ResetFunctions)
                if strcmp(modelMapping.ResetFunctions(ii).MappedTo.Runnable,m3iRunnable.Name)
                    isMapped=true;

                    resetFcnBlocks=autosar.utils.InitResetTermFcnBlock.findResetFunctionBlocksWithName(this.ModelName,modelMapping.ResetFunctions(ii).Name);
                    if((length(resetFcnBlocks)==1)&&strcmp(get_param(resetFcnBlocks{1},'Parent'),this.ModelName))
                        blockPath=resetFcnBlocks{1};
                    end
                    return;
                end
            end
        end

        function logDeletions(~,~,~)

        end
    end
end


