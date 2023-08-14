function list=getRegisteredTargets




    targetHardwareObj=realtime.internal.TargetHardware.getInstance('get');
    list={};
    if~isempty(targetHardwareObj)
        for ii=1:numel(targetHardwareObj.SupportPackageNames)
            thInfo=realtime.internal.TargetHardware.getTargetHardwareInfoFromRegistry(targetHardwareObj.SupportPackageNames{ii});
            list=[list,thInfo.keys];%#ok<AGROW>
        end

        list=list(~ismember(list,realtime.internal.TargetHardware.getAllDeprecatedTargetHardwares()));
    end
end