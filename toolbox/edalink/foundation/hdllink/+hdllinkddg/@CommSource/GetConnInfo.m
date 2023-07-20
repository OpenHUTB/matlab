function info=GetConnInfo(this)
    info.isShared=strcmp('Shared Memory',this.CommSharedMemory);
    info.isOnLocalHost=this.CommLocal;
    info.hostName=this.CommHostName;
    info.portNumber=this.CommPortNumber;
end