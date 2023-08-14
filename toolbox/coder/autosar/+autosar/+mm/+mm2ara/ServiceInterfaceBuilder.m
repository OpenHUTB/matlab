classdef ServiceInterfaceBuilder<autosar.mm.mm2ara.ARABuilder













    properties
        ARABuilder;
        InterfaceQNameToM3iInt;
        PerInterfaceQNameToM3iInt;
        PortEventMap;
        PortMethodMap;
        PortDataElementMap;
    end

    methods(Access=public)

        function this=ServiceInterfaceBuilder(ARAGenerator,m3iComponent,modelName)
            this=this@autosar.mm.mm2ara.ARABuilder(ARAGenerator,m3iComponent);
            this.InterfaceQNameToM3iInt=containers.Map;
            this.PerInterfaceQNameToM3iInt=containers.Map;

            this.PortEventMap=containers.Map;
            this.PortMethodMap=containers.Map;
            this.PortDataElementMap=containers.Map;


            mdlMap=Simulink.CodeMapping.get(modelName,'AutosarTargetCPP');
            this.fillPortToEventMapFromCodeMapping(mdlMap);
            this.fillPortToMethodMapFromFunctionPorts(modelName);

            this.fillPortToDataElementMapFromCodeMapping(mdlMap);

            this.registerBinds();
        end

        function build(this)
            this.applySeq('mmVisit',this.M3iASWC.Port);
        end
    end
    methods(Access=private)

        function registerBinds(this)



            this.bind('Simulink.metamodel.arplatform.port.Port',...
            @mmwalkPorts,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.PortInterface',...
            @mmwalkInterface,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.FlowData',...
            @mmwalkEvent,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.Operation',...
            @mmwalkMethod,'mmVisit');
        end


        function ret=mmwalkPorts(this,m3iPort)


            ret=[];
            this.apply('mmVisit',m3iPort.Interface,m3iPort);
        end

        function ret=mmwalkInterface(this,m3iIntf,m3iPort)


            ret=[];
            qname=m3iIntf.qualifiedName;
            if isa(m3iIntf,'Simulink.metamodel.arplatform.interface.PersistencyKeyValueInterface')
                if~this.PortDataElementMap.isKey(m3iPort.Name)
                    return;
                end
                if~this.PerInterfaceQNameToM3iInt.isKey(qname)
                    this.PerInterfaceQNameToM3iInt(qname)=struct('Interface',m3iIntf,'Ports',{{m3iPort}});
                else
                    vals=this.PerInterfaceQNameToM3iInt(qname);
                    if~any(strcmp(cellfun(@(x)x.Name,vals.Ports,'UniformOutput',false),m3iPort.Name))
                        vals.Ports{end+1}=m3iPort;
                        this.PerInterfaceQNameToM3iInt(qname)=vals;
                    end
                end
                return;
            end

            if isa(m3iIntf,'Simulink.metamodel.arplatform.interface.ServiceInterface')
                this.applySeq('mmVisit',m3iIntf.Events);
                this.applySeq('mmVisit',m3iIntf.Methods);
            end


            if~this.InterfaceQNameToM3iInt.isKey(qname)
                this.InterfaceQNameToM3iInt(qname)=struct('Interface',m3iIntf,'Ports',{{m3iPort}});
                tempVal=this.InterfaceQNameToM3iInt(qname);
                tempVal.SkeletonEvents={};
                tempVal.ProxyEvents={};
                tempVal.SkeletonMethods={};
                tempVal.ProxyMethods={};
                this.InterfaceQNameToM3iInt(qname)=tempVal;
                this.addEventToTypeBasedEventsList(m3iPort,m3iIntf);
                this.addMethodToTypeBasedMethodsList(m3iPort,m3iIntf);
            else
                vals=this.InterfaceQNameToM3iInt(qname);
                if~any(strcmp(cellfun(@(x)x.Name,vals.Ports,'UniformOutput',false),m3iPort.Name))
                    vals.Ports{end+1}=m3iPort;
                    this.InterfaceQNameToM3iInt(qname)=vals;
                    this.addEventToTypeBasedEventsList(m3iPort,m3iIntf);
                    this.addMethodToTypeBasedMethodsList(m3iPort,m3iIntf);
                end
            end
        end

        function ret=mmwalkEvent(this,m3iEvent)


            ret=[];
            typeBuilder=this.ARAGenerator.TypeBuilder;
            if~isempty(m3iEvent.Type)
                typeBuilder.addReferencedType(m3iEvent.Type,m3iEvent.containerM3I);
            end
        end

        function ret=mmwalkMethod(this,m3iMethod)


            ret=[];
            typeBuilder=this.ARAGenerator.TypeBuilder;

            for ii=1:m3iMethod.Arguments.size()
                curArg=m3iMethod.Arguments.at(ii);
                if~isempty(curArg.Type)
                    typeBuilder.addReferencedType(curArg.Type,m3iMethod.containerM3I);
                end
            end
        end

        function safeFillMapFromSeqOfMappedTo(~,map,seq,keyExtractLambda,valExtractLambda)


            for ii=1:numel(seq)
                mapping=seq(ii).MappedTo;
                key=keyExtractLambda(mapping);
                val=valExtractLambda(mapping);
                if~map.isKey(key)
                    map(key)={val};
                else
                    tempSlot=map(key);
                    tempSlot{end+1}=val;%#ok<AGROW>
                    map(key)=tempSlot;
                end
            end
        end

        function fillPortToEventMapFromCodeMapping(this,mdlMap)



            this.safeFillMapFromSeqOfMappedTo(this.PortEventMap,mdlMap.Inports,...
            (@(x)x.Port),(@(x)x.Event));


            this.safeFillMapFromSeqOfMappedTo(this.PortEventMap,mdlMap.Outports,...
            (@(x)x.Port),(@(x)x.Event));
        end

        function fillPortToMethodMapFromFunctionPorts(this,modelName)




            csPorts=[...
            autosar.simulink.functionPorts.Utils.findClientPorts(modelName);...
            autosar.simulink.functionPorts.Utils.findServerPorts(modelName)];

            portNames=get_param(csPorts,'PortName');
            methodNames=get_param(csPorts,'Element');

            for ii=1:length(csPorts)
                key=portNames{ii};
                val=methodNames{ii};
                if~this.PortMethodMap.isKey(key)
                    this.PortMethodMap(key)={val};
                else
                    tempSlot=this.PortMethodMap(key);
                    tempSlot{end+1}=val;%#ok<AGROW>
                    this.PortMethodMap(key)=tempSlot;
                end
            end
        end

        function fillPortToDataElementMapFromCodeMapping(this,mdlMap)


            map=this.PortDataElementMap;
            dsMapping=mdlMap.DataStores;

            for ii=1:numel(dsMapping)
                mappedTo=dsMapping(ii).MappedTo;
                if strcmp(mappedTo.ArDataRole,'Persistency')
                    key=mappedTo.getPerInstancePropertyValue('Port');
                    val=mappedTo.getPerInstancePropertyValue('DataElement');
                    if~map.isKey(key)
                        map(key)={val};
                    else
                        tempSlot=map(key);
                        tempSlot{end+1}=val;%#ok<AGROW>
                        map(key)=tempSlot;
                    end
                end
            end
        end

        function addEventToTypeBasedEventsList(this,m3iPort,m3iIntf)


            if~this.PortEventMap.isKey(m3iPort.Name)
                return;
            end

            qname=m3iIntf.qualifiedName;
            eventList=this.PortEventMap(m3iPort.Name);
            if~isempty(eventList)
                for ii=1:m3iIntf.Events.size()
                    evt=m3iIntf.Events.at(ii);

                    if any(strcmp(evt.Name,eventList))
                        tempVal=this.InterfaceQNameToM3iInt(qname);
                        if isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                            tempVal.SkeletonEvents{end+1}=evt;
                        else
                            tempVal.ProxyEvents{end+1}=evt;
                        end
                        this.InterfaceQNameToM3iInt(qname)=tempVal;
                    end
                end

                tempVal=this.InterfaceQNameToM3iInt(qname);
                if~isempty(tempVal.ProxyEvents)
                    proxyShortNames=cellfun(@(evt)evt.Name,tempVal.ProxyEvents,'UniformOutput',false);
                    [~,idx]=unique(proxyShortNames);
                    tempVal.ProxyEvents=tempVal.ProxyEvents(idx);
                end


                if~isempty(tempVal.SkeletonEvents)
                    skeletonShortNames=cellfun(@(evt)evt.Name,tempVal.SkeletonEvents,'UniformOutput',false);
                    [~,idx]=unique(skeletonShortNames);
                    tempVal.SkeletonEvents=tempVal.SkeletonEvents(idx);
                end

                this.InterfaceQNameToM3iInt(qname)=tempVal;
            end
        end

        function addMethodToTypeBasedMethodsList(this,m3iPort,m3iIntf)


            if~this.PortMethodMap.isKey(m3iPort.Name)
                return;
            end

            qname=m3iIntf.qualifiedName;
            methodList=this.PortMethodMap(m3iPort.Name);
            if~isempty(methodList)
                for ii=1:m3iIntf.Methods.size()
                    mthd=m3iIntf.Methods.at(ii);

                    if any(strcmp(mthd.Name,methodList))
                        tempVal=this.InterfaceQNameToM3iInt(qname);
                        if isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')
                            tempVal.SkeletonMethods{end+1}=mthd;
                        else
                            tempVal.ProxyMethods{end+1}=mthd;
                        end
                        this.InterfaceQNameToM3iInt(qname)=tempVal;
                    end
                end

                tempVal=this.InterfaceQNameToM3iInt(qname);
                if~isempty(tempVal.ProxyMethods)
                    proxyShortNames=cellfun(@(evt)evt.Name,tempVal.ProxyMethods,'UniformOutput',false);
                    [~,idx]=unique(proxyShortNames);
                    tempVal.ProxyMethods=tempVal.ProxyMethods(idx);
                end


                if~isempty(tempVal.SkeletonMethods)
                    skeletonShortNames=cellfun(@(evt)evt.Name,tempVal.SkeletonMethods,'UniformOutput',false);
                    [~,idx]=unique(skeletonShortNames);
                    tempVal.SkeletonMethods=tempVal.SkeletonMethods(idx);
                end

                this.InterfaceQNameToM3iInt(qname)=tempVal;
            end
        end

    end
end



