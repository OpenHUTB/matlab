classdef TerminateFunction<autosar.updater.ModelMappingMatcher






    methods
        function this=TerminateFunction(modelName)
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

            for ii=1:length(modelMapping.TerminateFunctions)
                if strcmp(modelMapping.TerminateFunctions(ii).MappedTo.Runnable,m3iRunnable.Name)
                    isMapped=true;

                    termFcnBlocks=autosar.utils.InitResetTermFcnBlock.findTermFunctionBlocks(this.ModelName);
                    if((length(termFcnBlocks)==1)&&strcmp(get_param(termFcnBlocks{1},'Parent'),this.ModelName))
                        blockPath=termFcnBlocks{1};
                    end
                    return;
                end
            end
        end

        function logDeletions(~,~,~)

        end
    end
end


