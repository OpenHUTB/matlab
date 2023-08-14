function populateSubPorts(obj)






    obj.hPixelDataType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TDATAMaxWidth);
    obj.hUfix1Type=hdlturnkey.data.TypeFixedPt('WordLength',1);

    obj.hPixelBusType=hdlturnkey.data.TypeBus();
    obj.hPixelBusType.addMemberType('hStart',obj.hUfix1Type);
    obj.hPixelBusType.addMemberType('hEnd',obj.hUfix1Type);
    obj.hPixelBusType.addMemberType('vStart',obj.hUfix1Type);
    obj.hPixelBusType.addMemberType('vEnd',obj.hUfix1Type);
    obj.hPixelBusType.addMemberType('valid',obj.hUfix1Type);











    PortUserData={'Pixel Data','pixel',obj.hPixelDataType,true,'data','(pixel)|(data)'};
    PortUserBus={'Pixel Control Bus','ctrl',obj.hPixelBusType,true,'','(ctrl)|(control)'};
    PortUserReady={'Ready','ready',obj.hUfix1Type,false,'ready','ready'};


    userMasterDrivenPortList={...
    PortUserData,...
    PortUserBus,...
    };
    userSlaveDrivenPortList={...
    PortUserReady,...
    };





    for ii=1:obj.SlaveChannelNumber
        hChannel=obj.hChannelList.createChannel(hdlturnkey.IOType.IN,...
        userMasterDrivenPortList,userSlaveDrivenPortList);


        if~obj.IsGenericIP
            hChannel.RDOverrideDataBitwidth=obj.SlaveChannelDataWidth;
        end
    end
    for ii=1:obj.MasterChannelNumber
        hChannel=obj.hChannelList.createChannel(hdlturnkey.IOType.OUT,...
        userMasterDrivenPortList,userSlaveDrivenPortList);


        if~obj.IsGenericIP
            hChannel.RDOverrideDataBitwidth=obj.MasterChannelDataWidth;
        end
    end
end



