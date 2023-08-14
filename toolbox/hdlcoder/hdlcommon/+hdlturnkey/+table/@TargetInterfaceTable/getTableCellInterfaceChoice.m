function interfaceChoiceStr=getTableCellInterfaceChoice(obj,portName)





    hIOPort=obj.hIOPortList.getIOPort(portName);
    hInterfaceList=getInterfaceList(obj);
    if hIOPort.PortType==hdlturnkey.IOType.IN
        interfaceIDList=hInterfaceList.getInputInterfaceIDList;
    else
        interfaceIDList=hInterfaceList.getOutputInterfaceIDList;
    end
    interfaceChoiceStr=interfaceIDList;

end