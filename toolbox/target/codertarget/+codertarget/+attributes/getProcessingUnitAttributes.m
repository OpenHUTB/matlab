function out=getProcessingUnitAttributes(procUnit)





    out=[];
    validateattributes(procUnit,{'codertarget.targethardware.ProcessingUnitInfo'},{});
    if~isempty(procUnit)
        defFile=codertarget.utils.replaceTokensforHardwareName(procUnit,procUnit.AttributeInfoFile);
        if~isempty(defFile)
            out=codertarget.Registry.manageInstance('get','attributes',defFile);
        end
    end
end

