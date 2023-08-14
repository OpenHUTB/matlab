function[status,desc]=isSLCAndECInstalledAndHardwareBoardNotNone(hCS,~)


    isECLicense=dig.isProductInstalled('Embedded Coder');
    isSLCLicense=dig.isProductInstalled('Simulink Coder');
    isHardwareBoardNotNone=~isequal(get_param(hCS,'HardwareBoard'),'None');
    desc='unused';
    if isECLicense&&isSLCLicense&&isHardwareBoardNotNone

        targetName=codertarget.target.getTargetName(hCS);
        targetType=codertarget.target.getTargetType(targetName);
        if isequal(targetType,0)
            status=configset.internal.data.ParamStatus.ReadOnly;
        else
            status=configset.internal.data.ParamStatus.Normal;
        end
    else
        status=configset.internal.data.ParamStatus.ReadOnly;
    end
end
