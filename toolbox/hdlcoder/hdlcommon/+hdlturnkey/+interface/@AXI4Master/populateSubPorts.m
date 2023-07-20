function populateSubPorts(obj)






    obj.hDataType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.MaxDataWidth);
    obj.hAddrType=hdlturnkey.data.TypeFixedPt('WordLength',obj.AddrWidth);
    obj.hLenType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.MaxLenWidth);
    obj.hUfix1Type=hdlturnkey.data.TypeFixedPt('WordLength',1);
    obj.hUfix2Type=hdlturnkey.data.TypeFixedPt('WordLength',2);

    obj.hWriteOutBusType=hdlturnkey.data.TypeBus();

    obj.hWriteOutBusType.addMemberType('wr_addr',obj.hAddrType);
    obj.hWriteOutBusType.addMemberType('wr_len',obj.hLenType);
    obj.hWriteOutBusType.addMemberType('wr_valid',obj.hUfix1Type);
    obj.hWriteOutBusType.addMemberType('wr_awid',obj.hUfix1Type,false,true);

    obj.hWriteInBusType=hdlturnkey.data.TypeBus();
    obj.hWriteInBusType.addMemberType('wr_ready',obj.hUfix1Type);
    obj.hWriteInBusType.addMemberType('wr_bvalid',obj.hUfix1Type,false);
    obj.hWriteInBusType.addMemberType('wr_bresp',obj.hUfix2Type,false);
    obj.hWriteInBusType.addMemberType('wr_complete',obj.hUfix1Type,false);
    obj.hWriteInBusType.addMemberType('wr_bid',obj.hUfix1Type,false,true);

    obj.hReadOutBusType=hdlturnkey.data.TypeBus();
    obj.hReadOutBusType.addMemberType('rd_addr',obj.hAddrType);
    obj.hReadOutBusType.addMemberType('rd_len',obj.hLenType);
    obj.hReadOutBusType.addMemberType('rd_avalid',obj.hUfix1Type);
    obj.hReadOutBusType.addMemberType('rd_dready',obj.hUfix1Type,false);
    obj.hReadOutBusType.addMemberType('rd_arid',obj.hUfix1Type,false,true);

    obj.hReadInBusType=hdlturnkey.data.TypeBus();
    obj.hReadInBusType.addMemberType('rd_aready',obj.hUfix1Type);
    obj.hReadInBusType.addMemberType('rd_dvalid',obj.hUfix1Type);
    obj.hReadInBusType.addMemberType('rd_rresp',obj.hUfix2Type,false);
    obj.hReadInBusType.addMemberType('rd_rid',obj.hUfix1Type,false,true);









    if obj.WriteSupport

        userOutPortList={...
        {'Data','data',obj.hDataType,true,'DATA','dat',0},...
        {'Write Master to Slave Bus','wr_m2s',obj.hWriteOutBusType,true,'wr_m2s','wr_m2s',0},...
        };
        userInPortList={...
        {'Write Slave to Master Bus','wr_s2m',obj.hWriteInBusType,true,'wr_s2m','wr_s2m',[]},...
        };

        obj.hChannelList.createChannel(hdlturnkey.IOType.OUT,...
        userInPortList,userOutPortList);

    end

    if obj.ReadSupport

        userOutPortList={...
        {'Read Master to Slave Bus','rd_m2s',obj.hReadOutBusType,true,'rd_m2s','rd_m2s',0},...
        };
        userInPortList={...
        {'Data','data',obj.hDataType,true,'DATA','dat',[]},...
        {'Read Slave to Master Bus','rd_s2m',obj.hReadInBusType,true,'rd_s2m','rd_s2m',[]},...
        };

        obj.hChannelList.createChannel(hdlturnkey.IOType.IN,...
        userInPortList,userOutPortList);
    end
end


