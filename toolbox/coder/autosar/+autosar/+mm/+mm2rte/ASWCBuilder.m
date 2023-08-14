classdef ASWCBuilder<autosar.mm.mm2rte.RTEBuilder





    properties(Access='private')
        WalkedParameterData;
    end

    methods(Access='public')
        function this=ASWCBuilder(rteGenerator,m3iComponent)
            this=this@autosar.mm.mm2rte.RTEBuilder(rteGenerator,m3iComponent);
            this.WalkedParameterData=[];
            this.registerBinds();
        end

        function RTEData=build(this)
            this.apply('mmVisit',this.M3iASWC);
            RTEData=this.RTEData;
        end
    end

    methods(Access='private')
        function registerBinds(this)
            this.bind('Simulink.metamodel.arplatform.component.AtomicComponent',@mmWalkApplicationComponent,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.ApplicationComponentBehavior',@mmWalkApplicationComponentBehavior,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.ModeDeclarationGroupElement',@mmWalkModeDeclarationGroupElement,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.FlowData',@mmWalkFlowData,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.Operation',@mmWalkOperation,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.IrvAccess',@mmWalkIrvAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.IrvData',@mmWalkIrvData,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.Runnable',@mmWalkRunnable,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.OperationBlockingAccess',@mmWalkOperationBlockingAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.OperationNonBlockingAccess',@mmWalkOperationBlockingAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.FlowDataAccess',@mmWalkFlowDataAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.ModeAccess',@mmWalkModeAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.ModeSwitch',@mmWalkModeAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.instance.OperationPortInstanceRef',@mmWalkOperationPortInstanceRef,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.InternalTrigger',@mmWalkInternalTriggerPoint,'mmVisit');


            this.bind('Simulink.metamodel.arplatform.behavior.PerInstanceMemory',@mmWalkPIM,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.interface.VariableData',@mmWalkArTypedPIMOrStaticMemory,'mmVisit');


            this.bind('Simulink.metamodel.arplatform.interface.ParameterData',@mmWalkParameterData,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.PortParameterAccess',@mmWalkPortParameterAccess,'mmVisit');
            this.bind('Simulink.metamodel.arplatform.behavior.ComponentParameterAccess',@mmWalkComponentParameterAccess,'mmVisit');


            this.bind('Simulink.metamodel.arplatform.behavior.ExclusiveArea',@mmWalkExclusiveArea,'mmVisit');


            this.bind('Simulink.metamodel.arplatform.behavior.IncludedDataTypeSet',@mmWalkIncludedDataTypeSets,'mmVisit');
        end

        function ret=mmWalkApplicationComponent(this,m3iComp)
            ret=[];

            assert(m3iComp.Behavior.isvalid);
            this.apply('mmVisit',m3iComp.Behavior);
        end

        function ret=mmWalkApplicationComponentBehavior(this,m3iApplicationComponentBehavior)
            ret=[];

            this.applySeq('mmVisit',m3iApplicationComponentBehavior.Runnables);


            this.applySeq('mmVisit',m3iApplicationComponentBehavior.PIM);
            this.applySeq('mmVisit',m3iApplicationComponentBehavior.ArTypedPIM,'ArTypedPIM');
            this.applySeq('mmVisit',m3iApplicationComponentBehavior.StaticMemory,'StaticMemory');


            this.applySeq('mmVisit',m3iApplicationComponentBehavior.Parameters);


            this.applySeq('mmVisit',m3iApplicationComponentBehavior.exclusiveArea);


            this.applySeq('mmVisit',m3iApplicationComponentBehavior.IncludedDataTypeSets);
        end

        function ret=mmWalkRunnable(this,m3iRunnable)

            ret=[];
            isServerRunnable=false;
            serverOpIRef=[];

            for ii=1:m3iRunnable.Events.size
                event=m3iRunnable.Events.at(ii);
                if isa(event,'Simulink.metamodel.arplatform.behavior.OperationInvokedEvent')
                    isServerRunnable=true;
                    serverOpIRef=event.instanceRef;
                    break;
                end
            end
            runnableSymbol=m3iRunnable.symbol;
            swAddrMethod=m3iRunnable.SwAddrMethod;
            if~isempty(swAddrMethod)&&swAddrMethod.isvalid()
                swAddrMethodName=swAddrMethod.Name;
            else
                swAddrMethodName='CODE';
            end
            if isServerRunnable
                if~isempty(serverOpIRef)&&serverOpIRef.isvalid()
                    this.apply('mmVisit',...
                    serverOpIRef.Operations,...
                    serverOpIRef.Port,...
                    isServerRunnable,...
                    runnableSymbol);
                end
            else
                dataItem=autosar.mm.mm2rte.RTEDataItemRunnable(runnableSymbol,swAddrMethodName);
                this.RTEData.insertItem(dataItem);
            end


            runnableName=m3iRunnable.Name;
            this.applySeq('mmVisit',m3iRunnable.dataAccess,runnableName);


            isWrite=false;
            this.applySeq('mmVisit',m3iRunnable.irvRead,runnableName,isWrite);
            isWrite=true;
            this.applySeq('mmVisit',m3iRunnable.irvWrite,runnableName,isWrite);


            isServer=false;
            this.applySeq('mmVisit',m3iRunnable.operationBlockingCall,isServer);
            this.applySeq('mmVisit',m3iRunnable.OperationNonBlockingCall,isServer);


            this.applySeq('mmVisit',m3iRunnable.InternalTriggeringPoint);


            this.applySeq('mmVisit',m3iRunnable.ModeAccessPoint);


            this.applySeq('mmVisit',m3iRunnable.ModeSwitchPoint);


            this.applySeq('mmVisit',m3iRunnable.portParamRead);
            this.applySeq('mmVisit',m3iRunnable.compParamRead);
        end

        function ret=mmWalkOperationBlockingAccess(this,m3iAccess,isServer)
            ret=[];
            m3iRef=m3iAccess.instanceRef;
            if~isempty(m3iRef)&&m3iRef.isvalid()
                this.applySeq('mmVisit',m3iRef,isServer);
            end
        end

        function ret=mmWalkOperationPortInstanceRef(this,m3iRef,isServer)
            ret=[];
            if~isempty(m3iRef)&&m3iRef.isvalid()
                this.mmWalkOperation(m3iRef.Operations,m3iRef.Port,isServer);
            end
        end

        function ret=mmWalkInternalTriggerPoint(this,m3iTrigPoint)
            ret=[];



            m3iIntTrigEvents=m3i.filter(@(x)...
            isequal(x.MetaClass,Simulink.metamodel.arplatform.behavior.InternalTriggerOccurredEvent.MetaClass),...
            this.M3iASWC.Behavior.Events);
            for k=1:length(m3iIntTrigEvents)
                m3iIntTrigEvent=m3iIntTrigEvents{k};
                if(m3iTrigPoint==m3iIntTrigEvent.InternalTriggeringPoint)
                    m3iTriggeringRun=m3iTrigPoint.containerM3I;
                    m3iTriggeredRun=m3iIntTrigEvent.StartOnEvent;
                    itpDataItem=autosar.mm.mm2rte.RTEDataItemInternalTriggeringPoint(...
                    m3iTriggeringRun.symbol,m3iTrigPoint.Name,m3iTriggeredRun.symbol);
                    this.RTEData.insertItem(itpDataItem);
                end
            end
        end

        function ret=mmWalkOperation(this,...
            m3iOperation,...
            m3iPort,...
            isServer,...
            serverRunnableSymbol)
            assert(~isServer||(nargin==5),...
            'serverRunnableSymbol must be provided when processing a server operation');

            ret=[];
            typeBuilder=this.RTEGenerator.TypeBuilder;


            serverLHSReturnString='void';

            m3iArgs=m3iOperation.Arguments;
            argDataItems=cell(1,m3iArgs.size);
            for i=1:m3iArgs.size
                m3iArg=m3iArgs.at(i);
                if m3iArg.Direction==...
                    Simulink.metamodel.arplatform.interface.ArgumentDataDirectionKind.Error
                    if isServer
                        serverLHSReturnString='Std_ReturnType';
                    end
                    continue;
                end


                typeBuilder.addReferencedType(m3iArg.Type);

                typeInfo=typeBuilder.getTypeInfo(m3iArg.Type);
                argDataItems{i}=autosar.mm.mm2rte.RTEDataItemOperationArgument(...
                m3iArg.Name,m3iArg.Direction.toString,typeInfo,isServer);
            end


            if isServer
                opDataItem=autosar.mm.mm2rte.RTEDataItemServer(...
                m3iOperation.Name,m3iPort.Name,[argDataItems{:}],...
                serverLHSReturnString,serverRunnableSymbol);
            else
                opDataItem=autosar.mm.mm2rte.RTEDataItemOperationCall(...
                m3iOperation.Name,m3iPort.Name,[argDataItems{:}]);
            end
            this.RTEData.insertItem(opDataItem);
        end

        function ret=mmWalkIrvAccess(this,m3iAccess,runnableName,isWrite)
            ret=[];
            iRef=m3iAccess.instanceRef;
            if~isempty(iRef)&&iRef.isvalid()
                this.apply('mmVisit',iRef.DataElements,runnableName,isWrite);
            end
        end

        function ret=mmWalkIrvData(this,m3iData,runnableName,isWrite)
            ret=[];


            typeBuilder=this.RTEGenerator.TypeBuilder;
            typeBuilder.addReferencedType(m3iData.Type);


            typeInfo=typeBuilder.getTypeInfo(m3iData.Type);
            irvName=m3iData.Name;
            accessKind=m3iData.Kind.toString;
            dataItem=autosar.mm.mm2rte.RTEDataItemIRVFcn(...
            irvName,runnableName,isWrite,accessKind,typeInfo);
            this.RTEData.insertItem(dataItem);
        end

        function ret=mmWalkFlowDataAccess(this,m3iAccess,runnableName)
            ret=[];
            iRef=m3iAccess.instanceRef;
            if~isempty(iRef)&&iRef.isvalid()
                this.apply('mmVisit',...
                iRef.DataElements,...
                iRef.Port,...
                m3iAccess.Kind.toString,...
                runnableName);
            end
        end

        function ret=mmWalkFlowData(this,m3iData,m3iPort,...
            accessKind,runnableName)

            ret=[];
            dataElementName=m3iData.Name;



            typeBuilder=this.RTEGenerator.TypeBuilder;
            typeBuilder.addReferencedType(m3iData.Type);





            isQueuedRecv=false;
            isQueuedSend=false;
            portElementisUpdated=false;
            needIStatusFcn=false;
            isE2EProtection=false;
            if isa(m3iPort,'Simulink.metamodel.arplatform.port.DataReceiverPort')||...
                isa(m3iPort,'Simulink.metamodel.arplatform.port.DataSenderReceiverPort')

                m3iComSpec=autosar.mm.Model.findComSpecForDataElement(m3iPort,m3iData.Name,true);

                if isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverQueuedPortComSpec')
                    isQueuedRecv=true;
                    isE2EProtection=m3iComSpec.UsesEndToEndProtection;
                elseif isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec')
                    portElementisUpdated=m3iComSpec.EnableUpdate;
                    isE2EProtection=m3iComSpec.UsesEndToEndProtection;
                end

                needIStatusFcn=autosar.api.Utils.isErrorStatusPortElement(m3iPort,m3iData,accessKind)||...
                this.isReferencedByErrorStatusPort(m3iPort.Name,m3iData.Name);
            end
            if isa(m3iPort,'Simulink.metamodel.arplatform.port.DataSenderPort')
                portInfo=autosar.mm.Model.findPortInfo(m3iPort,m3iData,'DataElements');
                if~isempty(portInfo)&&~isempty(portInfo.comSpec)
                    if isa(portInfo.comSpec,'Simulink.metamodel.arplatform.port.DataSenderQueuedPortComSpec')
                        isQueuedSend=true;
                        isE2EProtection=portInfo.comSpec.UsesEndToEndProtection;
                    elseif isa(portInfo.comSpec,...
                        'Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec')
                        isE2EProtection=portInfo.comSpec.UsesEndToEndProtection;
                    end
                end
            end


            typeInfo=typeBuilder.getTypeInfo(m3iData.Type);
            e2eAccessKind=[];
            useE2EErrorHandlingTransformer=autosar.mm.mm2sl.utils.doesPortUseE2EErrorHandlingTransformer(m3iPort);

            if isE2EProtection
                assert(strcmp(accessKind,'ExplicitReadByArg')||strcmp(accessKind,'ExplicitWrite'),...
                'Invalid access kind for E2E: %s\n',accessKind);

                if~useE2EErrorHandlingTransformer
                    if strcmp(accessKind,'ExplicitReadByArg')
                        e2eAccessKind='E2ERead';
                    else
                        e2eAccessKind='E2EWrite';
                    end
                else
                    if strcmp(accessKind,'ExplicitReadByArg')
                        e2eAccessKind='ExplicitReadByArg';
                    else
                        e2eAccessKind='ExplicitWrite';
                    end
                end
                dataAccessKind=e2eAccessKind;
            else
                dataAccessKind=accessKind;
            end
            dataItem=autosar.mm.mm2rte.RTEDataItemAccessFcn(...
            runnableName,m3iPort.Name,dataElementName,dataAccessKind,...
            isQueuedRecv,isQueuedSend,typeInfo);
            dataItem.setHasTransformerError(useE2EErrorHandlingTransformer);
            this.RTEData.insertItem(dataItem);



            if needIStatusFcn
                dataItem=autosar.mm.mm2rte.RTEDataItemAccessFcn(...
                runnableName,m3iPort.Name,dataElementName,'IStatus',...
                isQueuedRecv,false,typeInfo);
                this.RTEData.insertItem(dataItem);
            end


            if portElementisUpdated
                assert(any(strcmp(accessKind,{'ExplicitReadByArg','ExplicitReadByValue'})));
                dataItem=autosar.mm.mm2rte.RTEDataItemAccessFcn(...
                runnableName,m3iPort.Name,dataElementName,'IsUpdated',...
                isQueuedRecv,false,typeInfo);
                this.RTEData.insertItem(dataItem);
            end

            if(strcmp(accessKind,'ExplicitWrite'))



                dataItem=autosar.mm.mm2rte.RTEDataItemAccessFcn(...
                runnableName,m3iPort.Name,dataElementName,...
                'SignalInvalidationStub',false,false,typeInfo);
                this.RTEData.insertItem(dataItem);
                portInfo=autosar.mm.Model.findPortInfo(m3iPort,m3iData,'DataElements');
                hasSourceSignalInvalidationBlock=...
                this.RTEGenerator.SignalInvalidationPortTable.hasSourceSignalInvalidationBlock(...
                m3iPort.Name,dataElementName);
                if hasSourceSignalInvalidationBlock
                    dataItem=autosar.mm.mm2rte.RTEDataItemSignInvInitValue(...
                    runnableName,m3iPort.Name,dataElementName,...
                    portInfo,typeInfo);
                    this.RTEData.insertItem(dataItem);
                end
            end



            if strcmp(accessKind,'ImplicitWrite')
                dataItem=autosar.mm.mm2rte.RTEDataItemAccessFcn(...
                runnableName,m3iPort.Name,dataElementName,'ImplicitWriteRef',...
                isQueuedRecv,false,typeInfo);
                this.RTEData.insertItem(dataItem);
            end


            if isE2EProtection&&~useE2EErrorHandlingTransformer
                e2eInitAccessKind=[e2eAccessKind,'Init'];
                dataItem=autosar.mm.mm2rte.RTEDataItemAccessFcn(...
                runnableName,m3iPort.Name,dataElementName,e2eInitAccessKind,...
                isQueuedRecv,isQueuedSend,typeInfo);
                this.RTEData.insertItem(dataItem);
            end
        end

        function ret=mmWalkModeAccess(this,m3iAccess)
            ret=[];
            iRef=m3iAccess.InstanceRef;
            if~isempty(iRef)&&iRef.isvalid()
                this.apply('mmVisit',iRef.groupElement,...
                iRef.Port.Name,m3iAccess);
            end
        end


        function ret=mmWalkModeDeclarationGroupElement(this,m3iData,...
            portName,m3iAccess)
            ret=[];
            elementName=m3iData.Name;



            typeBuilder=this.RTEGenerator.TypeBuilder;
            typeBuilder.addReferencedType(m3iData.ModeGroup);


            typeInfo=typeBuilder.getTypeInfo(m3iData.ModeGroup);
            dataItem=autosar.mm.mm2rte.RTEDataItemModeDeclGroupAccess(...
            portName,elementName,typeInfo,m3iAccess);
            this.RTEData.insertItem(dataItem);
        end


        function ret=mmWalkPIM(this,m3iData)
            ret=[];


            dataItem=autosar.mm.mm2rte.RTEDataItemCTypedPIM(...
            m3iData.Name,m3iData.typeStr,m3iData.typeDefinitionStr);
            this.RTEData.insertItem(dataItem);








            externalToolInfo=m3iData.getExternalToolInfo('ARXML_TypePathForCTypedPIM');
            if~isempty(externalToolInfo.tool)&&~isempty(externalToolInfo.externalId)
                m3iType=autosar.mm.Model.findChildByName(...
                this.M3iModel.RootPackage.front,...
                externalToolInfo.externalId);


                typeBuilder=this.RTEGenerator.TypeBuilder;
                typeBuilder.addReferencedType(m3iType);
            end


        end

        function ret=mmWalkArTypedPIMOrStaticMemory(this,m3iData,type)
            switch type
            case 'ArTypedPIM'
                ret=this.mmWalkArTypedPIM(m3iData);
            case 'StaticMemory'
                ret=this.mmWalkStaticMemory(m3iData);
            otherwise
                ret=[];
            end
        end

        function ret=mmWalkArTypedPIM(this,m3iData)
            ret=[];



            typeBuilder=this.RTEGenerator.TypeBuilder;
            typeBuilder.addReferencedType(m3iData.Type);


            typeInfo=typeBuilder.getTypeInfo(m3iData.Type);
            dataItem=autosar.mm.mm2rte.RTEDataItemARTypedPIM(...
            m3iData.Name,typeInfo);
            this.RTEData.insertItem(dataItem);
        end

        function ret=mmWalkStaticMemory(this,m3iData)
            ret=[];



            typeBuilder=this.RTEGenerator.TypeBuilder;
            typeBuilder.addReferencedType(m3iData.Type);
        end

        function ret=mmWalkPortParameterAccess(this,m3iPortParameterAccess)

            ret=[];
            iRef=m3iPortParameterAccess.instanceRef;
            if~isempty(iRef)&&iRef.isvalid()
                this.apply('mmVisit',iRef.DataElements,iRef.Port.Name);
            end
        end

        function ret=mmWalkComponentParameterAccess(this,m3iComponentParameterAccess)

            ret=[];
            iRef=m3iComponentParameterAccess.instanceRef;
            if~isempty(iRef)&&iRef.isvalid()
                this.apply('mmVisit',iRef.DataElements);
            end
        end

        function ret=mmWalkParameterData(this,m3iParameterData,varargin)
            ret=[];

            if isempty(varargin)
                portName=[];
            else
                portName=varargin{1};
            end
            if m3iParameterData.Type.isvalid()
                paramName=m3iParameterData.Name;
                portParamName=[portName,'_',paramName];
                if~any(strcmp(this.WalkedParameterData,portParamName))
                    this.WalkedParameterData{end+1}=portParamName;



                    typeBuilder=this.RTEGenerator.TypeBuilder;
                    typeBuilder.addReferencedType(m3iParameterData.Type);



                    if m3iParameterData.Kind~=Simulink.metamodel.arplatform.behavior.ParameterKind.Const

                        typeInfo=typeBuilder.getTypeInfo(m3iParameterData.Type);
                        dataItem=autosar.mm.mm2rte.RTEDataItemParameter(...
                        portName,paramName,typeInfo);
                        this.RTEData.insertItem(dataItem);
                    end
                end
            end
        end

        function ret=mmWalkExclusiveArea(this,m3iData)
            ret=[];


            dataItem=autosar.mm.mm2rte.RTEDataItemExclusiveArea(m3iData.Name);
            this.RTEData.insertItem(dataItem);
        end

        function ret=mmWalkIncludedDataTypeSets(this,m3iIncludedTypeSet)
            ret=[];
            typeBuilder=this.RTEGenerator.TypeBuilder;
            m3iIncludedTypesSeq=m3iIncludedTypeSet.DataTypes;
            for typeIdx=1:m3iIncludedTypesSeq.size()
                m3iType=m3iIncludedTypesSeq.at(typeIdx);
                typeBuilder.addReferencedType(m3iType);
            end
        end

        function ret=isReferencedByErrorStatusPort(this,portName,dataElementName)




            ret=this.RTEGenerator.ErrorStatusPortTable.hasErrorStatusPort(...
            portName,dataElementName);
        end
    end
end



