function isEnabled=getIsOneClickEnabled(hCS)






    persistent targetMap;
    if isempty(targetMap)
        targetMap=containers.Map;
    end
    if codertarget.target.isCoderTarget(hCS)&&...
        codertarget.data.isParameterInitialized(hCS,'TargetHardware')
        targetHardwareName=codertarget.data.getParameterValue(hCS,'TargetHardware');







        featureSet=get_param(hCS,'HardwareBoardFeatureSet');
        key=sprintf('%s (%s)',targetHardwareName,featureSet);
        if~targetMap.isKey(key)
            targetInfo=codertarget.attributes.getTargetHardwareAttributes(hCS);
            targetMap(key)=~isempty(targetInfo)&&targetInfo.EnableOneClick;
        end
        isEnabled=targetMap(key);
    else
        isEnabled=false;
    end
end