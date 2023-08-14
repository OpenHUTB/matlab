function out=configureQueueForAUTOSAR(portPath)



    busElementPort=autosar.simulink.bep.AbstractBusElementPort.BusElementPortFactory(bdroot(portPath));
    busElementPort.setMessageQueueProperties(portPath);

    out='Queue configured';
