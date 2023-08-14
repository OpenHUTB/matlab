classdef SwcViewBuilder<autosar.timing.sl2mm.BaseViewBuilder




    methods
        function this=SwcViewBuilder(modelName)
            assert(autosar.api.Utils.isMappedToComponent(modelName),...
            '%s is not mapped to a component',modelName);

            this@autosar.timing.sl2mm.BaseViewBuilder(modelName);
        end

        function m3iSwcTiming=findM3iTiming(this)

            m3iComponent=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iSwcTiming=autosar.timing.Utils.findM3iTimingForM3iComponent(this.M3iModel,m3iComponent);
        end

        function m3iSwcTiming=createM3iTiming(this)

            pkgTiming=this.getOrAddTimingPackage();


            m3iComponent=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iBehavior=m3iComponent.Behavior;
            m3iSwcTiming=Simulink.metamodel.arplatform.timingExtension.SwcTiming(this.M3iModel);
            m3iSwcTiming.Behavior=m3iBehavior;


            defaultName=[m3iComponent.Name,'_timing'];
            swcTimingName=this.createUniqueTimingName(defaultName);
            m3iSwcTiming.Name=swcTimingName;


            pkgTiming.packagedElement.append(m3iSwcTiming);
        end

        function updateOrCreateM3iExecutableEntityRefAttributes(~,m3iExecutableEntityRef,m3iRunnable,~)

            if~strcmp(m3iExecutableEntityRef.Name,m3iRunnable.Name)
                m3iExecutableEntityRef.Name=m3iRunnable.Name;
            end

            if m3iExecutableEntityRef.Executable~=m3iRunnable
                m3iExecutableEntityRef.Executable=m3iRunnable;
            end
        end

        function m3iRunnable=findM3iRunnableForRootSlEntryPointFunction(this,~,rootSlEntryPointFunction)
            m3iRunnable=this.findM3iRunnableForRootSlEntryPointFunctionOfModel(this.ModelName,rootSlEntryPointFunction);
        end

        function[rootSlEntryPointFunctions,swcNames]=getSortedListOfRootSlEntryPointFunctions(this)

            executionList=autosar.timing.ScheduleEditorComponent(this.ModelName);
            rootSlEntryPointFunctions=executionList.getExecutionOrder();
            swcNames=repmat(string(this.ModelName),size(rootSlEntryPointFunctions));
        end
    end

    methods(Access=public,Static)
        function m3iRunnable=findM3iRunnableForRootSlEntryPointFunctionOfModel(modelName,rootSlEntryPointFunction)

            m3iRunnable='';
            mapping=autosar.api.getSimulinkMapping(modelName);
            try
                ARRunnableName=mapping.getFunction(rootSlEntryPointFunction);
            catch
                slIdentifier=autosar.api.internal.MappingFinder.getSlIdentifierForSlEntryPointFunction(rootSlEntryPointFunction,'SimulinkFunction');
                block=Simulink.findBlocks(modelName,'Name',slIdentifier,'BlockType','ModelReference');
                if~isempty(block)


                    MSLDiagnostic('autosarstandard:exporter:UnableToExportExecutionOrderConstraints').reportAsWarning;
                    return
                end

                assert(false,'Unable to retrieve runnable for entry-point function %s',rootSlEntryPointFunction);
            end


            m3iComponent=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iBehavior=m3iComponent.Behavior;
            m3iRunnable=autosar.mm.Model.findChildByName(m3iBehavior,ARRunnableName);
        end
    end
end


