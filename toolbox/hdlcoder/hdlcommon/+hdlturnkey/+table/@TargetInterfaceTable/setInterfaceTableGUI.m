function[launchAddInterfaceGUI,launchSetInterfaceOptGUI]=setInterfaceTableGUI(obj,rowIdx,colIdx,newValue)




    launchAddInterfaceGUI=false;
    launchSetInterfaceOptGUI=false;


    InterfaceIdx=3;
    BitRangeIdx=4;
    InterfaceOptionIdx=5;


    lengthInputPort=length(obj.hIOPortList.InputPortNameList);
    if rowIdx+1<=lengthInputPort
        portName=obj.hIOPortList.InputPortNameList{rowIdx+1};
    else
        portName=obj.hIOPortList.OutputPortNameList{rowIdx+1-lengthInputPort};
    end


    if colIdx==InterfaceIdx



        interfaceStrList=obj.getTableCellInterfaceChoice(portName);
        newIndex=newValue+1;
        interfaceStr=interfaceStrList{newIndex};

        if strcmp(interfaceStr,hdlturnkey.interface.InterfaceAddMore.DefaultInterfaceID)

            launchAddInterfaceGUI=true;
        else

            obj.setTableCellInterface(portName,interfaceStr);
        end

    elseif colIdx==InterfaceOptionIdx

        hIOPort=obj.hIOPortList.getIOPort(portName);

        launchSetInterfaceOptGUI=obj.hTableMap.showInterfaceOptionPushButton(hIOPort);

    elseif colIdx==BitRangeIdx



        if obj.hTableMap.isBitRangeComboBox(portName)
            bitRangeStrList=obj.hTableMap.getBitRangeChoice(portName);
            newIndex=newValue+1;
            newBitRangeStr=bitRangeStrList{newIndex};
        else
            newBitRangeStr=newValue;
        end


        obj.setTableCellBitRange(portName,newBitRangeStr)

    end

end

