function setTableCellInterface(obj,portName,newInterfaceStr)











    hIOPort=obj.hIOPortList.getIOPort(portName);
    portFullName=hIOPort.PortFullName;

    backInterface=obj.hTableMap.getInterface(portName);
    backInterfaceStr=obj.hTableMap.getInterfaceStr(portName);
    backIFUserSpec=obj.hTableMap.isInterfaceUserSpec(portName);

    backBitRangeStr=obj.hTableMap.getBitRangeStr(portName);
    backBRUserSpec=obj.hTableMap.isBitRangeUserSpec(portName);

    try

        hNewInterface=obj.assignInterfaceInternal(portName,newInterfaceStr);


        obj.assignDefaultBitRange;


        obj.hTableMap.setBitRangeUserSpec(portName,true);


        obj.hTableMap.buildInterfaceIOMap;


        hNewInterface.finishAssignInterface(obj.hTurnkey);


        obj.hTurnkey.refreshTableInterface;


        if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
            newInterfaceTableStr=hNewInterface.getTableCellInterfaceStr(portName);
            if~hIOPort.isTunable&&~hIOPort.isTestPoint
                if~strcmp(hdlget_param(portFullName,'IOInterface'),newInterfaceTableStr)
                    hdlset_param(portFullName,'IOInterface',newInterfaceTableStr);
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


        if backBRUserSpec
            obj.hTableMap.assignBitRange(portName,backBitRangeStr);
            if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
                if~hIOPort.isTunable&&~hIOPort.isTestPoint
                    if~strcmp(hdlget_param(portFullName,'IOInterfaceMapping'),backBitRangeStr)
                        hdlset_param(portFullName,'IOInterfaceMapping',backBitRangeStr);
                    end
                end
            end
        end
        obj.hTableMap.setBitRangeUserSpec(portName,backBRUserSpec);


        obj.assignDefaultBitRange;


        obj.hTableMap.buildInterfaceIOMap;


        obj.hTurnkey.refreshTableInterface;


        rethrow(ME);
    end
end
