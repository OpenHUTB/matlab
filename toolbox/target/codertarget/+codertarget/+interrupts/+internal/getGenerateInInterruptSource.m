function ret=getGenerateInInterruptSource(modelName)




    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(modelName);
    if~isempty(intdef)
        ret=intdef.GenerateInInterruptsSource;
    else
        ret=true;
    end


end
