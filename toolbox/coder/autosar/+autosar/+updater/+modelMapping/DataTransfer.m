classdef DataTransfer<autosar.updater.ModelMappingMatcher




    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=DataTransfer(modelName)
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
            for ii=1:length(modelMapping.DataTransfers)
                this.UnmatchedElements.set(modelMapping.DataTransfers(ii).SignalName);
            end
        end

        function[isMapped,signalName]=isMapped(this,varargin)

            isMapped=false;
            signalName='';

            m3iIrvData=varargin{1};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            for ii=1:length(modelMapping.DataTransfers)
                dataTransfer=modelMapping.DataTransfers(ii);
                if strcmp(m3iIrvData.Name,dataTransfer.MappedTo.IrvName)
                    isMapped=true;
                    signalName=dataTransfer.SignalName;
                    this.UnmatchedElements.remove(signalName);
                    break
                end
            end
        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'DataTransfer','NoMark',changeLogger);
        end
    end
end
