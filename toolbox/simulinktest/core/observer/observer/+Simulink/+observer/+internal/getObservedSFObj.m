function sfObj=getObservedSFObj(opBlkH)

    blkH=Simulink.observer.internal.getObservedBlockForceLoad(opBlkH);
    sfObj=struct('Name','','ID','0','SSID','0','ChartBlk',blkH,...
    'BusType','','SFDataType','Unknown','StateActType','Unknown','Valid',false);
    if blkH==-1
        return;
    end
    elemType=Simulink.observer.internal.getObservedEntityType(opBlkH);
    ssid=Simulink.observer.internal.getObservedSFObjSSID(opBlkH);
    if strcmp(elemType,'SFState')
        actType=Simulink.observer.internal.getObservedStateActivityType(opBlkH);
        sfObj=Simulink.sltblkmap.internal.getSFObj(blkH,elemType,ssid,actType);
    elseif strcmp(elemType,'SFData')
        sfObj=Simulink.sltblkmap.internal.getSFObj(blkH,elemType,ssid);
    end

end

