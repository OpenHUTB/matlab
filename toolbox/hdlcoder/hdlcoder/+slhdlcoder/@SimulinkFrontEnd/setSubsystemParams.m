function setSubsystemParams(this,configManager,thisNetwork)





    slnh=thisNetwork.SimulinkHandle;
    blockPath=getfullname(slnh);
    this.setNetworkRefCompParams(thisNetwork,configManager,blockPath,true);
end


