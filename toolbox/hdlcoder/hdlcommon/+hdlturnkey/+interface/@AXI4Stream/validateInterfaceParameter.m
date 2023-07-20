function validateInterfaceParameter(obj)




    validateInterfaceParameter@hdlturnkey.interface.AXI4StreamBase(obj,obj.AXI4StreamExampleStr);


    hdlturnkey.plugin.validateBooleanProperty(...
    obj.HasDMAConnection,'HasDMAConnection',obj.AXI4StreamExampleStr);

    obj.validateDeviceTreeNodeName(obj.DeviceTreeMasterChannelDMANode,'DeviceTreeMasterChannelDMANode',obj.AXI4StreamExampleStr);
    if~isempty(obj.DeviceTreeMasterChannelDMANode)&&~obj.HasDMAConnection


        error(message('hdlcommon:plugin:InvalidInterfaceDeviceTree','DeviceTreeMasterChannelDMANode','HasDMAConnection'));
    end

    obj.validateDeviceTreeNodeName(obj.DeviceTreeSlaveChannelDMANode,'DeviceTreeSlaveChannelDMANode',obj.AXI4StreamExampleStr);
    if~isempty(obj.DeviceTreeSlaveChannelDMANode)&&~obj.HasDMAConnection


        error(message('hdlcommon:plugin:InvalidInterfaceDeviceTree','DeviceTreeSlaveChannelDMANode','HasDMAConnection'));
    end



    if obj.IsGenericIP
        if obj.isNonDefaultDMASetting
            error(message('hdlcommon:interface:AXIStreamGenericIP'));
        end
    end

end
