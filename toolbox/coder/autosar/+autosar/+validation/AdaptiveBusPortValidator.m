classdef AdaptiveBusPortValidator<autosar.validation.BusPortValidatorAdapter




    properties(Constant,Access=protected)
        ElementPropName='Event';
        AccessModePropName='AllocateMemory';
    end

    methods(Access=protected)
        function verifyCompositePortMapping(this)
            this.verifyCompositePortMappingBase();
        end
    end

    methods(Static,Access=protected)
        function accessMode=getAccessMode(port)
            if isa(port,'Simulink.AutosarTarget.PortProvidedEvent')
                accessMode=port.MappedTo.AllocateMemory;
            else
                accessMode='';
            end
        end

        function portsSharingSameElem=filterValidSharedElems(portsSharingSameElem)


            return;
        end
    end
end
