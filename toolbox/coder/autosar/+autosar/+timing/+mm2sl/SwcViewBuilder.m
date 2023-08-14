classdef SwcViewBuilder<autosar.timing.mm2sl.BaseViewBuilder




    properties(Transient,SetAccess=private)
        M3iSwcTiming;
    end

    methods
        function this=SwcViewBuilder(modelName,updateMode,m3iSwcTiming)
            assert(autosar.api.Utils.isMappedToComponent(modelName),...
            '%s is not mapped to a component',modelName);

            this@autosar.timing.mm2sl.BaseViewBuilder(modelName,updateMode);
            this.M3iSwcTiming=m3iSwcTiming;
        end
    end

    methods
        function m3iSwcTiming=findM3iTiming(this)
            m3iSwcTiming=this.M3iSwcTiming;
        end

        function assignOrderIndex(this,m3iEOCExecutableEntityRefs)


            slEntryPointFunctions={};
            for i=1:length(m3iEOCExecutableEntityRefs)
                runnable=m3iEOCExecutableEntityRefs{i}.Executable.Name;
                slEntryPointFunctions{end+1}=...
                autosar.api.internal.MappingFinder.getSlEntryPointFunctionForRunnable(this.ModelName,runnable);%#ok<AGROW>
            end

            executionList=autosar.timing.ScheduleEditorComponent(this.ModelName);
            executionList.setExecutionOrder(slEntryPointFunctions);
        end
    end

    methods(Access=public,Static)
        function hasEOC=hasExecutionOrderConstraints(m3iSwcTiming)

            hasEOC=false;
            if isempty(m3iSwcTiming)
                return
            end

            m3iEOC=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
            m3iSwcTiming,...
            Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint.MetaClass,...
            true);
            if~isempty(m3iEOC)
                hasEOC=true;
            end
        end
    end
end


