classdef VfbViewBuilder<autosar.timing.sl2mm.BaseViewBuilder




    properties(Transient,SetAccess=private)
        M3IVfbTiming;
        M3IComposition;
    end

    methods
        function this=VfbViewBuilder(modelName,m3iComposition)
            assert(autosar.api.Utils.isMappedToComposition(modelName),...
            '%s is not mapped to a composition',modelName);

            assert(Simulink.internal.isArchitectureModel(modelName,'AUTOSARArchitecture'),...
            '%s is not an architecture model',modelName);

            this@autosar.timing.sl2mm.BaseViewBuilder(modelName);
            this.M3IComposition=m3iComposition;
        end

        function m3iVfbTiming=findM3iTiming(this)

            m3iVfbTiming='';
            m3iVfbTimings=autosar.mm.Model.findObjectByMetaClass(...
            this.M3iModel,...
            Simulink.metamodel.arplatform.timingExtension.VfbTiming.MetaClass);
            for i=1:size(m3iVfbTimings)
                if m3iVfbTimings.at(i).Component==this.M3IComposition
                    m3iVfbTiming=m3iVfbTimings.at(i);
                    this.M3IVfbTiming=m3iVfbTiming;
                    return
                end
            end
        end

        function m3iVfbTiming=createM3iTiming(this)

            pkgTiming=this.getOrAddTimingPackage();


            m3iVfbTiming=Simulink.metamodel.arplatform.timingExtension.VfbTiming(this.M3iModel);
            this.M3IVfbTiming=m3iVfbTiming;
            m3iVfbTiming.Component=this.M3IComposition;


            defaultName=[this.M3IComposition.Name,'_timing'];
            vfbTimingName=this.createUniqueTimingName(defaultName);
            m3iVfbTiming.Name=vfbTimingName;


            pkgTiming.packagedElement.append(m3iVfbTiming);
        end

        function updateOrCreateM3iExecutableEntityRefAttributes(this,m3iExecutableEntityRef,m3iRunnable,swcName)

            simulinkHandle=Simulink.findBlocks(this.ModelName,'Name',swcName);
            m3iComponentPrototype=this.findM3ICompPrototypeForCompBlock(simulinkHandle);
            if m3iExecutableEntityRef.Component~=m3iComponentPrototype
                m3iExecutableEntityRef.Component=m3iComponentPrototype;
            end

            if~strcmp(m3iExecutableEntityRef.Name,m3iRunnable.Name)
                m3iExecutableEntityRef.Name=[m3iComponentPrototype.Name,'_',m3iRunnable.Name];
            end

            if m3iExecutableEntityRef.Executable~=m3iRunnable
                m3iExecutableEntityRef.Executable=m3iRunnable;
            end
        end

        function m3iComponentPrototype=findM3ICompPrototypeForCompBlock(this,simulinkHandle)
            compPrototypeName=get_param(simulinkHandle,'Name');
            m3iCompPrototypes=autosar.composition.Utils.findCompPrototypesInComposition(this.M3IComposition);
            m3iComponentPrototype=m3iCompPrototypes(cellfun(@(component)strcmp(component,{compPrototypeName}),{m3iCompPrototypes.Name}));
            assert(m3iComponentPrototype.isvalid,'Did not find component prototype for %s',compPrototypeName);
        end

        function m3iRunnable=findM3iRunnableForRootSlEntryPointFunction(this,swcName,rootSlEntryPointFunction)

            swcBlock=Simulink.findBlocks(this.ModelName,'Name',swcName);
            swcModelName=get_param(swcBlock,'ModelName');
            m3iRunnable=autosar.timing.sl2mm.SwcViewBuilder.findM3iRunnableForRootSlEntryPointFunctionOfModel(swcModelName,rootSlEntryPointFunction);
        end

        function[rootSlEntryPointFunctions,swcNames]=getSortedListOfRootSlEntryPointFunctions(this)

            executionList=autosar.timing.ScheduleEditorArch(this.ModelName);
            [rootSlEntryPointFunctions,swcNames]=executionList.getExecutionOrder();
        end

        function removeM3iCrossReferences(this)





            if isempty(this.M3IVfbTiming)
                return
            end

            m3iTimingReqs=this.M3IVfbTiming.TimingRequirement;
            if~m3iTimingReqs.isEmpty()
                assert(m3iTimingReqs.size()==1,'Unexpected number of Execution order constraints');
                orderedElements=m3iTimingReqs.at(1).OrderedElement;
                for i=size(orderedElements):-1:1
                    orderedElements.at(i).destroy();
                end
            end
        end
    end

    methods(Access=protected)
        function m3iEOConstraint=getOrAddM3iEOConstraintForTimingModel(this,m3iTiming)
            m3iEOConstraint=getOrAddM3iEOConstraintForTimingModel@autosar.timing.sl2mm.BaseViewBuilder(this,m3iTiming);
            m3iEOConstraint.BaseComposition=this.M3IComposition;
        end
    end
end


