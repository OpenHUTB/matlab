classdef MappingValidator




    methods(Static)
        function validateAllMappings(modelHandle,callMode)




        end

        function[hasError,errorMessage]=validateIndividualMapping(mapping,propertyName)
            hasError=false;
            errorMessage='';


            hdlModelMapping=mapping.ParentMapping;
            mf0Model=hdlcoder.mapping.internal.ModelUtils.getMF0Model(hdlModelMapping);
            ipCore=hdlcoder.mapping.internal.ModelUtils.getIPCore(hdlModelMapping);
            dutPortProps=hdlcoder.mapping.internal.ModelUtils.getModelPortProperties(mapping);

            try
                switch propertyName
                case 'Interface'

                    hdlcoder.mapping.internal.MappingValidator.validatePortMapping(...
                    mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps);
                case 'InterfaceElement'



                    hdlcoder.mapping.internal.MappingValidator.validateElementMapping(...
                    mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps);
                otherwise
                    DAStudio.error('Unexpected property type.');
                end
            catch ME
                hasError=true;
                errorMessage=ME.message;
            end
        end
    end

    methods(Static,Access=private)
        function validatePortMapping(mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps)


        end

        function validateElementMapping(mf0Model,ipCore,hdlModelMapping,mapping,dutPortProps)
            elementUUID=mapping.MappedTo.Element.UUID;

            if isempty(elementUUID)

                return;
            end

            ipCorePort=mf0Model.findElement(mapping.MappedTo.Port.UUID);

            if hdlcoder.mapping.internal.MF0Utils.isInterfacePort(ipCorePort)

                if hdlcoder.mapping.internal.MF0Utils.isRegisterPort(ipCorePort)

                    register=mf0Model.findElement(elementUUID);
                    assert(isa(register,'hdl.ip.addressable.RegisterData'),'Expected a register.');
                    hdlcoder.mapping.internal.MappingValidator.validateRegisterMapping(...
                    register,dutPortProps,hdlModelMapping,mapping,ipCorePort);
                else

                    element=mf0Model.findElement(elementUUID);
                    assert(isa(element,'hdl.ip.interface.InterfaceElement'),'Expected an interface element.');
                    hdlcoder.mapping.internal.MappingValidator.validatePortElementMapping(...
                    element,dutPortProps,hdlModelMapping,mapping,ipCorePort);
                end
            else

                hdlcoder.mapping.internal.MappingValidator.validateExternalPortMapping(...
                elementUUID,dutPortProps,hdlModelMapping,mapping,ipCorePort);
            end
        end

        function validateExternalPortMapping(propertyValue,dutPortProps,hdlModelMapping,mapping,ipCorePort)
            if~isempty(propertyValue)
                DAStudio.error('codemapping_hdl:mapping:InvalidExternalPortMapping');
            end
        end

        function validatePortElementMapping(element,dutPortProps,hdlModelMapping,mapping,ipCorePort)

            allMappings=hdlcoder.mapping.internal.MappingValidator.getAllMappings(hdlModelMapping);
            for idx=1:length(allMappings)
                otherMapping=allMappings{idx};
                if isequal(otherMapping,mapping)

                    continue;
                end



                if isequal(otherMapping.MappedTo.Port.UUID,mapping.MappedTo.Port.UUID)&&...
                    isequal(otherMapping.MappedTo.Element.UUID,element.UUID)
                    blockName=hdlcoder.mapping.internal.MappingValidator.getBlockNameFromMapping(otherMapping);
                    DAStudio.error('codemapping_hdl:mapping:DuplicateElementMapping',element.Name,blockName);
                end
            end

            if hdlcoder.mapping.internal.MF0Utils.isSlavePort(ipCorePort)
                elementProps=element.SlavePortView;
                interfaceMode="Slave";
            elseif hdlcoder.mapping.internal.MF0Utils.isMasterPort(ipCorePort)
                elementProps=element.MasterPortView;
                interfaceMode="Master";
            else
                DAStudio.error('Expected either a Slave or Master port.');
            end


            elementPresence=elementProps.Presence;
            if elementPresence=="ILLEGAL"
                DAStudio.error('codemapping_hdl:mapping:IllegalElementMapping',element.Name,interfaceMode);
            end


            portDirection=dutPortProps.Direction;
            elementDirection=elementProps.Direction;
            if portDirection~=elementDirection
                DAStudio.error('codemapping_hdl:mapping:InvalidElementDirection',char(portDirection),char(elementDirection));
            end




            portWidth=dutPortProps.WordLength;
            elementWidth=elementProps.Width;
            if portWidth>elementWidth
                DAStudio.error('codemapping_hdl:mapping:InvalidElementWidth',portWidth,elementWidth);
            end


        end

        function validateRegisterMapping(register,dutPortProps,hdlModelMapping,mapping,ipCorePort)




            if register.IsAutoAssignedAddress
                return;
            end


            addrOffset=register.AddressOffset;
            memoryMap=ipCorePort.MemoryMap;
            addressBlock=memoryMap.AddressBlocks(1);
            regArray=addressBlock.Registers.toArray;
            for otherReg=regArray
                if isequal(otherReg,register)

                    continue;
                end

                if otherReg.IsAutoAssignedAddress

                    continue;
                end


                if isequal(otherReg.AddressOffset,addrOffset)
                    conflictingMapping=hdlcoder.mapping.internal.MappingValidator.findMappingByElementUUID(hdlModelMapping,otherReg.UUID);
                    blockName=hdlcoder.mapping.internal.MappingValidator.getBlockNameFromMapping(conflictingMapping);

                    DAStudio.error('codemapping_hdl:mapping:ConflictingRegisterAddress',sprintf("0x%X",addrOffset),blockName);
                end
            end
        end

        function allMappings=getAllMappings(hdlModelMapping)
            inPortMappings=hdlModelMapping.Inports;
            outPortMappings=hdlModelMapping.Outports;
            signalMappings=hdlModelMapping.Signals;

            allMappings=cell(1,length(inPortMappings)+length(outPortMappings)+length(signalMappings));

            idx=1;
            for mapping=inPortMappings
                allMappings{idx}=mapping;
                idx=idx+1;
            end

            for mapping=outPortMappings
                allMappings{idx}=mapping;
                idx=idx+1;
            end

            for mapping=signalMappings
                allMappings{idx}=mapping;
                idx=idx+1;
            end
        end

        function mapping=findMappingByElementUUID(hdlModelMapping,uuid)
            allMappings=hdlcoder.mapping.internal.MappingValidator.getAllMappings(hdlModelMapping);
            for idx=1:length(allMappings)
                mapping=allMappings{idx};
                if isequal(mapping.MappedTo.Element.UUID,uuid)
                    return;
                end
            end
        end

        function blockName=getBlockNameFromMapping(mapping)
            if isa(mapping,'Simulink.HDLTarget.IOMapping')
                blockName=mapping.Block;
            elseif isa(mapping,'Simulink.HDLTarget.SignalMapping')
                blockName=mapping.OwnerBlockPath;
            else
                blockName='';
            end
        end
    end
end


