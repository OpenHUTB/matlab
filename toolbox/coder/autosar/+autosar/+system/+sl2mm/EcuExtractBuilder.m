classdef EcuExtractBuilder<handle





    properties(SetAccess=immutable,GetAccess=private)
        RootModelName;
        SystemPathToExport;
        RootM3IModel;
        M3IComposition;
    end

    methods
        function this=EcuExtractBuilder(rootModelName,m3iComposition,systemPathToExport)
            assert((autosar.composition.Utils.isCompositionBlock(systemPathToExport)||...
            autosar.api.Utils.isMappedToComposition(systemPathToExport)),...
            '%s is not a composition',systemPathToExport);

            this.RootModelName=rootModelName;
            this.SystemPathToExport=systemPathToExport;
            this.RootM3IModel=autosar.api.Utils.m3iModel(rootModelName);
            this.M3IComposition=m3iComposition;
        end

        function build(this)
            if~slfeature('AUTOSAREcuExtract')
                return
            end

            assert(autosar.system.sl2mm.FlattenCompositionBuilder.isFlat(this.M3IComposition));


            pkgSystem=this.getOrAddSystemPackage();

            m3iSystem=this.updateOrCreateM3ISystem(pkgSystem);

            m3iSystemMapping=this.updateOrCreateM3ISystemMapping(m3iSystem);

            m3iSwcToEcuMapping=this.updateOrCreateM3ISwcToEcuMapping(m3iSystemMapping);

            this.updateOrCreateM3IEcuInstance(pkgSystem,m3iSwcToEcuMapping);

            this.addComponentPrototypesToMapping(m3iSwcToEcuMapping);

            this.updateOrCreateM3IRootSwCompositionPrototype(m3iSystem);
        end
    end

    methods(Access=private)
        function pkgSystem=getOrAddSystemPackage(this)

            m3iRoot=this.RootM3IModel.RootPackage.front();
            systemPackage=autosar.mm.util.XmlOptionsAdapter.get(m3iRoot,'SystemPackage');
            if isempty(systemPackage)
                systemPackage=autosar.mm.util.XmlOptionsDefaultPackages.SystemPackage;
                autosar.mm.util.XmlOptionsAdapter.set(m3iRoot,'SystemPackage',systemPackage);
            end

            pkgSystem=autosar.mm.Model.getOrAddARPackage(this.RootM3IModel,systemPackage);
        end

        function m3iEcuInstance=updateOrCreateM3IEcuInstance(this,pkgSystem,m3iSwcToEcuMapping)


            mappedECU=m3iSwcToEcuMapping.EcuInstance;
            if~isempty(mappedECU)
                m3iEcuInstance=autosar.mm.Model.findObjectByMetaClass(...
                this.RootM3IModel,...
                Simulink.metamodel.arplatform.system.EcuInstance.MetaClass);
                for i=1:size(m3iEcuInstance)
                    if m3iEcuInstance.at(i)==mappedECU
                        m3iEcuInstance=m3iEcuInstance.at(i);
                        return
                    end
                end
            end


            m3iEcuInstance=Simulink.metamodel.arplatform.system.EcuInstance(this.RootM3IModel);
            m3iEcuInstance.Name=this.createUniqueName('EcuInstance',pkgSystem);
            pkgSystem.packagedElement.append(m3iEcuInstance);
            m3iSwcToEcuMapping.EcuInstance=m3iEcuInstance;
        end

        function m3iSystem=updateOrCreateM3ISystem(this,pkgSystem)


            m3iSystems=autosar.mm.Model.findObjectByMetaClass(...
            this.RootM3IModel,...
            Simulink.metamodel.arplatform.system.System.MetaClass);
            for i=1:size(m3iSystems)
                if strcmp(m3iSystems.at(i).category,'ECU_EXTRACT')&&...
                    ~isempty(m3iSystems.at(i).RootSoftwareComposition)&&...
                    m3iSystems.at(i).RootSoftwareComposition.SwComposition==this.M3IComposition
                    m3iSystem=m3iSystems.at(i);
                    return
                end
            end


            m3iSystem=Simulink.metamodel.arplatform.system.System(this.RootM3IModel);
            m3iSystem.category="ECU_EXTRACT";
            m3iSystem.Name=this.createUniqueName('EcuExtract',pkgSystem);
            pkgSystem.packagedElement.append(m3iSystem);
        end

        function m3iRootSwCompositionPrototype=updateOrCreateM3IRootSwCompositionPrototype(this,m3iSystem)


            if~isempty(m3iSystem.RootSoftwareComposition)&&...
                m3iSystem.RootSoftwareComposition.SwComposition==this.M3IComposition
                m3iRootSwCompositionPrototype=m3iSystem.RootSoftwareComposition;
                return
            end


            m3iRootSwCompositionPrototype=Simulink.metamodel.arplatform.system.RootSwCompositionPrototype(this.RootM3IModel);
            m3iRootSwCompositionPrototype.SwComposition=this.M3IComposition;
            m3iRootSwCompositionPrototype.Name=this.createUniqueName('RootSwCompositionPrototype',m3iSystem);
            m3iSystem.RootSoftwareComposition=m3iRootSwCompositionPrototype;
        end

        function m3iSystemMapping=updateOrCreateM3ISystemMapping(this,m3iSystem)

            for i=1:size(m3iSystem.Mapping)
                if isa(m3iSystem.Mapping.at(i),'Simulink.metamodel.arplatform.system.SystemMapping')
                    m3iSystemMapping=m3iSystem.Mapping.at(i);
                    return
                end
            end


            m3iSystemMapping=Simulink.metamodel.arplatform.system.SystemMapping(this.RootM3IModel);
            m3iSystemMapping.Name=this.createUniqueName('SystemMapping',m3iSystem);
            m3iSystem.Mapping.append(m3iSystemMapping);
        end

        function m3iSwcToEcuMapping=updateOrCreateM3ISwcToEcuMapping(this,m3iSystemMapping)

            for i=1:size(m3iSystemMapping.SwMapping)
                if isa(m3iSystemMapping.SwMapping.at(i),'Simulink.metamodel.arplatform.system.SwcToEcuMapping')
                    m3iSwcToEcuMapping=m3iSystemMapping.SwMapping.at(i);




                    m3iSwcToEcuMapping.Component.clear();
                    return
                end
            end


            m3iSwcToEcuMapping=Simulink.metamodel.arplatform.system.SwcToEcuMapping(this.RootM3IModel);
            m3iSwcToEcuMapping.Name=this.createUniqueName('SwcToEcuMapping',m3iSystemMapping);
            m3iSystemMapping.SwMapping.append(m3iSwcToEcuMapping);
        end

        function addComponentPrototypesToMapping(this,m3iSwcToEcuMapping)

            for i=1:size(this.M3IComposition.Components)
                m3iSwcToEcuMapping.Component.append(this.M3IComposition.Components.at(i));
            end
        end

        function newName=createUniqueName(this,defaultName,m3iObj)
            qualifiedName=autosar.api.UnnamedElement.getQualifiedName(m3iObj);
            newName=autosar.api.Utils.createUniqueNameInSeq(this.RootModelName,defaultName,qualifiedName);
        end
    end
end


