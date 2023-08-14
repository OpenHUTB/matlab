classdef SLModelBuilder<handle








    properties(Access=private)
        MdlName;
        UpdateMode;
        AutoDelete;
        ChangeLogger;
        SLMatcher;
        AddedBlks;
        MarkAdditions;
        msgStream;
        slSystemName;
        slTypeBuilder;
        slParameterBuilder;
        SLConstantBuilder;
        slSubsystem2PositionMap;
        slCallerOp2PortNameMap;
        InternalTrigBlk2TriggeringRunMap;
        slRunnableFcnCallInport2RefBiMap;
        slRunnableSubSystem2RefBiMap;
        slSLFcn2PortMethodMap;
PostAddtermsResetOutDataTypeStrMap
        expReadData2IsUpdatedMap;
        DataInportBlk2ErrorStatusBlkMap;
        RootOutportBlk2CanInvalidateMap;
        InvalidatedRootOutportBlocks;
        BlockVariantBuilder autosar.mm.mm2sl.BlockVariantBuilder
        ModelPeriodicRunnablesAs;
        TopModelLayoutManager;
        SysConstsValueMap;
        ComponentHasBehavior;
        SsToLayoutManagerMap;
        IRVQNameToSLNameMap;
        UseBusElementPorts;
        RootPortsNeedingEventRouting={};
    end

    methods(Access=public)



        function this=SLModelBuilder(mdlName,changeLogger,updateMode,...
            autoDelete,slTypeBuilder,slParameterBuilder,slConstantBuilder,...
            modelPeriodicRunnablesAs,layoutLayers,sysConstsValueMap,componentHasBehavior,...
            useBusElementPorts)

            this.MdlName=mdlName;
            this.ChangeLogger=changeLogger;
            this.UpdateMode=updateMode;
            this.AutoDelete=autoDelete;

            this.slTypeBuilder=slTypeBuilder;
            this.slParameterBuilder=slParameterBuilder;
            this.SLConstantBuilder=slConstantBuilder;
            this.BlockVariantBuilder=autosar.mm.mm2sl.BlockVariantBuilder(mdlName,changeLogger);
            this.ModelPeriodicRunnablesAs=modelPeriodicRunnablesAs;
            this.ComponentHasBehavior=componentHasBehavior;
            this.UseBusElementPorts=useBusElementPorts;

            if autosar.api.Utils.isMappedToComposition(mdlName)
                this.SLMatcher=autosar.updater.SLCompositionMatcher(mdlName);
            else
                this.SLMatcher=autosar.updater.SLComponentMatcher(mdlName);
            end

            this.TopModelLayoutManager=autosar.mm.mm2sl.layout.LayoutManagerFactory.getLayoutManager(mdlName,...
            'TopModel',updateMode,'SubSystem','LayoutLayers',layoutLayers.GraphLayers);

            this.SsToLayoutManagerMap=this.createSubsystemToLayoutManagerMap(layoutLayers.NonGraphBlocks);
            this.IRVQNameToSLNameMap=containers.Map();

            this.slSubsystem2PositionMap=containers.Map(...
            'KeyType','double',...
            'ValueType','any'...
            );

            this.slCallerOp2PortNameMap=autosar.mm.util.Map(...
            'InitCapacity',40,...
            'KeyType','char');

            this.InternalTrigBlk2TriggeringRunMap=autosar.mm.util.Map(...
            'InitCapacity',40,...
            'KeyType','double');

            this.slRunnableFcnCallInport2RefBiMap=autosar.mm.util.BiMap(...
            'InitCapacity',40,...
            'KeyType1','double',...
            'KeyType2','char',...
            'HashFcn2',@autosar.mm.util.InstanceRefHelper.getOrSetId);

            this.slRunnableSubSystem2RefBiMap=autosar.mm.util.BiMap(...
            'InitCapacity',40,...
            'KeyType1','double',...
            'KeyType2','char',...
            'HashFcn2',@autosar.mm.util.InstanceRefHelper.getOrSetId);

            this.slSLFcn2PortMethodMap=autosar.mm.util.Map(...
            'InitCapacity',40,...
            'KeyType','double'...
            );

            this.expReadData2IsUpdatedMap=autosar.mm.util.Map(...
            'InitCapacity',40,...
            'KeyType','double'...
            );

            this.DataInportBlk2ErrorStatusBlkMap=autosar.mm.util.Map(...
            'InitCapacity',40,...
            'KeyType','double'...
            );

            this.RootOutportBlk2CanInvalidateMap=containers.Map(...
            'KeyType','char',...
            'ValueType','logical'...
            );
            this.InvalidatedRootOutportBlocks={};

            this.PostAddtermsResetOutDataTypeStrMap=containers.Map(...
            'KeyType','double',...
            'ValueType','any'...
            );


            this.msgStream=autosar.mm.util.MessageStreamHandler.instance();

            this.MarkAdditions=this.UpdateMode;
            this.AddedBlks={};

            this.SysConstsValueMap=sysConstsValueMap;
        end

        function reportDeletions(this)

            if this.AutoDelete
                deletionMode='DeleteBlock';
            else
                deletionMode='';
            end
            this.SLMatcher.doDeletions(this.ChangeLogger,deletionMode);

            if this.AutoDelete
                autosar.mm.mm2sl.layout.LayoutHelper.deleteUnconnectedLines(this.MdlName);
            end
        end

        function markupAdditions(this)
            if this.MarkAdditions
                this.markAddedBlks();
            end
        end

        function addComponent(this,m3iComp)
            this.slSystemName=this.MdlName;
            this.createSubsystemPositionEntry(this.MdlName);

            if this.UpdateMode
                slMapping=autosar.api.getSimulinkMapping(this.MdlName,this.ChangeLogger);
                slMapping.mapComponent(autosar.api.Utils.getQualifiedName(m3iComp));
            end
        end

        function addedBlks=getAddedBlks(this)
            addedBlks=this.AddedBlks;
        end

        function refreshModelLayout(this)
            this.TopModelLayoutManager.refresh();

            for subsystemLayoutManager=this.SsToLayoutManagerMap.values
                subsystemLayoutManager{1}.refresh();
            end
        end

        function[blkPath,isDataPortCreated]=addPortElement(this,m3iPort,m3iDataElement,accessKindStr,slPortType)




            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,blkPath]=this.SLMatcher.isPortElementMapped(m3iPort,m3iDataElement,slPortType);
            isDataPortCreated=~isMapped;
            if isMapped
                blkPath=this.updatePortElement(blkPath,m3iPort,m3iDataElement,slPortType);
            else

                slBEPEnabledPortType=slPortType;
                isAddingBusElementPort=this.UseBusElementPorts...
                &&any(strcmp(slPortType,{'Inport','Outport'}));

                if isAddingBusElementPort
                    if strcmp(slPortType,'Inport')
                        slBEPEnabledPortType='simulink/Sources/In Bus Element';
                    else
                        slBEPEnabledPortType='simulink/Sinks/Out Bus Element';
                    end
                end

                blkPath=this.createPortElement(m3iPort,m3iDataElement,slBEPEnabledPortType);
            end


            isUpdatedPortElement=autosar.api.Utils.isUpdatedPortElement(m3iPort,m3iDataElement,slPortType);
            if isUpdatedPortElement
                [isMapped,isUpdatedBlkPath]=this.SLMatcher.isIsUpdatedPortElementMapped(m3iPort,m3iDataElement,slPortType);
                if isMapped
                    this.updateIsUpdatedPortElement(blkPath,isUpdatedBlkPath,m3iPort,m3iDataElement,slPortType);
                else
                    this.createIsUpdatedPortElement(blkPath,m3iPort,m3iDataElement,slPortType);
                end
            end


            isErrorStatusPortElement=autosar.api.Utils.isErrorStatusPortElement(m3iPort,m3iDataElement,accessKindStr);
            if isErrorStatusPortElement
                this.createOrUpdateErrorStatusPortElement(blkPath,m3iPort,m3iDataElement,slPortType,isDataPortCreated);
            end


            if strcmp(get_param(blkPath,'BlockType'),'Outport')
                isCanInvalidateSupported=autosar.mm.mm2sl.SLModelBuilder.isCanInvalidateSupported(m3iPort,m3iDataElement,accessKindStr);
                if isCanInvalidateSupported
                    this.RootOutportBlk2CanInvalidateMap(blkPath)=true;
                end
            end
        end

        function[blkPath,isCreated]=addModeElement(this,m3iPort,m3iModeGroup,slPortType)




            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,blkPath]=this.SLMatcher.isPortElementMapped(m3iPort,m3iModeGroup,slPortType);
            if isMapped
                blkPath=this.updateModeElement(blkPath,m3iPort,m3iModeGroup,slPortType);
            else
                blkPath=this.createModeElement(m3iPort,m3iModeGroup,slPortType);
            end
            isCreated=~isMapped;
        end

        function blkPaths=addPortOperation(this,sys,m3iPort,m3iOperation)



            if isempty(sys)
                sys=this.MdlName;
            end

            if m3iPort.Interface.has('IsService')&&m3iPort.Interface.IsService
                serverType='Basic software';
            else
                serverType='Application software';
            end

            foundAUTOSARClientBlk=~isempty(arblk.findAUTOSARClientBlks(sys,...
            'portName',m3iPort.Name,...
            'OperationName',m3iOperation.Name,...
            'serverType',serverType));

            if foundAUTOSARClientBlk


                return
            end


            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,blkPaths]=this.SLMatcher.isPortOperationMapped(sys,m3iPort,m3iOperation);
            if isMapped
                this.updatePortOperation(blkPaths,m3iPort,m3iOperation);
            else
                this.createPortOperation(sys,m3iPort,m3iOperation);
            end

        end

        function slFcnPath=addServerFunction(this,sys,m3iPort,m3iOperation)


            if isempty(sys)
                sys=this.MdlName;
            end


            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,blkPath]=this.SLMatcher.isServerFunctionMapped(sys,m3iPort,m3iOperation);
            if isMapped
                slFcnPath=this.updateServerFunction(blkPath,m3iPort,m3iOperation);
            else
                slFcnPath=this.createServerFunction(sys,m3iPort,m3iOperation);
            end
        end

        function[subsystemPath,finalizeObj,isCreated]=addFunction(this,parentSys,m3iRun,m3iRunRef,irtRunnableType)

            updateMode=this.UpdateMode;
            finalizeObj=[];


            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,runnablePath]=this.SLMatcher.isRunnableMapped(m3iRun);



            if(autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass)...
                &&~autosar.mm.mm2sl.RunnableHelper.hasIrvOrIOConnections(m3iRun))
                if isMapped

                    parentSys=get_param(runnablePath,'Parent');
                else

                    parentSys=this.createOrUpdateSimulinkBlock(parentSys,...
                    'SubSystem',m3iRun.Events.at(1).instanceRef.Port.Name,[],[],{});
                end
            end

            if isMapped
                [subsystemPath,isCreated]=this.updateRunnable(runnablePath,parentSys,m3iRun,m3iRunRef,irtRunnableType);
            else
                [subsystemPath,runnablePath,isCreated]=this.createRunnable(parentSys,m3iRun,m3iRunRef,irtRunnableType);
                if updateMode

                    slMapping=autosar.api.getSimulinkMapping(this.MdlName,this.ChangeLogger);

                    isServerOperation=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                    Simulink.metamodel.arplatform.behavior.OperationInvokedEvent.MetaClass);
                    modelMapping=autosar.api.Utils.modelMapping(this.MdlName);
                    if isServerOperation

                        modelMapping.sync();

                        finalizeObj=onCleanup(@()slMapping.mapFunction(...
                        ['SimulinkFunction:',m3iRun.symbol],m3iRun.Name));
                    elseif irtRunnableType==autosar.mm.mm2sl.IRTRunnableType.Initialization
                        autosar.api.Utils.mapFunction(this.MdlName,...
                        modelMapping.InitializeFunctions,m3iRun.Name);
                    elseif irtRunnableType==autosar.mm.mm2sl.IRTRunnableType.Reset
                        autosar.api.Utils.mapFunction(this.MdlNamee,...
                        modelMapping.ResetFunctions,m3iRun.Name);
                    elseif irtRunnableType==autosar.mm.mm2sl.IRTRunnableType.Terminate
                        autosar.api.Utils.mapFunction(this.MdlName,...
                        modelMapping.TerminateFunctions,m3iRun.Name);
                    else
                        [isPeriodicRun,m3iEvent]=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
                        Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
                        if isPeriodicRun&&strcmp(this.ModelPeriodicRunnablesAs,'AtomicSubsystem')

                            modelMapping.sync();
                            modelMapping.addStepFunction(m3iRun.Name,m3iEvent.Period,0);
                            blkMapping=modelMapping.StepFunctions(end);
                            if~isempty(blkMapping)
                                autosar.api.Utils.mapFunction(this.MdlName,...
                                blkMapping,m3iRun.Name);
                            end
                        elseif slfeature('AUTOSARImportAsAtomicSubsystems')&&...
                            strcmp(get_param(runnablePath,'ScheduleAs'),'Aperiodic partition')


                            return
                        else
                            blkName=get_param(runnablePath,'Name');
                            slMapping.mapFunction(['ExportedFunction:',blkName],m3iRun.Name);
                        end
                    end
                end
            end
        end

        function addInternalTriggerPoint(this,m3iTrigPoint,m3iTriggeredRun,...
            m3iTriggeringRun,triggeringRunPath)



            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,blkPaths]=this.SLMatcher.isInternalTriggerPointMapped(...
            m3iTrigPoint,m3iTriggeringRun,triggeringRunPath);
            if isMapped
                this.updateInternalTriggerPoint(blkPaths,m3iTrigPoint,m3iTriggeredRun,...
                m3iTriggeringRun);
            else
                this.createInternalTriggerPoint(m3iTrigPoint,m3iTriggeredRun,...
                m3iTriggeringRun,triggeringRunPath);
            end
        end





        function positionBlockInLayout(this,blk,isCentral,isServer)

            narginchk(2,4);
            if nargin<4
                isServer=false;
            end
            if nargin<3
                isCentral=true;
            end

            if isempty(blk)
                return;
            end

            blkPath=getfullname(blk);
            blkParent=get_param(blkPath,'Parent');
            if strcmp(blkParent,this.MdlName)&&...
                (this.ComponentHasBehavior||this.isAdaptiveModel())



                if this.SsToLayoutManagerMap.isKey(blkPath)||isServer
                    this.TopModelLayoutManager.addBlock(blkPath,'isServRunParent',true);
                else
                    this.TopModelLayoutManager.addBlock(blkPath,'isCentral',isCentral);
                end
            elseif this.SsToLayoutManagerMap.isKey(blkParent)
                subsystemManager=this.SsToLayoutManagerMap(blkParent);
                subsystemManager.addBlock(blkPath,'isCentral',false);
            else

                this.setIdealBlockPosition(blkPath);
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(blkPath);
            end
        end

        function[isMapped,obj]=isRunnableMappedToStepFcn(this,m3iRun)
            [isMapped,obj]=this.SLMatcher.isRunnableMappedToStepFcn(m3iRun);
        end

        function[isMapped,obj]=isIRVMapped(this,m3iIrv)
            if strcmp(this.ModelPeriodicRunnablesAs,'AtomicSubsystem')

                [isMapped,obj]=this.SLMatcher.isRateTransitionMapped(m3iIrv);
            else
                assert(strcmp(this.ModelPeriodicRunnablesAs,'FunctionCallSubsystem'),...
                'ModelPeriodicRunnablesAs is expected to be FunctionCallSubsystem.');

                [isMapped,obj]=this.SLMatcher.isDataTransferMapped(m3iIrv);
            end
        end

        function connectRootIsUpdatedInportBlockToSSInportBlock(this,currBlk,dstSS)
            isUpdatedSlBlock=this.expReadData2IsUpdatedMap.get(currBlk);
            if~isempty(isUpdatedSlBlock)
                this.connectRootInportBlockToSSInportBlock(...
                isUpdatedSlBlock,dstSS);
            end
        end

        function connectRootErrorStatusInportBlockToSSInportBlock(this,currBlk,dstSS)
            errorStatusSlBlock=this.DataInportBlk2ErrorStatusBlkMap.get(currBlk);
            if~isempty(errorStatusSlBlock)
                this.connectRootInportBlockToSSInportBlock(...
                errorStatusSlBlock,dstSS);
            end
        end

        function connectSignalInvalidationBlockToSSOutportBlock(this,ssOutportBlk,rootOutportBlk,dstSS,m3iRef,isUpdateMode)
            if this.RootOutportBlk2CanInvalidateMap.isKey(rootOutportBlk)
                if sum(ismember(this.InvalidatedRootOutportBlocks,rootOutportBlk))>0
                    messageStream=autosar.mm.util.MessageStreamHandler.instance();
                    messageStream.createWarning('autosarstandard:importer:MultipleInvalidationsForAnOutport',...
                    getfullname(rootOutportBlk),...
                    rootOutportBlk,'modelImport');
                else
                    this.InvalidatedRootOutportBlocks=[this.InvalidatedRootOutportBlocks,rootOutportBlk];
                end
                sigInvBlkName=sprintf('%s%s',get_param(rootOutportBlk,'Name'),'_SignalInvalidation');
                if~isUpdateMode
                    sigInvBlk=this.createOrUpdateSimulinkBlock(dstSS,'SignalInvalidation',...
                    sigInvBlkName,[],[],{'ShowName','off'});
                else


                    [sigInvBlk,~]=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(dstSS,'SignalInvalidation',sigInvBlkName);
                    if isempty(sigInvBlk)

                        return;
                    end
                end
                portInfo=autosar.mm.Model.findPortInfo(m3iRef.Port,m3iRef.DataElements,'DataElements');
                invalidationPolicy=portInfo.DataElements.InvalidationPolicy;
                m3iComSpec=portInfo.comSpec;

                propName=autosar.mm.mm2sl.ConstantBuilder.getInitValuePropertyName(m3iComSpec);
                m3iInitValue=m3iComSpec.(propName);
                if isempty(m3iInitValue)||~m3iInitValue.isvalid()

                    initValStr=this.SLConstantBuilder.getBlockInitialValueStringForType(m3iRef.DataElements.Type);
                else
                    if~m3iInitValue.Type.isvalid()

                        m3iInitValue.Type=m3iRef.DataElements.Type;




                        if isa(m3iInitValue,'Simulink.metamodel.types.EnumerationLiteralReference')...
                            &&strcmp(m3iInitValue.Type.CompuMethod.Category.toString,'LinearAndTextTable')
                            MSLDiagnostic('autosarstandard:importer:RefToEnumLiteralNotSupportedForScaleLinear',...
                            m3iInitValue.Name,m3iInitValue.Type.CompuMethod.Name,m3iInitValue.LiteralText).reportAsWarning;
                            return;
                        end
                    end
                    initValStr=this.SLConstantBuilder.getBlockInitialValueStringForConst(m3iInitValue);
                end
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,sigInvBlk,...
                'InitialOutput',initValStr,...
                'InvalidationPolicy',invalidationPolicy.toString);
                if~isUpdateMode
                    add_line(dstSS,[get_param(sigInvBlk,'Name'),'/1'],...
                    [get_param(ssOutportBlk,'Name'),'/1']);

                    autosar.mm.mm2sl.MRLayoutManager.homeBlk(sigInvBlk);
                end
            end
        end




        function[blkPath,alreadyExists]=createOrUpdateSimulinkArgumentPort(this,...
            sys,type,slArgDirection,m3iArgument,variationPoint)



            onCleanupObj=this.forceAutomatedBlkAdditions();%#ok<NASGU>

            [isMapped,blkPath]=this.SLMatcher.isArgumentMapped(sys,m3iArgument,slArgDirection);

            m3iArgName=m3iArgument.Name;
            if isMapped
                alreadyExists=true;
                argParamName=get_param(blkPath,'ArgumentName');
            else
                alreadyExists=false;
                argParamName=m3iArgName;
            end

            if ischar(type)||isStringScalar(type)
                blkPath=this.createOrUpdateSimulinkInportWithType(...
                sys,...
                type,...
                slArgDirection,argParamName,variationPoint,'','');
            else
                blkPath=this.createOrUpdateSimulinkPortWithType(...
                sys,...
                type,...
                slArgDirection,argParamName,variationPoint,m3iArgument.desc,...
                '','');
            end

            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blkPath,...
            'ArgumentName',argParamName);

        end

        function[blockH,alreadyExists]=createOrUpdateDataStoreMemory(this,m3iData)
            [isMapped,blockH]=this.SLMatcher.isMappedToDSM(m3iData);

            alreadyExists=isMapped;
            if~alreadyExists
                dsmBlkPath=this.createOrUpdateSimulinkBlock(this.MdlName,...
                'DataStoreMemory',m3iData.Name,[],[],{'DataStoreName',m3iData.Name});
                blockH=get_param(dsmBlkPath,'Handle');
            end

            if m3iData.InitValue.isvalid()


            else




                initValueStr=this.SLConstantBuilder.getBlockInitialValueStringForType(m3iData.Type);
                if~strcmp(get_param(blockH,'InitialValue'),initValueStr)
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                    blockH,'InitialValue',initValueStr);
                end
            end

            slTypeInfo=this.slTypeBuilder.buildType(m3iData.Type);
            if isfield(slTypeInfo,'dims')&&~isa(slTypeInfo.slObj,'Simulink.ValueType')
                dimensionStr=slTypeInfo.dims.toString();
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                blockH,'Dimensions',dimensionStr);
            end
        end

        function mapDataStore(this,m3iData,variableRole,hasNVBlockNeeds)
            [isMappedToDSM,blkH,slObj]=this.SLMatcher.isMappedToDSM(m3iData);

            if~isMappedToDSM


                return;
            end

            signalExists=false;
            if~isempty(slObj)
                [signalExists,sigObj,inModelWS]=autosar.utils.Workspace.objectExistsInModelScope(this.MdlName,m3iData.Name);

                isEmbeddedSignal=~isempty(slObj)&&~signalExists;
                if isEmbeddedSignal
                    if~strcmp(slObj.CoderInfo.StorageClass,'Auto')

                        return;
                    else

                    end
                else
                    if isa(sigObj,'AUTOSAR.Signal')&&~inModelWS&&~strcmp(sigObj.CoderInfo.StorageClass,'Auto')

                        return;
                    else

                    end
                end
            end


            slMapping=autosar.api.getSimulinkMapping(this.MdlName,this.ChangeLogger);
            if~isempty(m3iData.SwAddrMethod)
                swAddrMethod=m3iData.SwAddrMethod.Name;
            else
                swAddrMethod='';
            end
            if islogical(hasNVBlockNeeds)
                if hasNVBlockNeeds
                    hasNVBlockNeeds='true';
                else
                    hasNVBlockNeeds='false';
                end
            end
            slMapping.mapDataStore(blkH,variableRole,...
            'ShortName',m3iData.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iData.SwCalibrationAccess),...
            'DisplayFormat',m3iData.DisplayFormat,...
            'IsVolatile',m3iData.Type.IsVolatile,...
            'NeedsNVRAMAccess',hasNVBlockNeeds,...
            'Qualifier',m3iData.Type.Qualifier);
            if signalExists
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blkH,'StateMustResolveToSignalObject','on');
            end
        end

        function updateSynthDSM(this,m3iData,variableRole,hasNVBlockNeeds)
            assert(slfeature('ArSynthesizedDS')>0,'Should not be called when this feature is off');

            [isMappedToSynthDSM,slDsmName]=this.SLMatcher.isMappedToSynthDSM(m3iData);

            if~isMappedToSynthDSM


                return;
            end


            slMapping=autosar.api.getSimulinkMapping(this.MdlName,this.ChangeLogger);
            if~isempty(m3iData.SwAddrMethod)
                swAddrMethod=m3iData.SwAddrMethod.Name;
            else
                swAddrMethod='';
            end
            if islogical(hasNVBlockNeeds)
                if hasNVBlockNeeds
                    hasNVBlockNeeds='true';
                else
                    hasNVBlockNeeds='false';
                end
            end
            slMapping.mapSynthesizedDataStore(slDsmName,variableRole,...
            'ShortName',m3iData.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iData.SwCalibrationAccess),...
            'DisplayFormat',m3iData.DisplayFormat,...
            'IsVolatile',m3iData.Type.IsVolatile,...
            'NeedsNVRAMAccess',hasNVBlockNeeds,...
            'Qualifier',m3iData.Type.Qualifier);
        end

        function updateSignal(this,m3iData,variableRole)
            [isMappedToSignal,lineH]=this.SLMatcher.isMappedToSignal(m3iData);

            if~isMappedToSignal


                return;
            end


            slMapping=autosar.api.getSimulinkMapping(this.MdlName,this.ChangeLogger);
            if~isempty(m3iData.SwAddrMethod)
                swAddrMethod=m3iData.SwAddrMethod.Name;
            else
                swAddrMethod='';
            end
            slMapping.mapSignal(lineH,variableRole,...
            'ShortName',m3iData.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iData.SwCalibrationAccess),...
            'DisplayFormat',m3iData.DisplayFormat,...
            'IsVolatile',m3iData.Type.IsVolatile,...
            'Qualifier',m3iData.Type.Qualifier);
        end

        function updateState(this,m3iData,variableRole)
            [isMappedToState,stateOwnerBlkH,stateName]=this.SLMatcher.isMappedToState(m3iData);

            if~isMappedToState


                return;
            end


            slMapping=autosar.api.getSimulinkMapping(this.MdlName,this.ChangeLogger);
            if~isempty(m3iData.SwAddrMethod)
                swAddrMethod=m3iData.SwAddrMethod.Name;
            else
                swAddrMethod='';
            end
            slMapping.mapState(stateOwnerBlkH,stateName,variableRole,...
            'ShortName',m3iData.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iData.SwCalibrationAccess),...
            'DisplayFormat',m3iData.DisplayFormat,...
            'IsVolatile',m3iData.Type.IsVolatile,...
            'Qualifier',m3iData.Type.Qualifier);
        end



        function[blkPath,alreadyExists]=createOrUpdateSimulinkBlock(this,...
            sys,blkType,blkName,blkDataType,positionVector,paramValuePair,varargin)


            [blk,blkName]=autosar.mm.mm2sl.SLModelBuilder.findSimulinkBlock(sys,blkType,blkName,varargin{:});
            alreadyExists=~isempty(blk);

            alreadyPositioned=false;

            if(~alreadyExists)
                if~contains(blkType,'/')
                    fullBlkType=sprintf('built-in/%s',blkType);
                else
                    fullBlkType=blkType;
                end




                isBusElementPort=endsWith(blkType,'Bus Element');
                if isBusElementPort
                    portNameIdx=find(strcmp(paramValuePair,'PortName'));
                    portName=paramValuePair{portNameIdx+1};
                    if endsWith(blkType,'In Bus Element')
                        searchBlkType='Inport';
                    else
                        searchBlkType='Outport';
                    end
                    existingBEPWithSamePortName=this.findSimulinkBlock(...
                    sys,searchBlkType,'','PortName',portName,...
                    'IsBusElementPort','on');
                    if~isempty(existingBEPWithSamePortName)
                        blk=add_block(existingBEPWithSamePortName(1),...
                        [getfullname(sys),'/',blkName],...
                        'MakeNameUnique','on');
                    end
                end

                if isempty(blk)
                    blk=add_block(...
                    fullBlkType,...
                    [getfullname(sys),'/',blkName],...
                    'MakeNameUnique','on');
                end

                if~isempty(paramValuePair)
                    isBusElementPort=any(strcmp(get_param(blk,'BlockType'),{'Inport','Outport'}))&&...
                    strcmp(get_param(blk,'IsBusElementPort'),'on');
                    if isBusElementPort
                        autosar.simulink.bep.Utils.setParam(blk,false,paramValuePair{:});
                    else
                        set_param(blk,paramValuePair{:});
                    end
                end

                this.ChangeLogger.logAddition('Automatic',[blkType,' block'],getfullname(blk));
                this.addedBlk(blk);

                if(nargin<=5||isempty(positionVector))
                    this.positionBlockInLayout(blk);
                    alreadyPositioned=true;
                else
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blk,'Position',positionVector);
                end
            else

                if~isempty(paramValuePair)
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
                    blk,paramValuePair{:});
                end
            end

            if~isempty(blkDataType)
                foundDataType=false;
                if iscell(blkDataType)
                    for ii=1:length(blkDataType)
                        dt=blkDataType{ii};
                        if strcmp(get_param(blk,'OutDataTypeStr'),dt)
                            foundDataType=true;
                        end
                    end
                    blkDataType=blkDataType{1};
                end

                if~foundDataType
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blk,'OutDataTypeStr',blkDataType);
                end
            end
            blkPath=getfullname(blk(1));

            if~alreadyExists&&~alreadyPositioned
                this.positionBlockInLayout(blkPath);
            end
        end

        function slMatcher=getSLMatcher(self)
            slMatcher=self.SLMatcher;
        end

        function addQueuedPortStateflowBlock(self,blockPath,blockType,~,typename,dimensions)








            sfinstalled=ver('Stateflow');
            if isempty(sfinstalled)





                return;
            end

            set_param(self.MdlName,'SimGenImportedTypeDefs','on');
            blockPos=get_param(blockPath,'Position');
            centerY=mean([blockPos(2),blockPos(4)]);

            if strcmp(blockType,'Inport')
                blockXOffset=50;
            else
                blockXOffset=-150;
            end

            load_system('sflib');
            defaultPos=get_param('sflib/Chart','Position');
            blockLeft=blockPos(3)+blockXOffset;
            blockWidth=defaultPos(3)-defaultPos(1);
            blockHeight=defaultPos(4)-defaultPos(2);
            position=[blockLeft,centerY-(blockHeight/2),...
            blockLeft+blockWidth,centerY+(blockHeight/2)];

            parentSystem=get_param(blockPath,'Parent');
            blockName=get_param(blockPath,'Name');

            sfChartName=arxml.arxml_private('p_create_aridentifier',...
            sprintf('%s_process_queue',blockName),namelengthmax);
            chartpath=self.createOrUpdateSimulinkBlock(parentSystem,'sflib/Chart',sfChartName,[],position,{});

            sfChartBasePath=get_param(chartpath,'Name');

            root=slroot;
            bd=root.find('-isa','Simulink.BlockDiagram','Name',self.MdlName);
            chartObj=bd.find('-isa','Stateflow.Chart','Path',chartpath);

            if strcmp(blockType,'Inport')
                autosar.mm.mm2sl.StateflowHelper.createReceiverChart(chartObj,blockName,...
                typename);
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                [blockName,'/1'],[sfChartBasePath,'/1']);
            else
                autosar.mm.mm2sl.StateflowHelper.createSenderChart(chartObj,...
                blockName,typename,dimensions);
                autosar.mm.mm2sl.layout.LayoutHelper.addLine(parentSystem,...
                [sfChartBasePath,'/1'],[blockName,'/1']);
            end
        end


        function addEventRoutingBlocks(this)
            autosar.validation.fixits.connectPortToEventRouting(...
            this.RootPortsNeedingEventRouting{:});
        end
    end

    methods(Access=public)
        connectIrv(this,m3iIrvData,srcSS,dstSS);
        [srcPort,dstPort,irvSLName]=getOrCreateIrvPorts(this,m3iIrvData,srcSS,dstSS,onlyGet);
        dstBlk=connectRootInportBlockToSSInportBlock(this,currBlk,dstSS);
        srcBlk=connectSSOutportBlockToRootOutportBlock(this,currBlk,srcSS,enableEnsureOutputIsVirtual);
        populateMapping(self,mapping,slPort2RefBiMap,slPort2AccessMap,slIrvRef2RunnableMap,...
        slParam2RefMap,slParamMap,dsmBlockMap,m3iComponent,initRunnable,resetRunnables,terminateRunnable,sampleTimes,componentHasBehavior,m3iSwcTiming);
        populatePortsMapping(self,slPort2RefBiMap,slPort2AccessMap);
        setEndToEndProtectionMethod(self,m3iBehavior);
        addterms(self,slPort2RefBiMap);
        isExpFcnStyle=convertToExportFunctionStyle(self);
    end

    methods(Access=private)


        createSubsystemPositionEntry(this,currSS);
        setIdealBlockPosition(this,blk,incr);
        connectSrcPortToDstPort(self,irvName,slDesc,workingSS,srcPort,...
        dstPort,initValue,modelPeriodicRunnablesAs);
        modelIRVConnectionBetweenRunnables(self,workingSS,srcBlk,dstBlk,srcPort,...
        dstPort,irvName,slDesc,initValue,modelPeriodicRunnablesAs);




        function portPath=createPortElement(this,m3iPort,m3iData,blockType)

            blockName=autosar.mm.mm2sl.SLModelBuilder.getSLBlockNameForPortElement(m3iPort,m3iData,blockType);

            portInfo=[];
            isNvPort=autosar.api.Utils.isNvPort(m3iPort);
            if~isNvPort
                portInfo=autosar.mm.Model.findPortInfo(m3iPort,m3iData,'DataElements');
            end

            isQueued=autosar.mm.mm2sl.SLModelBuilder.isQueuedPort(portInfo);
            portPath=this.createOrUpdateSimulinkPortWithType(...
            this.slSystemName,...
            m3iData.Type,...
            blockType,blockName,m3iPort.variationPoint,...
            m3iData.desc,m3iPort.Name,m3iData.Name);

            if isa(m3iPort,'Simulink.metamodel.arplatform.port.AdaptivePort')
                this.RootPortsNeedingEventRouting{end+1}=portPath;
            end


            if isQueued&&...
                isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedPort')&&...
                (slfeature('MessageModelRefSupport')==0)
                pos=get_param(portPath,'Position');
                canvasMinX=autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinX;
                canvasMinY=autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinY;
                pos=[pos(1)+canvasMinX,pos(2)+canvasMinY,pos(3)+canvasMinX,pos(4)+canvasMinY];
                name=get_param(portPath,'Name');
                this.TopModelLayoutManager.removeBlock(portPath);
                delete_block(portPath);
                portPath=add_block('built-in/SubSystem',...
                [this.slSystemName,'/',name,char(13),'QueuedExplicitSend not supported'],...
                'MakeNameUnique','on',...
                'Position',pos,...
                'BackgroundColor','orange',...
                'MaskDisplay','fprintf('' '')');
                this.positionBlockInLayout(portPath,false);


                warnId='RTW:autosar:unsupportedQueuedDataElement';
                warnParams={m3iData.Name,m3iData.containerM3I.Name};


                messageStream=autosar.mm.util.MessageStreamHandler.instance();
                messageStream.createWarning(warnId,warnParams,...
                portPath,'modelImport');

                portPath=[];
            end

        end

        function ssToLayoutManagerMap=createSubsystemToLayoutManagerMap(this,subsystemNames)
            assert(iscell(subsystemNames),'servRunSS must be cell array');
            ssToLayoutManagerMap=containers.Map(...
            'KeyType','char',...
            'ValueType','any'...
            );

            for i=1:length(subsystemNames)
                subsystemPath=[this.MdlName,'/',subsystemNames{i}];
                ssToLayoutManagerMap(subsystemPath)=...
                autosar.mm.mm2sl.layout.LayoutManagerFactory.getLayoutManager(this.MdlName,...
                'SubSystem',this.UpdateMode,'SubSystem',...
                'LayoutStrategy','Matrix','DestinationSystem',subsystemPath);
            end
        end




        function portPath=updatePortElement(this,blkPath,m3iPort,m3iData,blockType)


            isNvPort=autosar.api.Utils.isNvPort(m3iPort);

            if~isNvPort
                portInfo=autosar.mm.Model.findPortInfo(m3iPort,m3iData,'DataElements');
            else
                portInfo=[];
            end
            isQueued=autosar.mm.mm2sl.SLModelBuilder.isQueuedPort(portInfo);


            blockName=get_param(blkPath,'Name');

            [portPath,objExist]=this.createOrUpdateSimulinkPortWithType(...
            this.slSystemName,...
            m3iData.Type,...
            blockType,blockName,m3iPort.variationPoint,...
            m3iData.desc,m3iPort.Name,m3iData.Name);

            assert(objExist,'Port %s should already exist',portPath);



            if isQueued&&...
                isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedPort')&&...
                (slfeature('MessageModelRefSupport')==0)
                pos=get_param(portPath,'Position');
                canvasMinX=autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinX;
                canvasMinY=autosar.mm.mm2sl.layout.LayoutHelper.CanvasMinY;
                pos=[pos(1)+canvasMinX,pos(2)+canvasMinY,pos(3)+canvasMinX,pos(4)+canvasMinY];
                this.TopModelLayoutManager.removeBlock(portPath);
                name=get_param(portPath,'Name');
                delete_block(portPath);
                portPath=add_block('built-in/SubSystem',...
                [this.slSystemName,'/',name,char(13),'QueuedExplicitSend not supported'],...
                'MakeNameUnique','on',...
                'Position',pos,...
                'BackgroundColor','orange',...
                'MaskDisplay','fprintf('' '')');
                this.positionBlockInLayout(portPath,false);


                warnId='RTW:autosar:unsupportedQueuedDataElement';
                warnParams={m3iData.Name,m3iData.containerM3I.Name};


                messageStream=autosar.mm.util.MessageStreamHandler.instance();
                messageStream.createWarning(warnId,warnParams,...
                portPath,'modelImport');

                portPath=[];
            end

            if strcmp(blockType,'Outport')
                srcBlk=autosar.mm.mm2sl.SLModelBuilder.getOutportSrcBlock(blkPath,'SignalInvalidation');

                if~isempty(srcBlk)&&...
                    (m3iData.InvalidationPolicy==Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.None||...
                    m3iData.InvalidationPolicy==Simulink.metamodel.arplatform.interface.InvalidationPolicyKind.DontInvalidate)
                    this.ChangeLogger.logDeletion('Manual','Block',srcBlk,this.MdlName);
                end
            end
        end




        function createIsUpdatedPortElement(this,dataBlkPath,m3iPort,m3iDataElement,blockType)

            blockName=sprintf('%s%s',get_param(dataBlkPath,'Name'),'_IsUpdated');


            [isUpdatedPath,alreadyExist]=this.createOrUpdateSimulinkInportWithType(...
            this.slSystemName,'boolean',blockType,blockName,m3iPort.variationPoint,...
            m3iPort.Name,[m3iDataElement.Name,'_IsUpdated']);

            if~alreadyExist
                expReadDataHdl=get_param(dataBlkPath,'Handle');
                isUpdatedHdl=get_param(isUpdatedPath,'Handle');
                assert(~this.expReadData2IsUpdatedMap.isKey(expReadDataHdl),...
                'Inport %s has more than one IsUpdated port associated to it.',...
                dataBlkPath);
                this.expReadData2IsUpdatedMap.set(expReadDataHdl,isUpdatedHdl);
            end
        end




        function updateIsUpdatedPortElement(this,dataBlkPath,isUpdatedBlkPath,...
            m3iPort,m3iDataElement,blockType)



            blockName=get_param(isUpdatedBlkPath,'Name');

            [isUpdatedPortPath,objExist]=this.createOrUpdateSimulinkInportWithType(...
            this.slSystemName,'boolean',blockType,blockName,m3iPort.variationPoint,...
            m3iPort.Name,[m3iDataElement.Name,'_IsUpdated']);

            assert(objExist,'Port %s should already exist',isUpdatedPortPath);

            expReadDataHdl=get_param(dataBlkPath,'Handle');
            isUpdatedHdl=get_param(isUpdatedBlkPath,'Handle');
            this.expReadData2IsUpdatedMap.set(expReadDataHdl,isUpdatedHdl);
        end


        function createOrUpdateErrorStatusPortElement(this,dataBlkPath,...
            m3iPort,m3iDataElement,slPortType,isDataPortCreated)

            [isMapped,errorStatusBlkPath]=this.SLMatcher.isErrorStatusPortElementMapped(...
            m3iPort,m3iDataElement,slPortType);
            errorStatusPortAlreadyExists=isMapped;



            if~isDataPortCreated&&~errorStatusPortAlreadyExists
                return
            end

            if isMapped
                blockName=get_param(errorStatusBlkPath,'Name');
            else
                blockName=sprintf('%s%s',get_param(dataBlkPath,'Name'),'_ErrorStatus');
            end


            errorStatusBlkDataType=autosar.api.Utils.getSLTypeForErrorStatusPort(...
            m3iPort,m3iDataElement);
            errorStatusPath=this.createOrUpdateSimulinkInportWithType(...
            this.slSystemName,errorStatusBlkDataType,slPortType,blockName,...
            m3iPort.variationPoint,m3iPort.Name,[m3iDataElement.Name,'_ErrorStatus']);



            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,...
            errorStatusPath,'SampleTime',get_param(dataBlkPath,'SampleTime'));


            expReadDataHdl=get_param(dataBlkPath,'Handle');
            errorStatusHdl=get_param(errorStatusPath,'Handle');
            this.DataInportBlk2ErrorStatusBlkMap.set(expReadDataHdl,errorStatusHdl);
        end

        function[subsystemPath,runnablePath,isCreated]=createRunnable(this,sysName,m3iRun,m3iRunRef,irtRunnableType)


            runnableBuilder=autosar.mm.mm2sl.RunnableBuilderFactory.getBuilder(m3iRun,irtRunnableType,...
            this.ModelPeriodicRunnablesAs,this.ChangeLogger);
            [runnablePath,subsystemPath]=runnableBuilder.create(sysName);
            m3iRunRef.slURL=Simulink.ID.getSID(subsystemPath);


            addedBlocks=runnableBuilder.getAddedBlocks();
            isCreated=any(strcmp(subsystemPath,addedBlocks));
            for blkIdx=1:length(addedBlocks)
                addedBlockPath=addedBlocks{blkIdx};
                addedBlockHandle=get_param(addedBlockPath,'Handle');
                this.addedBlk(addedBlockHandle);





                if~strcmp(get(addedBlockHandle,'BlockType'),'SubSystem')
                    this.positionBlockInLayout(addedBlockPath);
                end
            end

            isIRTRunnable=(irtRunnableType~=autosar.mm.mm2sl.IRTRunnableType.NotAnIRTRunnable);
            if isIRTRunnable
                return
            end


            fcnCallInportBlockPath=autosar.mm.mm2sl.RunnableBuilder.findBlockWithType(addedBlocks,'Inport');
            if~isempty(fcnCallInportBlockPath)
                this.slRunnableFcnCallInport2RefBiMap.setLeft(get_param(fcnCallInportBlockPath,'Handle'),m3iRunRef);
            end

            isPeriodicRun=autosar.mm.mm2sl.RunnableHelper.isInvokedByEvent(m3iRun,...
            Simulink.metamodel.arplatform.behavior.TimingEvent.MetaClass);
            if~slfeature('AUTOSARImportAsAtomicSubsystems')&&~isPeriodicRun
                return
            end


            fcnAtomicSubSystemBlockPath=autosar.mm.mm2sl.RunnableBuilder.findBlockWithType(addedBlocks,'SubSystem');
            if~isempty(fcnAtomicSubSystemBlockPath)
                this.slRunnableSubSystem2RefBiMap.setLeft(get_param(fcnAtomicSubSystemBlockPath,'Handle'),m3iRunRef);
            end
        end

        function[subsystemPath,isCreated]=updateRunnable(this,runnablePath,sysName,m3iRun,m3iRunRef,irtRunnableType)


            runnableBuilder=autosar.mm.mm2sl.RunnableBuilderFactory.getBuilder(m3iRun,irtRunnableType,...
            this.ModelPeriodicRunnablesAs,this.ChangeLogger);
            subsystemPath=runnableBuilder.update(runnablePath,sysName);


            addedBlocks=runnableBuilder.getAddedBlocks();
            isCreated=any(strcmp(subsystemPath,addedBlocks));
            for blkIdx=1:length(addedBlocks)
                addedBlockPath=addedBlocks{blkIdx};
                addedBlockHandle=get_param(addedBlockPath,'Handle');
                this.addedBlk(addedBlockHandle);
                if~strcmp(get(addedBlockHandle,'BlockType'),'SubSystem')
                    this.positionBlockInLayout(addedBlockHandle);
                end
            end


            fcnCallInportBlockPath=autosar.mm.mm2sl.RunnableBuilder.findBlockWithType(addedBlocks,'Inport');
            if~isempty(fcnCallInportBlockPath)
                this.slRunnableFcnCallInport2RefBiMap.setLeft(get_param(fcnCallInportBlockPath,'Handle'),m3iRunRef);
            end
        end




        function portPath=createModeElement(this,m3iPort,m3iModeGroup,blockType)
            blockName=[m3iPort.Name,'_',m3iModeGroup.Name];

            portPath=this.createOrUpdateSimulinkInportWithType(...
            this.slSystemName,...
            ['Enum: ',m3iModeGroup.ModeGroup.Name],...
            blockType,blockName,m3iPort.variationPoint,...
            m3iPort.Name,m3iModeGroup.Name);
        end





        function portPath=updateModeElement(this,blkPath,m3iPort,m3iModeGroup,blockType)

            blockName=get_param(blkPath,'Name');

            [portPath,objExist]=this.createOrUpdateSimulinkInportWithType(...
            this.slSystemName,...
            ['Enum: ',m3iModeGroup.ModeGroup.Name],...
            blockType,blockName,m3iPort.variationPoint,...
            m3iPort.Name,m3iModeGroup.Name);
            assert(objExist,'Port %s should already exist',portPath);
        end


        function createPortOperation(this,sys,m3iPort,m3iOperation)
            assert(~isempty(sys),'target system should not be empty');

            fcnCallerHelper=autosar.mm.util.FcnCallerHelper(this.ChangeLogger,this.SysConstsValueMap);
            fcnCallerHelper.createWorkspaceObjects(m3iOperation,this.slTypeBuilder,this.slParameterBuilder);

            bswImpl=autosar.bsw.ServiceComponent.getBswCallerImplementation(m3iOperation);
            isBswCall=slfeature('BswImportSupport')&&~isempty(bswImpl);
            if isBswCall
                blockType=bswImpl.getLibraryBlk();
            else
                blockType=fcnCallerHelper.getBlkType();
            end

            blkName=[m3iPort.Name,'_',m3iOperation.Name];
            [blkPath,alreadyExists]=this.createOrUpdateSimulinkBlock(sys,...
            blockType,blkName,[],[],{});

            this.addFunctionPort(sys,'Client',m3iPort,m3iOperation);

            if isBswCall
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blkPath,...
                'Operation',m3iOperation.Name,...
                'PortName',m3iPort.Name);


                hasArgument=bswImpl.hasArgumentSpecificationParameter();
                hasDataType=bswImpl.hasDatatypeParameter();
                if hasArgument||hasDataType
                    dtOrArgSpec=fcnCallerHelper.getDataTypeOrArgumentSpec(m3iOperation,this.SysConstsValueMap);
                    if bswImpl.hasDatatypeParameter()&&~isempty(bswImpl.EnumDatatypeMap(m3iOperation.Name))
                        autosar.mm.mm2sl.SLModelBuilder.set_param(...
                        this.ChangeLogger,blkPath,...
                        'Datatype',['Enum: ',class(eval(dtOrArgSpec))]);
                    elseif bswImpl.hasArgumentSpecificationParameter()&&~isempty(bswImpl.ArgSpecMap(m3iOperation.Name))
                        autosar.mm.mm2sl.SLModelBuilder.set_param(...
                        this.ChangeLogger,blkPath,...
                        'ArgumentSpecification',dtOrArgSpec);
                    end
                end
            else
                if~alreadyExists

                    set_param(blkPath,'FunctionPrototype','y_toBeRenamed = f(u_toBeRenamed)');
                end
                fcnCallerHelper.syncBlk(blkPath,m3iOperation,m3iPort);
            end

            if~alreadyExists

                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(blkPath);
            end


            slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(m3iOperation.desc);
            if~isempty(slDesc)
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blkPath,'Description',slDesc);
            end

            opKey=[m3iPort.Name,'/',m3iOperation.Name];
            this.slCallerOp2PortNameMap.set(opKey,m3iPort.Name);
        end

        function fcnPortPath=addFunctionPort(this,sysName,portDirection,m3iPort,m3iOperation)
            fcnPortPath=[];
            if~(isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceProvidedPort')||...
                isa(m3iPort,'Simulink.metamodel.arplatform.port.ServiceRequiredPort'))

                return;
            end

            switch portDirection
            case 'Client'
                blkType='simulink/Sources/In Bus Element';
            case 'Server'
                blkType='simulink/Sinks/Out Bus Element';
            otherwise
                assert(false,'Unexpected port direction');
            end
            arPortName=m3iPort.Name;
            arOpName=m3iOperation.Name;
            blkName=[arPortName,'_',arOpName,'_',portDirection];
            busPortConfig={'PortName',arPortName,'Element',arOpName,...
            'AllowServiceAccess','on','IsClientServer','on'};
            blockDataType=[];
            position=[];
            fcnPortPath=this.createOrUpdateSimulinkBlock(sysName,blkType,...
            blkName,blockDataType,position,busPortConfig);
            autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(fcnPortPath);
        end

        function slFcnPath=createServerFunction(this,sysName,m3iPort,m3iMethod)

            slFcnBuilder=autosar.mm.mm2sl.AdaptiveSimulinkFunctionBuilder(m3iPort,m3iMethod,...
            this.ChangeLogger);
            slFcnPath=slFcnBuilder.create(sysName);
            fcnPortPath=this.addFunctionPort(sysName,...
            'Server',m3iPort,m3iMethod);


            addedBlocks=slFcnBuilder.getAddedBlocks();
            if~isempty(fcnPortPath)
                addedBlocks{end+1}=fcnPortPath;
            end
            for blkIdx=1:length(addedBlocks)
                addedBlockPath=addedBlocks{blkIdx};
                addedBlockHandle=get_param(addedBlockPath,'Handle');
                this.addedBlk(addedBlockHandle);

                isCentral=false;
                isServer=strcmp(addedBlockPath,slFcnPath);
                this.positionBlockInLayout(addedBlockPath,isCentral,isServer);
            end


            if~isempty(slFcnPath)
                this.slSLFcn2PortMethodMap.set(get_param(slFcnPath,'Handle'),{m3iPort.Name,m3iMethod.Name});
            end
        end

        function updateInternalTriggerPoint(this,blkPaths,m3iTrigPoint,m3iTriggeredRun,...
            m3iTriggeringRun)
            assert(length(blkPaths)==1,...
            'Triggering point %s should not be mapped to multiple caller blocks!',...
            m3iTrigPoint.Name);



            slFcnName=m3iTriggeredRun.symbol;

            blkPath=blkPaths{1};
            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blkPath,...
            'FunctionName',slFcnName,...
            'InternalTriggeringPointName',m3iTrigPoint.Name);

            this.InternalTrigBlk2TriggeringRunMap.set(get_param(blkPath,'handle'),...
            m3iTriggeringRun.symbol);
        end

        function blkPath=createInternalTriggerPoint(this,m3iTrigPoint,...
            m3iTriggeredRun,m3iTriggeringRun,triggeringRunPath)

            internalTrigBockPath=autosar.blocks.InternalTriggerBlock.LibBlockPath;
            blkName=[m3iTriggeredRun.Name,'_',m3iTrigPoint.Name];
            [blkPath,alreadyExists]=this.createOrUpdateSimulinkBlock(triggeringRunPath,...
            internalTrigBockPath,blkName,[],[],{});



            slFcnName=m3iTriggeredRun.symbol;
            autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,blkPath,...
            'FunctionName',slFcnName,...
            'InternalTriggeringPointName',m3iTrigPoint.Name);

            if~alreadyExists

                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlock(blkPath);
            end

            this.InternalTrigBlk2TriggeringRunMap.set(get_param(blkPath,'handle'),...
            m3iTriggeringRun.symbol);
        end

        function updatePortOperation(this,blks,m3iPort,m3iOperation)

            isBSWCallerBlock=autosar.bsw.BasicSoftwareCaller.isBSWCallerBlock(blks{1});
            if isBSWCallerBlock

                return
            end

            fcnCallerHelper=autosar.mm.util.FcnCallerHelper(this.ChangeLogger,this.SysConstsValueMap);
            fcnCallerHelper.createWorkspaceObjects(m3iOperation,this.slTypeBuilder,this.slParameterBuilder);

            for ii=1:length(blks)
                fcnCallerHelper.syncBlk(blks{ii},m3iOperation,m3iPort);
            end

        end

        function slFcnPath=updateServerFunction(this,slFcnPath,m3iPort,m3iMethod)

            slFcnBuilder=autosar.mm.mm2sl.AdaptiveSimulinkFunctionBuilder(m3iPort,m3iMethod,...
            this.ChangeLogger);
            slFcnBuilder.update(slFcnPath,sysName);


            addedBlocks=runnableBuilder.getAddedBlocks();
            for blkIdx=1:length(addedBlocks)
                addedBlockPath=addedBlocks{blkIdx};
                addedBlockHandle=get_param(addedBlockPath,'Handle');
                this.addedBlk(addedBlockHandle);
                if~strcmp(get(addedBlockHandle,'BlockType'),'SubSystem')
                    this.positionBlockInLayout(addedBlockHandle);
                end
            end


            if~isempty(slFcnPath)
                this.slSLFcn2PortMethodMap.set(get_param(slFcnPath,'Handle'),{m3iPort.Name,m3iMethod.Name});
            end
        end




        function[portPath,alreadyExists]=createOrUpdateSimulinkInportWithType(...
            this,sys,portDataTypeStr,portBlkType,portName,variationPoint,...
            arPortName,arElementName)

            paramValuePair={'PortDimensions','1','SignalType','real'};
            if any(strcmp(portBlkType,{'In Bus Element','Out Bus Element'}))
                paramValuePair=[...
                {'PortName',arPortName,'Element',arElementName}...
                ,paramValuePair];
            end

            if any(strcmp(portBlkType,{'ArgIn','ArgOut'}))

                searchTerms={'ArgumentName',portName};
            else
                searchTerms={};
            end

            [portPath,alreadyExists]=this.createOrUpdateSimulinkBlock(...
            sys,portBlkType,portName,portDataTypeStr,[],...
            paramValuePair,searchTerms{:});

            if~alreadyExists
                this.BlockVariantBuilder.addVariantForBlock(portPath,portBlkType,variationPoint);
            end

            switch portBlkType
            case{'ArgIn','ArgOut'}

            otherwise
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,portPath,...
                'BusOutputAsStruct','off',...
                'SamplingMode','Sample based');
            end
        end




        function[portName,alreadyExists]=createOrUpdateSimulinkPortWithType(this,aParent,...
            m3iType,portDirection,aDataPortName,...
            variationPoint,m3iDesc,arPortName,arElementName)


            slDesignData=this.slTypeBuilder.getSLDesignData(m3iType);


            typename=cellstr(slDesignData.DataTypeStr);


            if m3iType.isvalid()
                m3iBaseType=autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(m3iType);
                if autosar.mm.util.BuiltInTypeMapper.isARBuiltIn(m3iBaseType)
                    altTypename=this.getSLBuiltInName(m3iType);
                    if~strcmp(typename,altTypename)
                        typename=[typename,altTypename];
                    end
                end
            end

            if any(strcmp(portDirection,{'ArgIn','ArgOut'}))



                searchTerms={'ArgumentName',aDataPortName};
            else
                searchTerms={};
            end

            if any(strcmp(portDirection,{'simulink/Sources/In Bus Element','simulink/Sinks/Out Bus Element'}))
                paramValuePair={'PortName',arPortName,'Element',arElementName};
            else
                paramValuePair={};
            end
            [portName,alreadyExists]=this.createOrUpdateSimulinkBlock(...
            aParent,portDirection,aDataPortName,typename,[],paramValuePair,searchTerms{:});

            if isempty(portName)
                return
            end


            assert(isempty(m3iDesc)||isa(m3iDesc,'Simulink.metamodel.arplatform.documentation.MultiLanguageOverviewParagraph'),...
            'Expected m3iDesc to be Simulink.metamodel.arplatform.documentation.MultiLanguageOverviewParagraph');
            slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(m3iDesc);
            if~isempty(slDesc)
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,portName,'Description',slDesc);
            end

            if~alreadyExists
                this.BlockVariantBuilder.addVariantForBlock(portName,portDirection,variationPoint);
            end

            dims=slDesignData.Dimensions;
            if(dims==1)
                actDims=slResolve(get_param(portName,'PortDimensions'),portName);
                if actDims~=1
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,portName,'PortDimensions','1');
                end
            else
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,portName,...
                'PortDimensions',num2str(slDesignData.Dimensions));
            end

            if m3iType.isvalid()&&m3iBaseType.isvalid()&&...
                isa(m3iBaseType,'Simulink.metamodel.types.Structure')
                busOutputAsStructMode='on';
            else
                busOutputAsStructMode='off';
            end

            dataType=get_param(portName,'OutDataTypeStr');
            isBusTyped=startsWith(dataType,'Bus:');
            isBusPort=autosar.composition.Utils.isCompositePortBlock(portName);
            if~isBusTyped
                autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,portName,'SignalType','real');
            end

            if isBusTyped&&isBusPort&&slfeature('CompositePortsNonvirtualBusSupport')>0

                autosar.simulink.bep.Utils.setParam(portName,false,'Virtuality','nonvirtual');
            end

            switch portDirection
            case{'ArgIn','ArgOut'}

            otherwise
                if~isBusPort
                    autosar.mm.mm2sl.SLModelBuilder.set_param(this.ChangeLogger,portName,...
                    'BusOutputAsStruct',busOutputAsStructMode,...
                    'SamplingMode','Sample based');
                end
            end


            if m3iType.isvalid()&&m3iType.IsApplication&&~isBusTyped
                this.setAppTypeAttributesOnPort(portName,slDesignData.Min,slDesignData.Max);
            end
        end

        function setAppTypeAttributesOnPort(this,portName,slMin,slMax)

            if isempty(slMin)
                minValStr='[]';
            else
                minValStr=slMin;
            end

            if isempty(slMax)
                maxValStr='[]';
            else
                maxValStr=slMax;
            end

            autosar.mm.mm2sl.SLModelBuilder.set_param(...
            this.ChangeLogger,portName,...
            'OutMin',minValStr,...
            'OutMax',maxValStr);
        end

        function slTypeName=getSLBuiltInName(this,m3iType)


            oldKeepSLObj=this.slTypeBuilder.keepSLObj;
            this.slTypeBuilder.keepSLObj=false;
            slTypeName=this.slTypeBuilder.getSLBlockDataTypeStr(m3iType);
            this.slTypeBuilder.keepSLObj=oldKeepSLObj;
        end

        function cleanupObj=forceAutomatedBlkAdditions(this)


            userUpdateMode=this.UpdateMode;
            this.UpdateMode=false;

            cleanupObj=onCleanup(@()resetUpdateModel(this,userUpdateMode));
            function this=resetUpdateModel(this,userUpdateMode)
                this.UpdateMode=userUpdateMode;
            end

        end

        function addedBlk(this,blk)
            this.AddedBlks=[this.AddedBlks,blk];
        end

        function isAddedBlk=isAddedBlk(this,blkH)
            isAddedBlk=any(blkH==[this.AddedBlks{:}]);
        end

        function markAddedBlks(this)


            addedBlocks=this.AddedBlks;
            blockTypes=strcmp(cellfun(@(x)get_param(x,'BlockType'),addedBlocks,...
            'UniformOutput',false),'AsynchronousTaskSpecification');
            addedBlocks=[addedBlocks(blockTypes),addedBlocks(~blockTypes)];

            for ii=1:length(addedBlocks)
                blk=addedBlocks{ii};
                this.homeBlocksWithType(blk,{'Inport','Outport','AsynchronousTaskSpecification'});
                autosar.mm.mm2sl.SLModelBuilder.createAddedBlockSimulinkArea(blk);
            end
            this.AddedBlks={};
        end

        function ret=isAdaptiveModel(this)
            ret=strcmp(...
            get_param(this.MdlName,'SystemTargetFile'),...
            'autosar_adaptive.tlc');
        end
    end

    methods(Static)


        dstPortH=getAllDestinationPortsThroughVirtualBlocks(srcBlk);

        function createAddedBlockSimulinkArea(blkH)

            greenColor='[0.956863, 0.980392, 0.921569]';
            autosar.mm.mm2sl.SLModelBuilder.createSimulinkArea(blkH,greenColor,'Added blocks');
        end

        function createDeleteBlockSimulinkArea(blkH)

            redColor='[0.992157, 0.937255, 0.913725]';
            autosar.mm.mm2sl.SLModelBuilder.createSimulinkArea(blkH,redColor,'Delete block');
        end

        function createAddedLineSimulinkArea(lineH)

            greenColor='[0.956863, 0.980392, 0.921569]';
            autosar.mm.mm2sl.SLModelBuilder.createSimulinkArea(lineH,greenColor,'Added lines');
        end

        function blockName=getSLBlockNameForPortElement(m3iPort,m3iData,blockType)
            suffix='';
            if isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedRequiredPort')
                if strcmp(blockType,'Inport')
                    suffix='_read';
                else
                    suffix='_write';
                end
            end
            blockName=sprintf('%s_%s%s',m3iPort.Name,m3iData.Name,suffix);
        end



        function set_param(changeLogger,blk,varargin)

            assert(isa(changeLogger,'autosar.updater.ChangeLogger'),'Expected a change logger');

            if isempty(blk)
                return
            end


            switch get_param(blk,'type')
            case 'block_diagram'
                blockType='model';
            case 'block'
                blockType=get_param(blk,'BlockType');
            otherwise
                assert(false,'Do not recognize block type %s',get_param(blk,'type'));
            end



            isModifiable=true;
            if strcmp(blockType,'model')
                if isa(getActiveConfigSet(blk),'Simulink.ConfigSetRef')
                    isModifiable=false;
                end
            end

            if isModifiable
                modificationType='Automatic';
            else
                modificationType='Manual';
            end

            isModified=false;
            numParams=length(varargin)/2;
            for ii=1:numParams
                param=varargin{ii*2-1};
                newValueStr=varargin{ii*2};
                oldValueStr=get_param(blk,param);

                isSampleTimeProp=strcmp(param,'SampleTimeProperty');
                isPosition=strcmp(param,'Position');

                assert(((ischar(newValueStr)||isStringScalar(newValueStr))&&(ischar(oldValueStr)||isStringScalar(oldValueStr)))||...
                isSampleTimeProp||isPosition,...
                'Expected a string, position or SampleTimeProperty structure');

                isNumericValue=~isPosition&&~isSampleTimeProp&&~isnan(str2double(newValueStr));
                if isNumericValue

                    newValue=str2double(newValueStr);
                    oldValue=str2double(oldValueStr);
                    if isempty(oldValue)

                        [objExists,oldValue]=autosar.utils.Workspace.objectExistsInModelScope(bdroot(blk),oldValueStr);
                        if~objExists

                            newValue=newValueStr;
                            oldValue=oldValueStr;
                        end
                    end
                elseif isSampleTimeProp
                    newValueStr=autosar.mm.mm2sl.SLModelBuilder.convertSampleTimePropertyToString(newValueStr);
                    oldValueStr=autosar.mm.mm2sl.SLModelBuilder.convertSampleTimePropertyToString(oldValueStr);
                    newValue=newValueStr;
                    oldValue=oldValueStr;
                elseif isPosition
                    newValueStr=mat2str(newValueStr);
                    oldValueStr=mat2str(oldValueStr);
                    newValue=newValueStr;
                    oldValue=oldValueStr;
                else
                    newValue=newValueStr;
                    oldValue=oldValueStr;
                end


                if strcmp(oldValue,'<Enter example>')
                    oldValue='';
                end

                if~isequal(newValue,oldValue)||~strcmp(class(newValue),class(oldValue))
                    changeLogger.logModification(modificationType,param,blockType,getfullname(blk),oldValueStr,newValueStr);
                    isModified=true;
                end
            end

            if isModified&&isModifiable
                isBusElementPort=~strcmp(blockType,'model')&&...
                any(strcmp(get_param(blk,'BlockType'),{'Inport','Outport'}))&&...
                strcmp(get_param(blk,'IsBusElementPort'),'on');
                if isBusElementPort
                    autosar.simulink.bep.Utils.setParam(blk,false,varargin{:});
                else
                    set_param(blk,varargin{:});
                end
            end
        end



        function[blkH,blkName]=findSimulinkBlock(sys,blkType,blkName,varargin)
            sys=get_param(sys,'Handle');
            isArgumentBlock=any(strcmp(blkType,{'ArgIn','ArgOut'}));
            if isempty(blkName)||isArgumentBlock
                argParser=inputParser();
                argParser.KeepUnmatched=true;
                argParser.addParameter('ArgumentName',blkType,...
                @(x)(ischar(x)||isStringScalar(x)));
                argParser.parse(varargin{:});

                blkName=argParser.Results.ArgumentName;

                blkH=find_system(sys,'SearchDepth',1,'FollowLinks','on',...
                'LookUnderMasks','all','BlockType',blkType,varargin{:});

                if~isempty(blkH)
                    blkName=get_param(blkH(1),'Name');
                end
            else
                blkH=find_system(sys,'SearchDepth',1,'FollowLinks','on',...
                'LookUnderMasks','all','BlockType',blkType,...
                'Name',blkName,varargin{:});
            end
        end


        function isQueued=isQueuedPort(portInfo)


            if isempty(portInfo)
                isQueued=false;
                return;
            end

            try
                if isempty(portInfo.comSpec)
                    isQueued=false;
                    return;
                end
            catch err
                if strcmp(err.identifier,'MATLAB:noSuchMethodOrField')
                    isQueued=false;
                    return;
                else
                    rethrow(err)
                end
            end

            isQueued=isa(portInfo.comSpec,'Simulink.metamodel.arplatform.port.DataSenderQueuedPortComSpec')||...
            isa(portInfo.comSpec,'Simulink.metamodel.arplatform.port.DataReceiverQueuedPortComSpec');
        end

        function markBlkDeletion(blkPath)

            autosar.mm.mm2sl.SLModelBuilder.createDeleteBlockSimulinkArea(blkPath);
        end
    end

    methods(Static,Access=private)


        srcBlock=getOutportSrcBlock(outBlk,srcBlkType)



        function isCanInvalidateSupported=isCanInvalidateSupported(m3iPort,m3iDataElement,accessKindStr)
            isNvPort=autosar.api.Utils.isNvPort(m3iPort);
            isCanInvalidateSupported=false;
            if~isNvPort&&isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedPort')
                portInfo=autosar.mm.Model.findPortInfo(m3iPort,m3iDataElement,'DataElements');
                if~isempty(portInfo)&&~isempty(portInfo.comSpec)&&...
                    isa(portInfo.comSpec,'Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec')&&...
                    strcmp(accessKindStr,'ExplicitWrite')
                    dataElementInvalidationPolicy=m3iDataElement.InvalidationPolicy.toString();
                    isCanInvalidateSupported=any(strcmp(dataElementInvalidationPolicy,{'Replace','Keep'}));
                end
            end
        end

        function homeBlocksWithType(blkH,blockTypes)


            switch(get_param(blkH,'BlockType'))
            case blockTypes
                blkPath=getfullname(blkH);
                if strcmp(bdroot(blkPath),fileparts(blkPath))
                    numConnections=autosar.mm.mm2sl.MRLayoutManager.numConnections(blkH);
                    if numConnections==1
                        autosar.mm.mm2sl.MRLayoutManager.homeBlk(blkH);
                    end
                end
            end
        end

        function createSimulinkArea(sysH,color,txt)



            if~strcmp(get_param(sysH,'Type'),'line')&&...
                strcmp(get_param(sysH,'StaticLinkStatus'),'implicit')



                return
            end

            sysType=get_param(sysH,'Type');
            switch(sysType)
            case 'line'
                lineH=sysH;
                points=get_param(lineH,'Points');
                numSegments=size(points,1)/2;
                if numSegments==1

                    segmentPos=points;
                else


                    segIdx=numSegments;
                    segmentPos=points(2*segIdx-1:2*segIdx,:);
                    if segmentPos(2)-segmentPos(1)<15


                        segIdx=(numSegments-1);
                        segmentPos=points(2*segIdx-1:2*segIdx,:);
                    end
                end
                p=[segmentPos(1),segmentPos(3),segmentPos(2),segmentPos(4)];

                offset=5;
                x=p(1);
                y=p(2)-offset;
                w=p(3)-p(1);
                h=p(4)-p(2)+offset*2;

                posArea=[x,y,x+w,y+h];



                dstBlkName=get_param(get_param(lineH,'DstBlockHandle'),'Name');
                dstPort=get_param(lineH,'DstPort');
                areaName=[get_param(lineH,'Parent'),'/'...
                ,dstBlkName,'_',dstPort,'_area'];
            case 'block'
                blkPath=getfullname(sysH);
                p=get_param(blkPath,'Position');

                offset=27;
                x=p(1)-offset;
                y=p(2)-offset;
                w=p(3)-p(1)+offset*2;
                h=p(4)-p(2)+offset*2;

                posArea=[x,y,x+w,y+h];
                areaName=[blkPath,'_area'];
            otherwise
                assert(false,'createSimulinkArea does not support system type: %s.',sysType);
            end
            add_block('built-in/Area',areaName,'Position',...
            posArea,'Text',txt,'FontSize',9,...
            'ForegroundColor',color);
        end



        function name=getSimulinkNameOf(slURL,defaultName)
            try
                name=get_param(Simulink.ID.getHandle(slURL),'Name');
            catch Me %#ok<NASGU>

                name=defaultName;
            end
        end



        function block=getBlockFromSSPort(port)
            try
                parent=get_param(port,'Parent');
                ptype=get_param(port,'PortType');
                pn=get_param(port,'PortNumber');
                switch ptype
                case 'inport'
                    blockType='Inport';
                case 'outport'
                    blockType='Outport';
                case 'trigger'
                    blockType='TriggerPort';

                otherwise
                    blockType=[];
                end
                blocks=find_system(parent,'SearchDepth',1,...
                'FollowLinks','on','LookUnderMasks','all',...
                'type','block','BlockType',blockType);
                block=blocks{pn};
            catch me %#ok<NASGU>

                block=[];
            end
        end



        function port=getSSPortFromBlock(blk)
            try
                parent=get_param(blk,'Parent');
                ph=get_param(parent,'PortHandles');
                switch lower(get_param(blk,'BlockType'))
                case 'inport'
                    pn=sscanf(get_param(blk,'Port'),'%d');
                    port=ph.Inport(pn);
                case 'outport'
                    pn=sscanf(get_param(blk,'Port'),'%d');
                    port=ph.Outport(pn);
                case 'triggerport'
                    port=ph.Trigger(1);

                otherwise
                    port=[];
                end

            catch me %#ok<NASGU>

                port=[];
            end
        end



        function objH=getHandleFromID(slURL)
            [objH,~,~,~,~]=Simulink.ID.getHandle(slURL);
        end



        function slH=getHandle(slEntity)
            if ishandle(slEntity)
                slH=slEntity;
            elseif ischar(slEntity)||isStringScalar(slEntity)
                slH=get_param(slEntity,'Handle');
            elseif iscellstr(slEntity)||isstring(slEntity)
                slH=cell2mat(get_param(slEntity,'Handle'));
            else
                slH=[];
            end
        end







        function slPath=getFullName(slEntity)
            if ishandle(slEntity)
                slPath=getfullname(slEntity);
            elseif(ischar(slEntity)||isStringScalar(slEntity))||...
                (iscellstr(slEntity)||isstring(slEntity))
                slPath=slEntity;
            else
                slPath='';
            end
        end

        function path=removeModelName(modelName,path)

            path=regexprep(path,['^',modelName,'/'],'');

        end







        function stPropStr=convertSampleTimePropertyToString(stProp)
            stPropStr='[';
            for i=1:length(stProp)
                curStr=['[',stProp(i).SampleTime,',',stProp(i).Offset,',',...
                num2str(stProp(i).Priority),'];'];
                stPropStr=strcat(stPropStr,curStr);
            end
            stPropStr=strcat(stPropStr,']');
        end

    end

end






