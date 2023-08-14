classdef VfbViewBuilder<autosar.timing.mm2sl.BaseViewBuilder




    properties(SetAccess=immutable,GetAccess=private)
        M3iComposition;
    end

    methods
        function this=VfbViewBuilder(modelName,updateMode,m3iComposition)
            assert(autosar.api.Utils.isMappedToComposition(modelName),...
            '%s is not mapped to a composition',modelName);

            assert(Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture'),...
            '%s is not an architecture model',modelName);

            this@autosar.timing.mm2sl.BaseViewBuilder(modelName,updateMode);

            this.M3iComposition=m3iComposition;
        end

        function m3iVfbTiming=findM3iTiming(this)
            m3iVfbTimings=this.findM3iVfbTimingsForModel(this.ModelName);
            if isempty(m3iVfbTimings)
                m3iVfbTiming='';
                return
            end

            m3iVfbTiming=this.findM3iVfbTimingAmongstTimingsForM3iComp(m3iVfbTimings,this.M3iComposition);
        end

        function assignOrderIndex(this,m3iEOCExecutableEntityRefs)


            swcInstanceNames={};
            rootSlEntryPointFunctions={};
            for i=1:length(m3iEOCExecutableEntityRefs)

                swcInstanceName=m3iEOCExecutableEntityRefs{i}.Component.Name;
                swcModel=m3iEOCExecutableEntityRefs{i}.Component.Type.Name;
                runnable=m3iEOCExecutableEntityRefs{i}.Executable.Name;


                rootSlEntryPointFunction=...
                autosar.api.internal.MappingFinder.getSlEntryPointFunctionForRunnable(swcModel,runnable);

                swcInstanceNames{end+1}=swcInstanceName;%#ok<AGROW>
                rootSlEntryPointFunctions{end+1}=rootSlEntryPointFunction;%#ok<AGROW>
            end


            executionList=autosar.timing.ScheduleEditorArch(this.ModelName);
            executionList.setExecutionOrder(rootSlEntryPointFunctions,swcInstanceNames);
        end
    end

    methods(Static)
        function hasEOC=hasExecutionOrderConstraints(modelName,m3iComposition)

            import autosar.timing.mm2sl.VfbViewBuilder

            hasEOC=false;
            m3iVfbTimings=VfbViewBuilder.findM3iVfbTimingsForModel(modelName);
            if isempty(m3iVfbTimings)
                return
            end

            m3iVfbTiming=VfbViewBuilder.findM3iVfbTimingAmongstTimingsForM3iComp(m3iVfbTimings,m3iComposition);
            if isempty(m3iVfbTiming)
                return
            end

            m3iEOC=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
            m3iVfbTiming,...
            Simulink.metamodel.arplatform.timingExtension.ExecutionOrderConstraint.MetaClass,...
            true);
            if~isempty(m3iEOC)
                hasEOC=true;
            end
        end

        function m3iVfbTiming=findM3iVfbTimingAmongstTimingsForM3iComp(m3iVfbTimings,m3iComponent)
            m3iVfbTiming=[];
            for i=1:size(m3iVfbTimings)
                if m3iVfbTimings.at(i).Component==m3iComponent
                    m3iVfbTiming=m3iVfbTimings.at(i);
                    return
                end
            end
        end
    end

    methods(Access=private,Static)
        function m3iVfbTimings=findM3iVfbTimingsForModel(modelName)



            m3iVfbTimings='';
            archModel=autosar.arch.Composition.create(modelName);
            components=archModel.find('Component','AllLevels',true);
            linkedComponents=components(cellfun(@(x)~isempty(x),{components.ReferenceName}));
            if isempty(linkedComponents)
                return
            end
            m3iModel=autosar.api.Utils.m3iModel(linkedComponents(1).ReferenceName);


            m3iVfbTimings=autosar.mm.Model.findObjectByMetaClass(...
            m3iModel,...
            Simulink.metamodel.arplatform.timingExtension.VfbTiming.MetaClass);
        end
    end
end


