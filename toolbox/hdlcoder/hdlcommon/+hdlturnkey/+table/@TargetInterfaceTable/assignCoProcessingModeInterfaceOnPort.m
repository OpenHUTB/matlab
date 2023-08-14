function assignCoProcessingModeInterfaceOnPort(obj,portName,hDefaultBusInterface)










    backInterface=obj.hTableMap.getInterface(portName);
    backInterfaceStr=obj.hTableMap.getInterfaceStr(portName);
    backIFUserSpec=obj.hTableMap.isInterfaceUserSpec(portName);

    hIOPort=obj.hIOPortList.getIOPort(portName);
    portFullName=hIOPort.PortFullName;

    try
        if~obj.hTableMap.isInterfaceUserSpec(portName)

            defaultInterfaceID=hDefaultBusInterface.InterfaceID;
            assignInterfaceInternal(obj,portName,defaultInterfaceID);

            if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
                newInterfaceTableStr=hDefaultBusInterface.getTableCellInterfaceStr(portName);
                if~hIOPort.isTunable&&~hIOPort.isTestPoint
                    if~strcmp(hdlget_param(portFullName,'IOInterface'),newInterfaceTableStr)
                        hdlset_param(portFullName,'IOInterface',newInterfaceTableStr);
                    end
                end
            end
        end

    catch ME

        obj.hTableMap.assignInterface(portName,backInterface,backInterfaceStr);
        obj.hTableMap.setInterfaceUserSpec(portName,backIFUserSpec);

        if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
            newInterfaceTableStr=backInterface.getTableCellInterfaceStr(portName);
            if~hIOPort.isTunable&&~hIOPort.isTestPoint
                if~strcmp(hdlget_param(portFullName,'IOInterface'),newInterfaceTableStr)
                    hdlset_param(portFullName,'IOInterface',newInterfaceTableStr);
                end
            end
        end


        rethrow(ME);
    end
end
