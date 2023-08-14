function ret=isValidIrqName(modelname,mappedIrqName)



    IrqNames=codertarget.interrupts.internal.getAllIrqNames(modelname);
    if~isempty(IrqNames)
        ret=any(ismember(IrqNames,mappedIrqName));
    else
        ret=false;
    end
end

