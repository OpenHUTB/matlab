function className=getImplementationClassName(this,blockLibPath,implDB)









    className=[];

    implInfo=this.getImplInfoForBlockLibPath(blockLibPath);
    if~isempty(implInfo)
        archName=implInfo.ArchitectureName;
        className=implDB.getImplementationForArch(blockLibPath,archName);
    end