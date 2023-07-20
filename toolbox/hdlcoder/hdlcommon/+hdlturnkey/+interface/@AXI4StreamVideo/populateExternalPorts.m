function populateExternalPorts(obj,hN,hChannel,hElab)

















    PortExtData={'TDATA',obj.hPixelDataType,'Pixel Data'};
    PortExtValid={'TVALID',obj.hUfix1Type,''};
    PortExtReady={'TREADY',obj.hUfix1Type,''};
    PortExtTLAST={'TLAST',obj.hUfix1Type,''};
    PortExtTUSER={'TUSER',obj.hUfix1Type,''};



    extMasterDrivenPortList={...
    PortExtData,...
    PortExtValid,...
    PortExtTLAST,...
    PortExtTUSER,...
    };
    extSlaveDrivenPortList={...
    PortExtReady,...
    };





    hdlturnkey.interface.ChannelBased.populateExternalChannelPort(hN,hChannel,...
    extSlaveDrivenPortList,extMasterDrivenPortList,...
    extMasterDrivenPortList,extSlaveDrivenPortList,hElab);

end

