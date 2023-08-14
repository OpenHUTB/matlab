classdef ComSpecBuilder<handle






    properties(Constant,Access=public)
        DataAccessModesWithoutComSpec={'IsUpdated'
'ErrorStatus'
'ModeReceive'
        'ModeSend'}
    end

    methods(Static,Access=public)
        function addOrUpdateM3IComSpec(ARPortName,ARDataElementName,ARDataAccessModeStr,modelName)



            if ismember(ARDataAccessModeStr,autosar.mm.sl2mm.ComSpecBuilder.DataAccessModesWithoutComSpec)||...
                isempty(ARPortName)||isempty(ARDataElementName)


                return
            end

            m3iInfo=autosar.mm.sl2mm.ComSpecBuilder.findOrCreateM3IInfo(...
            ARPortName,ARDataElementName,ARDataAccessModeStr,modelName);
            if isempty(m3iInfo)


                return
            end
            if autosar.api.Utils.isNvPort(m3iInfo.containerM3I)
                m3iComSpec=m3iInfo.ComSpec;
            else
                m3iComSpec=m3iInfo.comSpec;
            end

            if~isempty(m3iComSpec)



                needToCreateNewComSpec=...
                autosar.mm.sl2mm.ComSpecBuilder.checkOrUpdateM3IComSpecAgainstDataAccessMode(m3iComSpec,ARDataAccessModeStr);
            else


                needToCreateNewComSpec=true;
            end

            if needToCreateNewComSpec


                autosar.mm.sl2mm.ComSpecBuilder.createNewM3IComSpec(m3iInfo,ARDataAccessModeStr);
            end
        end

        function checkAndGenerateComSpecsForMappedDataElements(modelMapping)



            for i=1:length(modelMapping.Inports)
                ARPortName=modelMapping.Inports(i).MappedTo.Port;
                ARDataElement=modelMapping.Inports(i).MappedTo.Element;
                ARDataAccessMode=modelMapping.Inports(i).MappedTo.DataAccessMode;
                modelName=bdroot(modelMapping.Inports(i).Block);
                autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(ARPortName,...
                ARDataElement,ARDataAccessMode,modelName);
            end
            for i=1:length(modelMapping.Outports)
                ARPortName=modelMapping.Outports(i).MappedTo.Port;
                ARDataElement=modelMapping.Outports(i).MappedTo.Element;
                ARDataAccessMode=modelMapping.Outports(i).MappedTo.DataAccessMode;
                modelName=bdroot(modelMapping.Outports(i).Block);
                autosar.mm.sl2mm.ComSpecBuilder.addOrUpdateM3IComSpec(ARPortName,...
                ARDataElement,ARDataAccessMode,modelName);
            end
        end

    end

    methods(Static,Access=private)

        function m3iInfo=findOrCreateM3IInfo(ARPortName,ARDataElementName,ARDataAccessModeStr,modelName)



            m3iComp=autosar.api.Utils.m3iMappedComponent(modelName);
            m3iPort=autosar.ui.comspec.ComSpecUtils.findM3IPortByName(m3iComp,ARPortName);
            if isempty(m3iPort)||autosar.api.Utils.isMsPort(m3iPort)
                m3iInfo=[];
                return
            end

            isInport=autosar.mm.sl2mm.ComSpecBuilder.isInportFromDataAccessMode(ARDataAccessModeStr);
            isNvPort=autosar.api.Utils.isNvPort(m3iPort);

            m3iInfo=autosar.ui.comspec.ComSpecUtils.findM3IPortInfoForDataElement(m3iPort,ARDataElementName,isInport);

            if isempty(m3iInfo)

                m3iModel=m3iPort.rootModel;
                trans=M3I.Transaction(m3iModel);
                if isInport
                    if isNvPort
                        m3iInfo=Simulink.metamodel.arplatform.port.NvDataReceiverPortInfo(m3iModel);
                    else
                        m3iInfo=Simulink.metamodel.arplatform.port.DataReceiverPortInfo(m3iModel);
                    end
                else
                    if isNvPort
                        m3iInfo=Simulink.metamodel.arplatform.port.NvDataSenderPortInfo(m3iModel);
                    else
                        m3iInfo=Simulink.metamodel.arplatform.port.DataSenderPortInfo(m3iModel);
                    end
                end

                for ii=1:m3iPort.Interface.DataElements.size()
                    if strcmp(ARDataElementName,m3iPort.Interface.DataElements.at(ii).Name)
                        m3iInfo.DataElements=m3iPort.Interface.DataElements.at(ii);
                        break;
                    end
                end
                if autosar.api.Utils.isNvPort(m3iPort)
                    m3iPort.Info.append(m3iInfo);
                else
                    m3iPort.info.append(m3iInfo);
                end
                trans.commit();
            end
        end

        function isInport=isInportFromDataAccessMode(ARDataAccessModeStr)

            switch ARDataAccessModeStr
            case{'ImplicitReceive','ExplicitReceive',...
                'ExplicitReceiveByVal','QueuedExplicitReceive',...
                'EndToEndRead','EndToEndQueuedReceive'}
                isInport=true;
            case{'ImplicitSend','ImplicitSendByRef',...
                'ExplicitSend','QueuedExplicitSend','EndToEndWrite',...
                'EndToEndQueuedSend'}
                isInport=false;
            otherwise
                assert(false,'Unsupported data access mode');
            end
        end

        function needToCreateM3IComSpec=checkOrUpdateM3IComSpecAgainstDataAccessMode(m3iComSpec,ARDataAccessModeStr)






            needToCreateM3IComSpec=false;

            isInport=autosar.mm.sl2mm.ComSpecBuilder.isInportFromDataAccessMode(ARDataAccessModeStr);
            if isInport

                switch ARDataAccessModeStr
                case{'QueuedExplicitReceive','EndToEndQueuedReceive'}

                    if~isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverQueuedPortComSpec')
                        needToCreateM3IComSpec=true;
                    end
                otherwise

                    if~(isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec')||...
                        isa(m3iComSpec,'Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec'))
                        needToCreateM3IComSpec=true;
                    end
                end
            else
                switch ARDataAccessModeStr
                case{'QueuedExplicitSend','EndToEndQueuedSend'}

                    if~isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataSenderQueuedPortComSpec')
                        needToCreateM3IComSpec=true;
                    end
                otherwise

                    if~(isa(m3iComSpec,'Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec')||...
                        isa(m3iComSpec,'Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec'))
                        needToCreateM3IComSpec=true;
                    end
                end
            end
        end

        function createNewM3IComSpec(m3iInfo,ARDataAccessModeStr)




            m3iModel=m3iInfo.modelM3I;
            trans=M3I.Transaction(m3iModel);

            m3iPort=m3iInfo.containerM3I;
            isInport=autosar.mm.sl2mm.ComSpecBuilder.isInportFromDataAccessMode(ARDataAccessModeStr);
            if autosar.api.Utils.isNvPort(m3iPort)

                if m3iInfo.ComSpec.isvalid()
                    m3iInfo.ComSpec.destroy();
                end

                if isInport
                    m3iInfo.ComSpec=Simulink.metamodel.arplatform.port.NvDataReceiverPortComSpec(m3iModel);
                    autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                    m3iInfo.ComSpec,'InitValue',autosar.ui.comspec.ComSpecPropertyHandler.DefaultInitValue);
                else
                    m3iInfo.ComSpec=Simulink.metamodel.arplatform.port.NvDataSenderPortComSpec(m3iModel);
                    autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                    m3iInfo.ComSpec,'InitValue',autosar.ui.comspec.ComSpecPropertyHandler.DefaultInitValue);
                end
            else

                if m3iInfo.comSpec.isvalid()
                    m3iInfo.comSpec.destroy();
                end
                if isInport

                    switch ARDataAccessModeStr
                    case{'QueuedExplicitReceive','EndToEndQueuedReceive'}

                        m3iInfo.comSpec=Simulink.metamodel.arplatform.port.DataReceiverQueuedPortComSpec(m3iModel);
                        m3iInfo.comSpec.QueueLength=autosar.ui.comspec.ComSpecPropertyHandler.DefaultQueueLength;
                    case{'ImplicitReceive','ExplicitReceive',...
                        'ExplicitReceiveByVal','EndToEndRead'}

                        m3iInfo.comSpec=Simulink.metamodel.arplatform.port.DataReceiverNonqueuedPortComSpec(m3iModel);
                        m3iInfo.comSpec.AliveTimeout=autosar.ui.comspec.ComSpecPropertyHandler.DefaultAliveTimeout;
                        autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                        m3iInfo.comSpec,'InitValue',autosar.ui.comspec.ComSpecPropertyHandler.DefaultInitValue);
                    otherwise
                        assert(false,'Unsupported data access mode');
                    end
                else
                    switch ARDataAccessModeStr
                    case{'QueuedExplicitSend','EndToEndQueuedSend'}

                        m3iInfo.comSpec=Simulink.metamodel.arplatform.port.DataSenderQueuedPortComSpec(m3iModel);
                    case{'ImplicitSend','ImplicitSendByRef',...
                        'ExplicitSend','EndToEndWrite'}

                        m3iInfo.comSpec=Simulink.metamodel.arplatform.port.DataSenderNonqueuedPortComSpec(m3iModel);
                        autosar.ui.comspec.ComSpecPropertyHandler.setComSpecPropertyValue(...
                        m3iInfo.comSpec,'InitValue',autosar.ui.comspec.ComSpecPropertyHandler.DefaultInitValue);
                    otherwise
                        assert(false,'Unsupported data access mode');
                    end
                end
            end
            trans.commit();
        end

    end
end


