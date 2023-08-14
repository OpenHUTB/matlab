function populateSubPorts(obj)






    obj.hTDataType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TDATAMaxWidth);
    obj.hUfix1Type=hdlturnkey.data.TypeFixedPt('WordLength',1);

    if strcmpi(hdlfeature('AXI4StreamSampleControlBus'),'on')

        obj.hSampleBusType=hdlturnkey.data.TypeBus();
        obj.hSampleBusType.addMemberType('start',obj.hUfix1Type);
        obj.hSampleBusType.addMemberType('end',obj.hUfix1Type);
        obj.hSampleBusType.addMemberType('valid',obj.hUfix1Type);
    end

    obj.hTSTRBType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TSTRBMaxWidth);
    obj.hTKEEPType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TKEEPMaxWidth);
    obj.hTIDType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TIDMaxWidth);
    obj.hTDESTType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TDESTMaxWidth);
    obj.hTUSERType=hdlturnkey.data.TypeFixedPtFlexible('MaxWordLength',obj.TUSERMaxWidth);













    PortUserData={'Data','data',obj.hTDataType,true,'data','dat'};

    if strcmp(hdlfeature('AXI4StreamControlSignal'),'on')
        validRequired=false;
    else
        validRequired=true;
    end

    if strcmpi(hdlfeature('AXI4StreamSampleControlBus'),'on')
        PortUserBus={'Sample Control Bus','ctrl',obj.hSampleBusType,validRequired,'ctrl','(ctrl)|(control)'};
    end
    PortUserValid={'Valid','valid',obj.hUfix1Type,validRequired,'valid','v(al)|(ld)'};
    PortUserReady={'Ready','ready',obj.hUfix1Type,false,'ready','r[ea]*dy'};
    PortUserTLAST={'TLAST','TLAST',obj.hUfix1Type,false,'tlast','tlast'};


    PortUserTSTRB={'TSTRB','TSTRB',obj.hTSTRBType,false,'tstrb','tstrb'};
    PortUserTKEEP={'TKEEP','TKEEP',obj.hTKEEPType,false,'tkeep','tkeep'};
    PortUserTID={'TID','TID',obj.hTIDType,false,'tid','tid'};
    PortUserTDEST={'TDEST','TDEST',obj.hTDESTType,false,'tdest','tdest'};
    PortUserTUSER={'TUSER','TUSER',obj.hTUSERType,false,'tuser','tuser'};


    if strcmpi(hdlfeature('AXI4StreamSampleControlBus'),'on')
        userMasterDrivenPortList={...
        PortUserData,...
        PortUserBus,...
        PortUserValid,...
        PortUserTLAST,...
        PortUserTSTRB,...
        PortUserTKEEP,...
        PortUserTID,...
        PortUserTDEST,...
        PortUserTUSER,...
        };
    else
        userMasterDrivenPortList={...
        PortUserData,...
        PortUserValid,...
        PortUserTLAST,...
        PortUserTSTRB,...
        PortUserTKEEP,...
        PortUserTID,...
        PortUserTDEST,...
        PortUserTUSER,...
        };
    end
    userSlaveDrivenPortList={...
    PortUserReady,...
    };





    for ii=1:obj.SlaveChannelNumber
        hChannel=obj.hChannelList.createChannel(hdlturnkey.IOType.IN,...
        userMasterDrivenPortList,userSlaveDrivenPortList);

        if strcmpi(hdlfeature('AXI4StreamSampleControlBus'),'on')

            hChannel.addExclusiveSubPort('Sample Control Bus',{'Valid','TLAST'});
            hChannel.addExclusiveSubPort('Valid',{'Sample Control Bus'});
            hChannel.addExclusiveSubPort('TLAST',{'Sample Control Bus'});
        end


        if~obj.IsGenericIP
            hChannel.RDOverrideDataBitwidth=obj.SlaveChannelDataWidth;
        end
    end
    for ii=1:obj.MasterChannelNumber
        hChannel=obj.hChannelList.createChannel(hdlturnkey.IOType.OUT,...
        userMasterDrivenPortList,userSlaveDrivenPortList);

        if strcmpi(hdlfeature('AXI4StreamSampleControlBus'),'on')

            hChannel.addExclusiveSubPort('Sample Control Bus',{'Valid','TLAST'});
            hChannel.addExclusiveSubPort('Valid',{'Sample Control Bus'});
            hChannel.addExclusiveSubPort('TLAST',{'Sample Control Bus'});
        end


        if~obj.IsGenericIP
            hChannel.RDOverrideDataBitwidth=obj.MasterChannelDataWidth;
        end
    end
end




