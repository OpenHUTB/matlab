function[sectionIds,timerValues,coreNums]=getProfileData(modelName)











    hCS=getActiveConfigSet(modelName);
    hardwareName=codertarget.targethardware.getTargetHardwareName(hCS);
    [ipAddress,userName,password,~,portNumber]=codertarget.arm_cortex_a.internal.getConnectionInfo(hardwareName);


    ssh=matlabshared.internal.ssh2client(ipAddress,userName,password,portNumber);
    [~,name,~]=fileparts(modelName);
    filename=[name,'.txt'];
    scpGetFile(ssh,filename,filename);


    d=importdata(filename);
    sectionIds=uint32(d(:,1));
    timerValues=uint32(d(:,2));
    [~,w]=size(d);
    if(w>2)
        coreNums=uint32(d(:,3));
    else
        coreNums=[];
    end
end
