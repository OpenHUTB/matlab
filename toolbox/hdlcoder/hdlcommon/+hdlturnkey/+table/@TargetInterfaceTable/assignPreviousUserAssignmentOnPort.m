function assignPreviousUserAssignmentOnPort(obj,portName)











    if~obj.hIOPortListRef.IOPortMap.isKey(portName)||...
        ~obj.hTableMapRef.isInterfaceMapKey(portName)
        return;
    end


    backInterface=obj.hTableMap.getInterface(portName);
    backInterfaceStr=obj.hTableMap.getInterfaceStr(portName);
    backIFUserSpec=obj.hTableMap.isInterfaceUserSpec(portName);

    backBitRangeStr=obj.hTableMap.getBitRangeStr(portName);
    backBRUserSpec=obj.hTableMap.isBitRangeUserSpec(portName);

    backInterfaceOption=obj.hTableMap.getInterfaceOption(portName);
    backInterfaceOptionUserSpec=obj.hTableMap.isInterfaceOptionUserSpec(portName);

    try
        newInterface=false;


        if obj.hTableMapRef.isInterfaceUserSpec(portName)

            newInterfaceStr=obj.hTableMapRef.getBackupInterfaceStr(portName);

            hNewInterface=obj.assignInterfaceInternal(portName,newInterfaceStr);
            newInterface=true;
        end


        if obj.hTableMapRef.isBitRangeUserSpec(portName)


            if~obj.hTableMapRef.isInterfaceUserSpec(portName)

                newInterfaceStr=obj.hTableMapRef.getBackupInterfaceStr(portName);

                hNewInterface=assignInterfaceInternal(obj,portName,newInterfaceStr);
                newInterface=true;
            end
            bitRangeStr=obj.hTableMapRef.getBackupBitRangeStr(portName);
            obj.hTableMap.assignBitRange(portName,bitRangeStr);
            obj.hTableMap.setBitRangeUserSpec(portName,true);
        end


        if obj.hTableMapRef.isInterfaceOptionUserSpec(portName)


            if~obj.hTableMapRef.isInterfaceUserSpec(portName)

                newInterfaceStr=obj.hTableMapRef.getBackupInterfaceStr(portName);

                hNewInterface=assignInterfaceInternal(obj,portName,newInterfaceStr);
                newInterface=true;
            end
            interfaceOption=obj.hTableMapRef.getBackupInterfaceOption(portName);
            obj.hTableMap.assignInterfaceOption(portName,interfaceOption);
            obj.hTableMap.setInterfaceOptionUserSpec(portName,true);
        end

        if newInterface

            hNewInterface.finishAssignInterface(obj.hTurnkey);
        end

    catch ME

        obj.hTableMap.assignInterface(portName,backInterface,backInterfaceStr);
        obj.hTableMap.setInterfaceUserSpec(portName,backIFUserSpec);


        obj.hTableMap.assignBitRange(portName,backBitRangeStr);
        obj.hTableMap.setBitRangeUserSpec(portName,backBRUserSpec);


        obj.hTableMap.assignInterfaceOption(portName,backInterfaceOption);
        obj.hTableMap.setInterfaceOptionUserSpec(portName,backInterfaceOptionUserSpec);


        rethrow(ME);
    end

end

