function hdlblkinfo=getSubsystemImplInfo(this)%#ok<INUSD>





    hdlblkinfo=containers.Map;
    ssImpl=hdldefaults.Subsystem;
    archName=ssImpl.getArchitectureName;
    hdlblkinfo(archName)=ssImpl.getImplParamInfo;
