function IrqNumber=getIrqNumber(ModelName,IsrName)





    IrqInfo=codertarget.interrupts.internal.getIrqInfo(ModelName,IsrName);
    if~isempty(IrqInfo)
        IrqNumber=IrqInfo.Number;
    else
        IrqNumber=[];
    end
end

