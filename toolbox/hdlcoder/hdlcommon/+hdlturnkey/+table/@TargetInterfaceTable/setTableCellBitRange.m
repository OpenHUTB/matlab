function setTableCellBitRange(obj,portName,newBitRangeStr)





    backIFUserSpec=obj.hTableMap.isInterfaceUserSpec(portName);


    backBitRangeStr=obj.hTableMap.getBitRangeStr(portName);
    backBRUserSpec=obj.hTableMap.isBitRangeUserSpec(portName);

    hIOPort=obj.hIOPortList.getIOPort(portName);
    portFullName=hIOPort.PortFullName;

    try

        obj.hTableMap.assignBitRange(portName,newBitRangeStr);
        obj.hTableMap.setBitRangeUserSpec(portName,true);

        if~obj.isMLHDLC&&~obj.hTurnkey.hD.getloadingFromModel
            if~hIOPort.isTunable&&~hIOPort.isTestPoint
                if~strcmp(hdlget_param(portFullName,'IOInterfaceMapping'),newBitRangeStr)
                    hdlset_param(portFullName,'IOInterfaceMapping',newBitRangeStr);
                end
            end
        end


        obj.assignDefaultBitRange;


        obj.hTableMap.setInterfaceUserSpec(portName,true);

    catch ME

        obj.hTableMap.setInterfaceUserSpec(portName,backIFUserSpec);


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


        rethrow(ME);
    end
end