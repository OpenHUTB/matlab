function[isNonAutoStorageCls,propValue]=isSignalObjectSpecified(modelName,blk,isInport)




    isNonAutoStorageCls=false;
    sigName='';
    storageClass='';
    if isInport
        ph=get_param(blk,'PortHandles');
        if~isempty(ph.Outport)
            if strcmp(get_param(ph.Outport,'MustResolveToSignalObject'),'on')
                sigName=get_param(ph.Outport,'Name');
                storageClass=Simulink.CodeMapping.getStorageClass(modelName,sigName);
                isNonAutoStorageCls=~strcmp(storageClass,'Auto');
            else
                storageClass=get_param(ph.Outport,'StorageClass');
                sigName=get_param(ph.Outport,'Name');
                if~strcmp(storageClass,'Auto')
                    isNonAutoStorageCls=true;
                end
            end
        end
    else
        if strcmp(get_param(blk,'MustResolveToSignalObject'),'on')
            sigName=get_param(blk,'SignalName');
            storageClass=Simulink.CodeMapping.getStorageClass(modelName,sigName);
            isNonAutoStorageCls=~strcmp(storageClass,'Auto');
        else
            storageClass=get_param(blk,'StorageClass');
            sigName=get_param(blk,'SignalName');
            if~strcmp(storageClass,'Auto')
                isNonAutoStorageCls=true;
            end
        end
    end
    propValue=[sigName,':',storageClass];
end
