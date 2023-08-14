function intdef=getHardwareBoardInterruptInfo(hObj)




    if isa(hObj,'CoderTarget.SettingsController')
        hObj=hObj.getConfigSet();
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    else
        assert(isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')||...
        isa(hObj,'coder.CodeConfig'),...
        [mfilename,' called with a wrong argument']);
    end

    tgtHWInfo=codertarget.targethardware.getTargetHardware(hObj);
    intdef=[];


    intDefRegistry=which('matlabshared.svd.internal.InterruptDefRegistry');
    if exist(intDefRegistry,'file')
        boardFeature=get_param(hObj,'HardwareBoardFeatureSet');
        if isequal(boardFeature,'SoCBlockset')
            baseProduct=codertarget.targethardware.BaseProductID.SOC;
        else
            baseProduct=codertarget.targethardware.BaseProductID.EC;
        end
        hwName=get_param(hObj,'HardwareBoard');
        intdefFromRegistry=matlabshared.svd.internal.InterruptDefRegistry.getInterruptDefFromRegistry(hwName,'BaseProductID',baseProduct,'CPU','all');
        if~isempty(intdefFromRegistry)
            intdef=intdefFromRegistry.InterruptDefinition;
        end
    end


    if~isempty(tgtHWInfo)&&isempty(intdef)



        try
            if isequal(get_param(hObj,'HardwareBoardFeatureSet'),'EmbeddedCoderHSP')
                cpuName='';
            else
                cpuName=codertarget.targethardware.getProcessingUnitName(hObj);
                tempData=get_param(hObj,'TemporaryCoderTargetData');

                if isfield(tempData,'SelectedCPUName')&&strcmpi(cpuName,'None')
                    cpuName=tempData.SelectedCPUName;
                end
            end
            defFile=codertarget.interrupts.internal.getDefFileName(tgtHWInfo,cpuName);
            intdef=codertarget.interrupts.HWInterruptInfo(defFile);
        catch
        end
    end
end
