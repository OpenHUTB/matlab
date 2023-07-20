function setTableCellOption(obj,portName,interfaceOpt)


    backIFUserSpec=obj.hTableMap.isInterfaceUserSpec(portName);


    backOptionPVPair=obj.hTableMap.getInterfaceOption(portName);
    backOptionSpec=obj.hTableMap.isInterfaceOptionUserSpec(portName);


    hIOPort=obj.hIOPortList.getIOPort(portName);
    portFullName=hIOPort.PortFullName;

    try



        obj.hTableMap.assignInterfaceOption(portName,interfaceOpt);
        obj.hTableMap.setInterfaceOptionUserSpec(portName,true);


        hInterface=obj.hTableMap.getInterface(portName);
        hInterface.allocateUserSpecInterfaceOption(portName,obj.hTableMap);


        if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
            if~hIOPort.isTunable&&~hIOPort.isTestPoint
                if~isequal(hdlget_param(portFullName,'IOInterfaceOptions'),interfaceOpt)
                    hdlset_param(portFullName,'IOInterfaceOptions',interfaceOpt);
                end
            end
        end


        obj.hTableMap.setInterfaceUserSpec(portName,true);

    catch ME

        obj.hTableMap.setInterfaceUserSpec(portName,backIFUserSpec);


        if backOptionSpec

            obj.hTableMap.assignInterfaceOption(portName,backOptionPVPair);
            if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
                if~hIOPort.isTunable&&~hIOPort.isTestPoint
                    if~isequal(hdlget_param(portFullName,'IOInterfaceOptions'),backOptionPVPair)
                        hdlset_param(portFullName,'IOInterfaceOptions',backOptionPVPair);
                    end
                end
            end
        end
        obj.hTableMap.setInterfaceOptionUserSpec(portName,backOptionSpec);


        hInterface=obj.hTableMap.getInterface(portName);
        hInterface.allocateUserSpecInterfaceOption(portName,obj.hTableMap);


        rethrow(ME);
    end

end