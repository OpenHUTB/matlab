function IrqInfo=getIrqInfo(ModelName,IrqName)





    IrqInfo=codertarget.interrupts.Interrupt.empty;
    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(ModelName);
    if~isempty(intdef)
        isrs=getAllInterrupts(intdef);
        isrnames={isrs(:).Name};
        idx=ismember(isrnames,IrqName);
        if any(idx)
            IrqInfo=isrs(idx);
        end
    end
end

