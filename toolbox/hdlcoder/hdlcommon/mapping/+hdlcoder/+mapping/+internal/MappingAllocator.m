classdef MappingAllocator




    methods(Static)
        function[portUUID,elementUUID]=allocateIndividualMapping(mapping,propertyName,propertyValue)

            hdlModelMapping=mapping.ParentMapping;
            mf0Model=hdlcoder.mapping.internal.ModelUtils.getMF0Model(hdlModelMapping);
            ipCore=hdlcoder.mapping.internal.ModelUtils.getIPCore(hdlModelMapping);
            dutPortProps=hdlcoder.mapping.internal.ModelUtils.getModelPortProperties(mapping);






            transaction=mf0Model.beginRevertibleTransaction;
            try
                switch propertyName
                case 'Interface'


                    [portUUID,elementUUID]=hdlcoder.mapping.internal.MappingAllocator.allocatePortMapping(...
                    propertyValue,mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps);
                case 'InterfaceElement'




                    portUUID=mapping.MappedTo.Port.UUID;
                    assert(~isempty(portUUID),'Expected port to be non-empty when assigning element.')
                    [elementUUID]=hdlcoder.mapping.internal.MappingAllocator.allocateElementMapping(...
                    propertyValue,mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps);
                otherwise
                    portUUID='';
                    elementUUID='';
                    hdlcoder.mapping.internal.MappingAllocator.allocatePerInstanceProperty(...
                    propertyName,propertyValue,mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps)
                end
                transaction.commit;
            catch ME
                transaction.rollBack;
                rethrow(ME);
            end
        end

        function autoDefault=getAnnotationForMapping(mapping,propertyName)
            autoDefault='';

            switch propertyName
            case 'Interface'

            case 'InterfaceElement'

                hdlModelMapping=mapping.ParentMapping;
                mf0Model=hdlcoder.mapping.internal.ModelUtils.getMF0Model(hdlModelMapping);



                if isempty(mapping.MappedTo.Element.UUID)
                    return;
                end

                portUUID=mapping.MappedTo.Port.UUID;
                ipCorePort=mf0Model.findElement(portUUID);
                assert(~isempty(ipCorePort),'Expected port to be nonempty.');


                if hdlcoder.mapping.internal.MF0Utils.isRegisterPort(ipCorePort)
                    register=mf0Model.findElement(mapping.MappedTo.Element.UUID);
                    if register.IsAutoAssignedAddress
                        autoDefault="0x"+dec2hex(register.AddressOffset);
                    end
                end
            otherwise
                DAStudio.error('Unexpected property type.');
            end
        end
    end

    methods(Static,Access=private)
        function[portUUID,elementUUID]=allocatePortMapping(portName,mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps)

            prevPortUUID=mapping.MappedTo.Port.UUID;
            if~isempty(prevPortUUID)
                prevPort=mf0Model.findElement(prevPortUUID);
                if hdlcoder.mapping.internal.MF0Utils.isRegisterPort(prevPort)

                    regUUID=mapping.MappedTo.Element.UUID;
                    oldRegister=mf0Model.findElement(regUUID);
                    oldRegister.destroy;
                elseif hdlcoder.mapping.internal.MF0Utils.isExternalPort(prevPort)

                    oldExternalPort=prevPort;
                    oldExternalPort.destroy;
                end
            end


            if isempty(portName)
                portUUID='';
                elementUUID='';
                return;
            end








            if strcmp(portName,'External Port')
                externalPort=hdlcoder.mapping.internal.MappingAllocator.createExternalPort(...
                mf0Model,dutPortProps);
                ipCore.Ports(end+1)=externalPort;

                portUUID=externalPort.UUID;
                elementUUID='';
                return;
            end




            interfacePort=hdlcoder.mapping.internal.MF0Utils.getIPCorePortByName(...
            ipCore,portName);
            assert(hdlcoder.mapping.internal.MF0Utils.isInterfacePort(interfacePort),'Expected port to be an interface port.');


            portUUID=interfacePort.UUID;



            if hdlcoder.mapping.internal.MF0Utils.isRegisterPort(interfacePort)

                memoryMap=interfacePort.MemoryMap;
                addressBlock=memoryMap.AddressBlocks(1);

                register=hdlcoder.mapping.internal.MappingAllocator.createRegister(mf0Model,dutPortProps);
                hdlcoder.mapping.internal.MappingAllocator.autoAssignRegisterAddress(register,interfacePort,dutPortProps);
                addressBlock.Registers.add(register);

                elementUUID=register.UUID;
            else
                elementUUID='';
            end
        end

        function elementUUID=allocateElementMapping(elementName,mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps)

            ipCorePort=mf0Model.findElement(mapping.MappedTo.Port.UUID);










            if hdlcoder.mapping.internal.MF0Utils.isExternalPort(ipCorePort)
                if~isempty(elementName)
                    DAStudio.error('codemapping_hdl:mapping:InvalidExternalPortMapping');
                end
            elseif hdlcoder.mapping.internal.MF0Utils.isRegisterPort(ipCorePort)
                register=mf0Model.findElement(mapping.MappedTo.Element.UUID);


                try
                    newAddrOffset=hex2dec(elementName);
                catch
                    DAStudio.error('codemapping_hdl:mapping:IncorrectAddressFormat',elementName);
                end



                if isempty(newAddrOffset)
                    hdlcoder.mapping.internal.MappingAllocator.autoAssignRegisterAddress(register,ipCorePort,dutPortProps);
                else
                    register.AddressOffset=newAddrOffset;
                    register.IsAutoAssignedAddress=false;
                end


                elementUUID=register.UUID;
            else
                if isempty(elementName)

                    elementUUID='';
                    return;
                end


                element=hdlcoder.mapping.internal.MF0Utils.getPortElementByName(ipCorePort,elementName);


                if isempty(element)
                    validElements=[ipCorePort.InterfaceDefinition.InterfaceElements];
                    validElementNames=strjoin([validElements.Name],", ");
                    DAStudio.error('codemapping_hdl:mapping:InvalidElementName',elementName,ipCorePort.InterfaceDefinition.Name,validElementNames);
                end

                elementUUID=element.UUID;
            end
        end

        function allocatePerInstanceProperty(propertyName,propertyValue,mf0Model,~,~,mapping,~)
            mappedTo=mf0Model.findElement(mapping.MappedTo.Element.UUID);
            if isa(mappedTo,'hdl.ip.addressable.Register')
                switch propertyName
                case 'Register Initial Value'
                    mappedTo.InitialValue=str2double(propertyValue);
                    return;
                end
            end

            DAStudio.error('Unexpected property type.');
        end
    end


    methods(Static,Access=private)
        function externalPort=createExternalPort(mf0Model,dutPortProps)
            externalPort=hdl.ip.port.IOPort(mf0Model);
            externalPort.Direction=dutPortProps.Direction;





            externalPort.Name=dutPortProps.PortName;

        end

        function register=createRegister(mf0Model,dutPortProps)
            register=hdl.ip.addressable.Register(mf0Model);
            register.Name=dutPortProps.PortName;
            if dutPortProps.Direction=="IN"
                register.Access=hdl.ip.addressable.DataAccess.WRITEONLY;
            elseif dutPortProps.Direction=="OUT"
                register.Access=hdl.ip.addressable.DataAccess.READONLY;
            end
        end

        function autoAssignRegisterAddress(register,ipCorePort,dutPortProps)
            memoryMap=ipCorePort.MemoryMap;
            addressBlock=memoryMap.AddressBlocks(1);


            if isempty(addressBlock.Registers.toArray)
                addrOffset=0x100u64;
            else
                regArray=addressBlock.Registers.toArray;
                occupiedAddrs=sort([regArray.AddressOffset]);
                addrOffset=occupiedAddrs(end)+0x4u64;
            end
            register.AddressOffset=addrOffset;
            register.IsAutoAssignedAddress=true;
        end
    end
end


