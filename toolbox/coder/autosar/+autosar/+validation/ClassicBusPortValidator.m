classdef ClassicBusPortValidator<autosar.validation.BusPortValidatorAdapter




    properties(Constant,Access=protected)
        ElementPropName='Element';
        AccessModePropName='DataAccessMode';
    end

    methods(Access=protected)
        function verifyCompositePortMapping(this)
            this.verifyCompositePortMappingBase();

            this.verifyModePorts();



            this.verifyNoMixedMessageSignalBusPort();
        end

        function verifyModePorts(this)



            mapping=autosar.api.Utils.modelMapping(this.ModelH);
            mmPorts=[mapping.Inports,mapping.Outports];

            arProps=autosar.api.getAUTOSARProperties(this.ModelH);

            for portIdx=1:numel(mmPorts)
                mmPort=mmPorts(portIdx);
                if~autosar.composition.Utils.isCompositePortBlock(mmPort.Block)

                    continue;
                end
                if any(strcmp(mmPort.MappedTo.DataAccessMode,{'ModeSend','ModeReceive'}))


                    arPort=arProps.find([],'Port','Name',mmPort.MappedTo.Port,'PathType','FullyQualified');
                    if isempty(arPort),continue;end
                    arInterface=arProps.get(arPort{1},'Interface');

                    modeInterface=arProps.find([],'ModeSwitchInterface','Name',arInterface);
                    if isempty(modeInterface)
                        blk=mmPort.Block;
                        isInport=strcmp(get_param(blk,'BlockType'),'Inport');
                        if isInport
                            defaultDataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessInport;
                        else
                            defaultDataAccessMode=autosar.ui.wizard.PackageString.DefaultDataAccessOutport;
                        end
                        blockStr=autosar.simulink.bep.Utils.getBusPortBlockTypeStr(blk);
                        autosar.validation.Validator.logError('autosarstandard:validation:busPortDataAccessModeChanged',...
                        blockStr,...
                        getfullname(blk),...
                        mmPort.MappedTo.Port,...
                        get_param(this.ModelH,'Name'),...
                        defaultDataAccessMode);
                    end
                end
            end
        end

        function verifyNoMixedMessageSignalBusPort(this)







            [~,portsUsingMixedMessageSignal]=...
            autosar.validation.ClassicBusPortValidator.containsMixedMessageSignalPorts(this.ModelH);

            isComposite=strcmp(get_param(portsUsingMixedMessageSignal,'IsComposite'),'on');
            compositePortsUsingMixedMessageSignal=portsUsingMixedMessageSignal(isComposite);
            if~isempty(compositePortsUsingMixedMessageSignal)
                mixedPortPathsString=...
                autosar.validation.AutosarUtils.getFullBlockPathsForError(...
                compositePortsUsingMixedMessageSignal);
                autosar.validation.Validator.logError(...
                'autosarstandard:validation:MixedMessageSignalPorts',...
                mixedPortPathsString);
            end
        end
    end

    methods(Static,Access=protected)
        function accessMode=getAccessMode(port)
            accessMode=port.MappedTo.DataAccessMode;
        end

        function nonQosPortsSharingSameElement=filterValidSharedElems(portsSharingSameElem)



            duplicateDataAccessModes=cellfun(@(x)x.DataAccessMode,portsSharingSameElem,'UniformOutput',false);
            qosElementIds=cellfun(@(x)any(strcmp(x,{'ErrorStatus','IsUpdated','EndToEndRead'})),duplicateDataAccessModes);

            nonQosPortsSharingSameElement=portsSharingSameElem(~qosElementIds);
        end
    end

    methods(Static,Access=public)
        function[hasMixedMessageSignalPorts,mixedPortPaths]=...
            containsMixedMessageSignalPorts(modelName)






            hasMixedMessageSignalPorts=false;
            mixedPortPaths=[];

            if~autosar.api.Utils.isMappedToComponent(modelName)


                return;
            end

            mapping=autosar.api.Utils.modelMapping(modelName);


            mappedPorts=[mapping.Inports.MappedTo,mapping.Outports.MappedTo];
            if isempty(mappedPorts)

                return;
            end
            arPortNames={mappedPorts.Port};
            portPaths={mapping.Inports.Block,mapping.Outports.Block};



            if isa(mapping,'Simulink.AutosarTarget.ModelMapping')
                mappedQueuedPortIdx=ismember({mappedPorts.DataAccessMode},...
                {'QueuedExplicitReceive','QueuedExplicitSend',...
                'EndToEndQueuedSend','EndToEndQueuedReceive'});


                mappedNonQueuedPortsIdx=~ismember({mappedPorts.DataAccessMode},...
                {'QueuedExplicitReceive','QueuedExplicitSend',...
                'EndToEndQueuedSend','EndToEndQueuedReceive',...
                'ErrorStatus','IsUpdated'});



                messagePortNames=arPortNames(mappedQueuedPortIdx);
                signalPortNames=arPortNames(mappedNonQueuedPortsIdx);

                mixedPortNames=intersect(messagePortNames,signalPortNames);

                mixedPortPaths=portPaths(ismember(arPortNames,mixedPortNames));
                hasMixedMessageSignalPorts=~isempty(mixedPortPaths);
            end
        end
    end
end


