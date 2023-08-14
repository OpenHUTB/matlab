function[status,desc]=isSLCInstalledAndHardwareBoardNotNone(hCS,~)


    isSLCLicense=dig.isProductInstalled('Simulink Coder');
    isHardwareBoardNotNone=~isequal(get_param(hCS,'HardwareBoard'),'None');
    desc='unused';
    if isSLCLicense&&isHardwareBoardNotNone

        targetName=codertarget.target.getTargetName(hCS);
        targetType=codertarget.target.getTargetType(targetName);
        if isequal(targetType,0)||isequal(targetType,2)
            status=configset.internal.data.ParamStatus.ReadOnly;
        else
            status=configset.internal.data.ParamStatus.Normal;
        end
    else
        status=configset.internal.data.ParamStatus.ReadOnly;
    end
end
