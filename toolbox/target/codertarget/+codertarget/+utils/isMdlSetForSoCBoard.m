function out=isMdlSetForSoCBoard(cs)



    out=false;
    if cs.isValidParam('CoderTargetData')
        tgtHWInfo=codertarget.targethardware.getTargetHardware(cs);
        if codertarget.utils.isMdlConfiguredForSoC(cs)||...
            (~isempty(tgtHWInfo)&&isequal(tgtHWInfo.ESBCompatible,2))
            out=true;
        end
    end
end