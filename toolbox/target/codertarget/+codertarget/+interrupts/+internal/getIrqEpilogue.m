function irqEpilogue=getIrqEpilogue(modelName,isrName,irqNumber)





    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(modelName);
    irqEpilogue=intdef.Epilogue;

    if~isempty(irqEpilogue)

        irqEpilogue=strrep(irqEpilogue,intdef.TokenInterruptName,isrName);

        irqNumber=convertStringsToChars(irqNumber);
        if isnumeric(irqNumber)
            irqNumber=num2str(irqNumber);
        end
        irqEpilogue=strrep(irqEpilogue,intdef.TokenInterruptNumber,irqNumber);
    else
        irqEpilogue='';
    end

end

