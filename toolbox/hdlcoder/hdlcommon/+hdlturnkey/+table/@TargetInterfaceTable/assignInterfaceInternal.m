function hNewInterface=assignInterfaceInternal(obj,portName,newInterfaceStr)





    obj.validateInInterfaceChoice(portName,newInterfaceStr);


    hInterfaceList=getInterfaceList(obj);
    interfaceID=hInterfaceList.getInterfaceIDFromDispStr(newInterfaceStr);
    hNewInterface=hInterfaceList.getInterface(interfaceID);


    obj.hTableMap.assignInterface(portName,hNewInterface,newInterfaceStr);
    obj.hTableMap.setInterfaceUserSpec(portName,true);

end