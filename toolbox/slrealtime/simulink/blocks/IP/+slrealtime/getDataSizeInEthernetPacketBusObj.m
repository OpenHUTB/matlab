function width=getDataSizeInEthernetPacketBusObj






    if Simulink.data.existsInGlobal(bdroot,"Ethernet_Packet")
        EthPacketBusObj=Simulink.data.evalinGlobal(bdroot,"Ethernet_Packet");
        width=EthPacketBusObj.Elements(1).Dimensions(1);
    else
        width=0;
    end
