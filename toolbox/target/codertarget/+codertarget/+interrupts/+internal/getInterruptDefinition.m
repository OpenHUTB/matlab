function ret=getInterruptDefinition(ModelName,IsrName,IrqNumber)





    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(ModelName);
    intgrp=getInterruptGroupBasedOnInterruptName(intdef,IsrName);

    ret=intgrp.IsrDefinitionSignature;

    if~isempty(intgrp)

        ret=strrep(ret,intdef.TokenInterruptName,IsrName);

        IrqNumber=convertStringsToChars(IrqNumber);
        if isnumeric(IrqNumber)
            IrqNumber=num2str(IrqNumber);
        end
        ret=strrep(ret,intdef.TokenInterruptNumber,IrqNumber);
    end
end


