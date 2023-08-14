classdef FlattenCompositionBuilder<handle









    properties(Access=private)
        M3IComposition;
        MaxShortNameLength;
        SystemPathToExport;
    end

    methods
        function this=FlattenCompositionBuilder(m3iComposition,maxShortNameLength,systemPathToExport)
            this.M3IComposition=m3iComposition;
            this.MaxShortNameLength=maxShortNameLength;
            this.SystemPathToExport=systemPathToExport;
        end

        function build(this)


            if~this.hasUniqueSWCPrototypeNames()
                DAStudio.error('autosarstandard:exporter:ECUExtractNotUniqueNames',this.SystemPathToExport);
            end



            while~autosar.system.sl2mm.FlattenCompositionBuilder.isFlat(this.M3IComposition)
                this.walkCompositionCompPrototypes();
            end
        end
    end

    methods(Static)
        function res=isFlat(m3iComposition)

            import autosar.system.sl2mm.FlattenCompositionBuilder
            m3iCompositionCompPrototypes=m3i.filter(@(component)...
            FlattenCompositionBuilder.isaCompositionComponent(component.Type),m3iComposition.Components);
            res=isempty(m3iCompositionCompPrototypes);
        end
    end

    methods(Access=private)
        function res=hasUniqueSWCPrototypeNames(this)
            m3iCompPrototypes=autosar.composition.Utils.findCompPrototypesInComposition(this.M3IComposition);
            m3iAtomicCompPrototypes=m3iCompPrototypes(cellfun(@(component)this.isaAtomicComponent(component),{m3iCompPrototypes.Type}));
            res=length(m3iAtomicCompPrototypes)==length(unique({m3iAtomicCompPrototypes.Name},'stable'));
        end

        function walkCompositionCompPrototypes(this)

            m3iCompositionCompPrototypes=m3i.filter(@(component)...
            this.isaCompositionComponent(component.Type),this.M3IComposition.Components);
            m3i.foreach(@(compositionCompPrototype)this.expandM3IComposition(compositionCompPrototype,this.M3IComposition),m3iCompositionCompPrototypes);
        end

        function expandM3IComposition(this,m3iSrcCompositionCompPrototype,m3iDstComposition)






            srcM3IComposition=m3iSrcCompositionCompPrototype.Type;

            this.moveCompPrototypes(srcM3IComposition,m3iDstComposition);

            this.moveAndFuseConnectors(srcM3IComposition,m3iDstComposition);

            m3iSrcCompositionCompPrototype.destroy();
        end

        function moveAndFuseConnectors(this,m3iSrcComposition,m3iDstComposition)


            garbageCollectorSeq=M3I.SequenceOfClassObject.makeUnique(m3iSrcComposition.rootModel);

            m3iConnectorSeq=M3I.SequenceOfClassObject.make(m3iSrcComposition.rootModel);
            m3iConnectorSeq.addAll(m3iSrcComposition.Connectors);
            for i=1:m3iConnectorSeq.size()
                connector=m3iConnectorSeq.at(i);
                if this.isaAssemblyConnector(connector)
                    this.moveAssemblyConnector(connector,m3iDstComposition);
                elseif this.isaDelegationConnector(connector)


                    m3iOuterPort=connector.OuterPort;
                    m3iOuterConnectors=m3i.filter(@(outerConnector)...
                    this.isAssemblyConnectedToPort(outerConnector,m3iOuterPort)||this.isDelegationConnectedToPort(outerConnector,m3iOuterPort),...
                    m3iDstComposition.Connectors);
                    m3i.foreach(@(m3iOuterConnector)this.fuseConnectors(connector,m3iOuterConnector),m3iOuterConnectors);


                    m3i.foreach(@(m3iOuterConnector)garbageCollectorSeq.append(m3iOuterConnector),m3iOuterConnectors);
                end
            end

            m3i.foreach(@(outerConnector)outerConnector.destroy(),garbageCollectorSeq);
        end

        function fuseConnectors(this,m3iDelegationConnector,m3iOuterConnector)


            if isa(m3iOuterConnector,'Simulink.metamodel.arplatform.composition.AssemblyConnector')
                if m3iOuterConnector.Provider.ProvidedPort==m3iDelegationConnector.OuterPort
                    newM3ICompositionPPortInstanceRef=this.createM3ICompositionPPortInstanceRef(m3iDelegationConnector.InnerPort);
                    newM3ICompositionRPortInstanceRef=this.createM3ICompositionRPortInstanceRef(m3iOuterConnector.Requester);
                elseif m3iOuterConnector.Requester.RequiredPort==m3iDelegationConnector.OuterPort
                    newM3ICompositionPPortInstanceRef=this.createM3ICompositionPPortInstanceRef(m3iOuterConnector.Provider);
                    newM3ICompositionRPortInstanceRef=this.createM3ICompositionRPortInstanceRef(m3iDelegationConnector.InnerPort);
                end
                this.createM3IAssemblyConnector(this.M3IComposition,newM3ICompositionPPortInstanceRef,newM3ICompositionRPortInstanceRef,this.MaxShortNameLength);
            elseif isa(m3iOuterConnector,'Simulink.metamodel.arplatform.composition.DelegationConnector')
                if isa(m3iDelegationConnector.InnerPort,'Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef')
                    newM3ICompositionPortInstanceRef=this.createM3ICompositionPPortInstanceRef(m3iDelegationConnector.InnerPort);
                else
                    newM3ICompositionPortInstanceRef=this.createM3ICompositionRPortInstanceRef(m3iDelegationConnector.InnerPort);
                end
                this.createM3IDelegationConnector(this.M3IComposition,m3iOuterConnector.OuterPort,newM3ICompositionPortInstanceRef,this.MaxShortNameLength);
            end
        end
    end

    methods(Access=private,Static)
        function moveCompPrototypes(m3iSrcComposition,m3iDstComposition)
            m3iComponentPrototypeSeq=M3I.SequenceOfClassObject.make(m3iSrcComposition.rootModel);
            m3iComponentPrototypeSeq.addAll(m3iSrcComposition.Components);
            m3i.foreach(@(componentPrototype)m3iDstComposition.Components.append(componentPrototype),m3iComponentPrototypeSeq);
        end

        function moveAssemblyConnector(connector,m3iDstComposition)
            m3iDstComposition.Connectors.append(connector);
        end

        function res=isAssemblyConnectedToPort(m3iConnector,m3iPort)
            res=isa(m3iConnector,'Simulink.metamodel.arplatform.composition.AssemblyConnector')&&...
            (m3iConnector.Provider.ProvidedPort==m3iPort||...
            m3iConnector.Requester.RequiredPort==m3iPort);
        end

        function res=isDelegationConnectedToPort(m3iConnector,m3iPort)
            res=isa(m3iConnector,'Simulink.metamodel.arplatform.composition.DelegationConnector')&&...
            m3iConnector.InnerPort.Port==m3iPort;
        end

        function createM3IDelegationConnector(m3iComposition,outerPort,m3iCompositionPortInstanceRef,maxShortNameLength)
            m3iDelegationConnector=Simulink.metamodel.arplatform.composition.DelegationConnector(m3iComposition.rootModel);
            m3iDelegationConnector.OuterPort=outerPort;
            m3iDelegationConnector.InnerPort=m3iCompositionPortInstanceRef;
            m3iDelegationConnector.Name=autosar.system.sl2mm.FlattenCompositionBuilder.calculateDelegationConnectorName(m3iDelegationConnector,maxShortNameLength);
            m3iComposition.Connectors.append(m3iDelegationConnector);
        end

        function createM3IAssemblyConnector(m3iComposition,m3iCompositionPPortInstanceRef,m3iCompositionRPortInstanceRef,maxShortNameLength)
            m3iAssemblyConnector=Simulink.metamodel.arplatform.composition.AssemblyConnector(m3iComposition.rootModel);
            m3iAssemblyConnector.Provider=m3iCompositionPPortInstanceRef;
            m3iAssemblyConnector.Requester=m3iCompositionRPortInstanceRef;
            m3iAssemblyConnector.Name=autosar.system.sl2mm.FlattenCompositionBuilder.calculateAssemblyConnectorName(m3iAssemblyConnector,maxShortNameLength);
            m3iComposition.Connectors.append(m3iAssemblyConnector);
        end

        function newM3ICompositionPPortInstanceRef=createM3ICompositionPPortInstanceRef(m3iCompositionPPortInstanceRef)
            newM3ICompositionPPortInstanceRef=Simulink.metamodel.arplatform.instance.CompositionPPortInstanceRef(m3iCompositionPPortInstanceRef.rootModel);
            newM3ICompositionPPortInstanceRef.ProvidedPort=m3iCompositionPPortInstanceRef.ProvidedPort;
            newM3ICompositionPPortInstanceRef.ComponentPrototype=m3iCompositionPPortInstanceRef.ComponentPrototype;
        end

        function newM3ICompositionPPortInstanceRef=createM3ICompositionRPortInstanceRef(m3iCompositionPPortInstanceRef)
            newM3ICompositionPPortInstanceRef=Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef(m3iCompositionPPortInstanceRef.rootModel);
            newM3ICompositionPPortInstanceRef.RequiredPort=m3iCompositionPPortInstanceRef.RequiredPort;
            newM3ICompositionPPortInstanceRef.ComponentPrototype=m3iCompositionPPortInstanceRef.ComponentPrototype;
        end

        function connectorName=calculateAssemblyConnectorName(m3iAssemblyConnector,maxShortNameLength)


            providerCompProtoName=m3iAssemblyConnector.Provider.ComponentPrototype.Name;
            providerPortQName=autosar.api.Utils.getQualifiedName(m3iAssemblyConnector.Provider.ProvidedPort);
            requesterCompProtoName=m3iAssemblyConnector.Requester.ComponentPrototype.Name;
            requesterPortQName=autosar.api.Utils.getQualifiedName(m3iAssemblyConnector.Requester.RequiredPort);
            assemblyConnector=autosar.composition.sl2mm.private.AssemblyConnector(...
            providerCompProtoName,providerPortQName,requesterCompProtoName,requesterPortQName);
            connectorName=assemblyConnector.calculateConnectorName(maxShortNameLength);
        end

        function connectorName=calculateDelegationConnectorName(m3iDelegationConnector,maxShortNameLength)


            innerCompProtoName=m3iDelegationConnector.InnerPort.ComponentPrototype.Name;
            if isa(m3iDelegationConnector.InnerPort,'Simulink.metamodel.arplatform.instance.CompositionRPortInstanceRef')
                innerM3IPort=m3iDelegationConnector.InnerPort.RequiredPort;
                isInBound=1;
            else
                innerM3IPort=m3iDelegationConnector.InnerPort.ProvidedPort;
                isInBound=0;
            end
            innerPortQName=autosar.api.Utils.getQualifiedName(innerM3IPort);
            outerPortName=m3iDelegationConnector.OuterPort.Name;
            delegationConnector=autosar.composition.sl2mm.private.DelegationConnector(...
            innerCompProtoName,innerPortQName,...
            outerPortName,isInBound,innerM3IPort);
            connectorName=delegationConnector.calculateConnectorName(maxShortNameLength);
        end

        function res=isaCompositionComponent(m3iComponent)
            res=isa(m3iComponent,'Simulink.metamodel.arplatform.composition.CompositionComponent');
        end

        function res=isaAtomicComponent(m3iComponent)
            res=isa(m3iComponent,'Simulink.metamodel.arplatform.component.AtomicComponent');
        end

        function res=isaAssemblyConnector(m3iConnector)
            res=isa(m3iConnector,'Simulink.metamodel.arplatform.composition.AssemblyConnector');
        end

        function res=isaDelegationConnector(m3iConnector)
            res=isa(m3iConnector,'Simulink.metamodel.arplatform.composition.DelegationConnector');
        end
    end
end


