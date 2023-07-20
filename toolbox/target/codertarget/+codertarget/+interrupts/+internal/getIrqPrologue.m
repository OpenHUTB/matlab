function irqPrologue=getIrqPrologue(modelName,isrName,irqNumber)





    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(modelName);
    irqPrologue=intdef.Prologue;

    if~isempty(irqPrologue)

        irqPrologue=strrep(irqPrologue,intdef.TokenInterruptName,isrName);

        irqNumber=convertStringsToChars(irqNumber);
        if isnumeric(irqNumber)
            irqNumber=num2str(irqNumber);
        end
        irqPrologue=strrep(irqPrologue,intdef.TokenInterruptNumber,irqNumber);
    else
        irqPrologue='';
    end

end

