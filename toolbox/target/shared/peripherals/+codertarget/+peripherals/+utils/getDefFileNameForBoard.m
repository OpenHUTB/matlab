function defFile=getDefFileNameForBoard(hCS)





    if ischar(hCS)
        hCS=getActiveConfigSet(hCS);
    end

    defFile=char.empty;
    tgtHwInfo=codertarget.targethardware.getTargetHardware(hCS);
    if~isempty(tgtHwInfo)
        [~,name,ext]=fileparts(tgtHwInfo.DefinitionFileName);
        defFolder=fullfile(tgtHwInfo.TargetFolder,'registry','peripherals');
        defFile=fullfile(defFolder,[name,'Peripherals',ext]);
    end
end
