function ret=isISRMaskable(ModelName,IsrName)





    isr=codertarget.interrupts.internal.getIrqInfo(ModelName,IsrName);
    if~isempty(isr)
        ret=isr.Maskable;
    else
        ret=true;
    end
end

