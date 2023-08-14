





function populatePortsMapping(self,slPort2RefBiMap,slPort2AccessMap)

    persistent accessKind2Str;

    if isempty(accessKind2Str)
        accessKind2Str=containers.Map(...
        {...
        Simulink.metamodel.arplatform.behavior.DataAccessKind.ImplicitRead.toString(),...
        Simulink.metamodel.arplatform.behavior.DataAccessKind.ImplicitWrite.toString(),...
        Simulink.metamodel.arplatform.behavior.DataAccessKind.ExplicitReadByArg.toString(),...
        Simulink.metamodel.arplatform.behavior.DataAccessKind.ExplicitReadByValue.toString(),...
        Simulink.metamodel.arplatform.behavior.DataAccessKind.ExplicitWrite.toString()...
        },...
        {...
        'ImplicitReceive',...
        'ImplicitSend',...
        'ExplicitReceive',...
        'ExplicitReceiveByVal',...
'ExplicitSend'...
        }...
        );
    end



    portList=slPort2RefBiMap.getLeftKeys();

    isAdaptive=autosar.api.Utils.isMappedToAdaptiveApplication(self.MdlName);


    for ii=1:numel(portList)

        m3iAccesses=slPort2AccessMap.get(portList{ii});
        m3iAccess=[];
        validm3iAcess=true;
        if~isempty(m3iAccesses)
            accessStrs=cell(1,numel(m3iAccesses));
            for jj=1:numel(m3iAccesses)
                m3iAccess=m3iAccesses{jj};
                if isempty(m3iAccess)||~m3iAccess.isvalid
                    validm3iAcess=false;
                    break;
                end
                if isa(m3iAccess,'Simulink.metamodel.arplatform.behavior.ModeAccess')
                    accessStrs{jj}='ModeReceive';
                elseif isa(m3iAccess,'Simulink.metamodel.arplatform.behavior.ModeSwitch')
                    accessStrs{jj}='ModeSend';
                else
                    accessStrs{jj}=accessKind2Str(m3iAccess.Kind.toString());
                end
            end

            implicitRecvAccess=strcmp(accessStrs,'ImplicitReceive');
            implicitSendAccess=strcmp(accessStrs,'ImplicitSend');
            explicitRecvAccess=strcmp(accessStrs,'ExplicitReceive');
            explicitSendAccess=strcmp(accessStrs,'ExplicitSend');
            explicitRecvByValAccess=strcmp(accessStrs,'ExplicitReceiveByVal');

            isReceiveAccess=any(implicitRecvAccess)||any(explicitRecvAccess)...
            ||any(explicitRecvByValAccess);
            isSendAccess=any(implicitSendAccess)||any(explicitSendAccess);

            if validm3iAcess




                implicitAndExplicitRecvAccess=any(implicitRecvAccess)&&any(explicitRecvAccess);
                implicitAndExplicitSendAccess=any(implicitSendAccess)&&any(explicitSendAccess);
                implicitAndExplicitAccess=implicitAndExplicitRecvAccess||implicitAndExplicitSendAccess;
                if implicitAndExplicitAccess
                    if implicitAndExplicitRecvAccess

                        implicitRecvAccesses=m3iAccesses(implicitRecvAccess);
                        m3iAccess=implicitRecvAccesses{1};
                        warnId='RTW:autosar:DataReceivePointAndDataReadAccessDefined';
                    else
                        assert(implicitAndExplicitSendAccess,'expected implicitAndExplicitSendAccess to be true');

                        implicitSendAccesses=m3iAccesses(implicitSendAccess);
                        m3iAccess=implicitSendAccesses{1};
                        warnId='RTW:autosar:DataSendPointAndDataWriteAccessDefined';
                    end

                    warnParams={m3iAccess.instanceRef.DataElements.Name,...
                    m3iAccess.instanceRef.DataElements.containerM3I.Name,...
                    m3iAccess.instanceRef.Port.Name};
                    self.msgStream.createWarning(warnId,warnParams,...
                    self.slSystemName,'modelImport');
                end
            end
        else
            validm3iAcess=false;
        end


        blkH=portList{ii};
        m3iRef=slPort2RefBiMap.getLeft(blkH);
        m3iPort=m3iRef.Port;

        if isa(m3iRef,'Simulink.metamodel.arplatform.instance.ModeDeclarationInstanceRef')
            if isa(m3iPort,'Simulink.metamodel.arplatform.port.RequiredPort')
                slMapping=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
                slMapping.mapPort(get_param(blkH,'Name'),m3iPort.Name,m3iRef.groupElement.Name,'ModeReceive');
            elseif isa(m3iPort,'Simulink.metamodel.arplatform.port.ProvidedPort')
                slMapping=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
                slMapping.mapPort(get_param(blkH,'Name'),m3iPort.Name,m3iRef.groupElement.Name,'ModeSend');
            else
                assert(false,'Expected either provide or require port in a mode declaration instance reference, but found %s',...
                class(m3iPort));
            end
        else

            isQueued=false;
            isE2E=false;
            portPkgStr='Simulink.metamodel.arplatform.port.';

            if validm3iAcess&&isa(m3iPort,'Simulink.metamodel.arplatform.port.DataSenderReceiverPort')
                assert(xor(isReceiveAccess,isSendAccess),...
                ['For a DataSenderReceiverPort, the access mode has ',...
                'to be either a sender or receiver.']);

                portInfo=iFindPRPortInfo(m3iPort,m3iRef.DataElements,...
                'DataElements',isSendAccess);
            else
                portInfo=autosar.mm.Model.findPortInfo(m3iPort,...
                m3iRef.DataElements,...
                'DataElements');
            end

            isNvPort=autosar.api.Utils.isNvPort(m3iPort);
            if~isNvPort&&~isempty(portInfo)&&~isempty(portInfo.comSpec)
                comSpec=portInfo.comSpec;
                if(isa(comSpec,[portPkgStr,'DataReceiverQueuedPortComSpec'])||...
                    isa(comSpec,[portPkgStr,'DataSenderQueuedPortComSpec']))
                    isQueued=true;
                    isE2E=comSpec.UsesEndToEndProtection;


                    m3iRef.DataElements.SwCalibrationAccess=...
                    Simulink.metamodel.foundation.SwCalibrationAccessKind.NotAccessible;
                end
                if(isa(comSpec,[portPkgStr,'DataReceiverNonqueuedPortComSpec'])||...
                    isa(comSpec,[portPkgStr,'DataSenderNonqueuedPortComSpec']))
                    isE2E=comSpec.UsesEndToEndProtection;
                end
            end

            portUsesE2EErrorHandlingTransformer=...
            autosar.mm.mm2sl.utils.doesPortUseE2EErrorHandlingTransformer(m3iPort);
            isE2E=isE2E||portUsesE2EErrorHandlingTransformer;

            if self.expReadData2IsUpdatedMap.isKey(blkH)


                isUpdatedHdl=self.expReadData2IsUpdatedMap.get(blkH);
                isUpdatedPortName=get_param(isUpdatedHdl,'Name');
            else
                isUpdatedPortName='';
            end

            if self.DataInportBlk2ErrorStatusBlkMap.isKey(blkH)


                errorStatusBlkHdl=self.DataInportBlk2ErrorStatusBlkMap.get(blkH);
                errorStatusPortName=get_param(errorStatusBlkHdl,'Name');
            else
                errorStatusPortName='';
            end

            isInport=strcmp(get_param(blkH,'BlockType'),'Inport');
            if validm3iAcess
                accessStr=iGetFlowDataAccessStr(accessKind2Str,m3iAccess,isQueued,isInport,isE2E);
            else
                if isInport
                    if~isQueued
                        accessStr='ImplicitReceive';
                    else
                        if~isE2E
                            accessStr='QueuedExplicitReceive';
                        else
                            accessStr='EndToEndQueuedReceive';
                        end
                    end
                else
                    if isAdaptive
                        accessStr='false';
                    elseif~isQueued
                        accessStr='ImplicitSend';
                    else
                        if~isE2E
                            accessStr='QueuedExplicitSend';
                        else
                            accessStr='EndToEndQueuedSend';
                        end
                    end
                end
            end


            if slfeature('E2ECodeGenSupport')==0
                if strcmp(accessStr,'EndToEndQueuedSend')==1
                    accessStr='QueuedExplicitSend';
                elseif strcmp(accessStr,'EndToEndQueuedReceive')==1
                    accessStr='QueuedExplicitReceive';
                end
            end
            slMapping=autosar.api.getSimulinkMapping(self.MdlName,self.ChangeLogger);
            slMapping.mapPort(get_param(blkH,'Name'),m3iPort.Name,m3iRef.DataElements.Name,accessStr);
            if~isempty(isUpdatedPortName)
                slMapping.mapPort(isUpdatedPortName,m3iPort.Name,m3iRef.DataElements.Name,'IsUpdated');
            end
            if~isempty(errorStatusPortName)
                slMapping.mapPort(errorStatusPortName,m3iPort.Name,m3iRef.DataElements.Name,'ErrorStatus');
            end
        end
    end

end

function accessStr=iGetFlowDataAccessStr(accessKind2Str,m3iAccess,isQueued,isInport,isE2E)


    if isQueued

        if isInport


            if~isE2E
                accessStr='QueuedExplicitReceive';
            else
                accessStr='EndToEndQueuedReceive';
            end
        else
            if~isE2E
                accessStr='QueuedExplicitSend';
            else
                accessStr='EndToEndQueuedSend';
            end
        end
    elseif isE2E


        if isInport
            accessStr='EndToEndRead';
        else
            accessStr='EndToEndWrite';
        end
    elseif isempty(m3iAccess)

        if isInport
            accessStr='ImplicitReceive';
        else
            accessStr='ImplicitSend';
        end
    else

        accessStr=accessKind2Str(m3iAccess.Kind.toString());
    end

end

function portInfo=iFindPRPortInfo(port,key,role,sendReceiveN)





    portPkgStr='Simulink.metamodel.arplatform.port.';

    portInfo=[];
    for jj=1:port.info.size()
        currPortInfo=port.info.at(jj);
        if sendReceiveN
            if~isa(currPortInfo.comSpec,...
                [portPkgStr,'DataSenderNonqueuedPortComSpec'])
                continue;
            end
        else
            if~isa(currPortInfo.comSpec,...
                [portPkgStr,'DataReceiverNonqueuedPortComSpec'])
                continue;
            end
        end
        if currPortInfo.(role)==key
            portInfo=currPortInfo;
        end
    end
end

