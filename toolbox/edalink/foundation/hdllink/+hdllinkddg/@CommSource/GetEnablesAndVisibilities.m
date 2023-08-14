function[ens,vis]=GetEnablesAndVisibilities(this)
    ens.CosimBypass=1;
    ens.CommShowInfo=1;
    ens.CommLocal=1;
    ens.CommHostName=1;
    ens.CommSharedMemory=1;
    ens.CommPortNumber=1;

    vis.CosimBypass=1;
    if(this.CosimBypass==2)
        vis.CommLocal=0;
        vis.CommSharedMemory=0;
        vis.CommShowInfo=0;
        vis.CommHostName=0;
        vis.CommPortNumber=0;
    else
        vis.CommLocal=1;
        vis.CommSharedMemory=1;
        vis.CommShowInfo=1;
        vis.CommHostName=1;
        vis.CommPortNumber=1;
    end

    if this.CommLocal
        ens.CommHostName=0;
    else
        ens.CommSharedMemory=0;
    end

    if strcmp(this.CommSharedMemory,'Shared Memory')
        ens.CommHostName=0;
        vis.CommPortNumber=0;
    end
    vis.CommSharedMemoryTxt=vis.CommSharedMemory;
    vis.CommHostNameTxt=vis.CommHostName;
    vis.CommPortNumberTxt=vis.CommPortNumber;

end
