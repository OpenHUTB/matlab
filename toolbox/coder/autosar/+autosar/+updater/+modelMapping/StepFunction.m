classdef StepFunction<autosar.updater.ModelMappingMatcher





    properties(Access=private)
        UnmatchedElements autosar.mm.util.Set
    end

    methods
        function this=StepFunction(modelName)
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

            for ii=1:length(modelMapping.StepFunctions)
                periodStr=Simulink.metamodel.arplatform.getRealStringCompact(...
                modelMapping.StepFunctions(ii).Period);
                this.UnmatchedElements.set(periodStr);
            end
        end

        function[isMapped,periodStr]=isMapped(this,varargin)

            isMapped=false;
            periodStr='';

            m3iRunnable=varargin{1};

            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end
            modelMapping=autosar.api.Utils.modelMapping(this.ModelName);

            for ii=1:length(modelMapping.StepFunctions)
                if strcmp(modelMapping.StepFunctions(ii).MappedTo.Runnable,m3iRunnable.Name)
                    isMapped=true;
                    period=modelMapping.StepFunctions(ii).Period;
                    periodStr=Simulink.metamodel.arplatform.getRealStringCompact(period);
                    this.UnmatchedElements.remove(periodStr);
                    break
                end
            end

        end

        function logDeletions(this,changeLogger,~)
            this.logManualBlkDeletions(this.UnmatchedElements,'Runnable with sample time','MarkForDelete',changeLogger);

        end
    end
end
