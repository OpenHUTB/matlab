classdef InitializeFunction<autosar.updater.ModelMappingMatcher






    methods
        function this=InitializeFunction(modelName)
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

            for ii=1:length(modelMapping.InitializeFunctions)
                if strcmp(modelMapping.InitializeFunctions(ii).MappedTo.Runnable,m3iRunnable.Name)
                    isMapped=true;

                    initFcnBlocks=autosar.utils.InitResetTermFcnBlock.findInitFunctionBlocks(this.ModelName);
                    if((length(initFcnBlocks)==1)&&strcmp(get_param(initFcnBlocks{1},'Parent'),this.ModelName))
                        blockPath=initFcnBlocks{1};
                    end
                    return;
                end
            end
        end

        function logDeletions(~,~,~)

        end
    end
end


