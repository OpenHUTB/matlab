function sv=getHardwareSetting(hardwareData,aSetting)





    if isa(hardwareData,'coder.Hardware')
        sv=hardwareData.getCoderHardwareSetting(aSetting);
    else
        sv=hardwareData.(aSetting);
    end

    if isempty(sv)
        error(message('Coder:builtins:CoderHardwareSettingUndefined',aSetting));
    end

end