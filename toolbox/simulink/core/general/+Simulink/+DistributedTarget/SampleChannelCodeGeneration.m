




classdef SampleChannelCodeGeneration<Simulink.DistributedTarget.ChannelCodeGenConfigurationBase
    properties(SetAccess=private)
        Address=0;
    end

    methods


        function initializeChannelParameters(obj)
            obj.Address=0;
        end



        function computeChannelParameters(obj,signalMapping)
            obj.Address=obj.Address+4;
            signalMapping.Address=num2str(obj.Address);
        end


        function ret=getDeviceDriverBlockAndProperties(~,nodeH,signalMappingH,portH)

            assert(isa(nodeH,'Simulink.DistributedTarget.SoftwareNode'));

            portType=get_param(portH,'PortType');

            switch portType
            case 'outport'
                isReadOp='false';
            case 'inport'
                isReadOp='true';
            end

            portOffset=signalMappingH.Address;
            sfcnName='sfun_ce_readwrite';


            ret={sfcnName,...
            [portOffset,',',isReadOp],...
            ''};
        end

    end
end



