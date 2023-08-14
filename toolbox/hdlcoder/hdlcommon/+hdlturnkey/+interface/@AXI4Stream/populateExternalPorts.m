function populateExternalPorts(obj,hN,hChannel,hElab)





















    PortExtData={'TDATA',obj.hTDataType,'Data'};
    PortExtValid={'TVALID',obj.hUfix1Type,''};
    PortExtReady={'TREADY',obj.hUfix1Type,''};
    PortExtTLAST={'TLAST',obj.hUfix1Type,'TLAST'};

    PortExtTSTRB={'TSTRB',obj.hTSTRBType,'TSTRB'};
    PortExtTKEEP={'TKEEP',obj.hTKEEPType,'TKEEP'};
    PortExtTID={'TID',obj.hTIDType,'TID'};
    PortExtTDEST={'TDEST',obj.hTDESTType,'TDEST'};
    PortExtTUSER={'TUSER',obj.hTUSERType,'TUSER'};


    extSideBandPortGroup={...
    PortExtTSTRB,...
    PortExtTKEEP,...
    PortExtTID,...
    PortExtTDEST,...
    PortExtTUSER,...
    };







    extMasterOutputPortList={...
    PortExtData,...
    PortExtValid,...
    PortExtTLAST,...
    };

    for ii=1:length(extSideBandPortGroup)
        portCell=extSideBandPortGroup{ii};
        [~,~,hSubPort]=hdlturnkey.interface.ChannelBased.getExternalPortInfo(hChannel,portCell,hElab);


        if~hSubPort.isAssigned
            continue;
        end

        extMasterOutputPortList{end+1}=portCell;%#ok<*AGROW>
    end




    extSlaveInputPortList={...
    PortExtData,...
    PortExtValid,...
    };
    if hElab.hTurnkey.hD.isAlteraIP




        extSlaveInputPortList{end+1}=PortExtTLAST;
    elseif hChannel.isSampleControlBusAssigned


        extSlaveInputPortList{end+1}=PortExtTLAST;
    elseif hChannel.isTLASTPortAssigned


        extSlaveInputPortList{end+1}=PortExtTLAST;
    end

    for ii=1:length(extSideBandPortGroup)
        portCell=extSideBandPortGroup{ii};
        [~,~,hSubPort]=hdlturnkey.interface.ChannelBased.getExternalPortInfo(hChannel,portCell,hElab);


        if~hSubPort.isAssigned
            continue;
        end

        extSlaveInputPortList{end+1}=portCell;
    end


    extSlaveDrivenPortList={...
    PortExtReady,...
    };





    hdlturnkey.interface.ChannelBased.populateExternalChannelPort(hN,hChannel,...
    extSlaveDrivenPortList,extMasterOutputPortList,...
    extSlaveInputPortList,extSlaveDrivenPortList,hElab);

end


