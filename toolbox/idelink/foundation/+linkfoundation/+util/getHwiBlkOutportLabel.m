function irqMaskStr=getHwiBlkOutportLabel(irqnumbers)





    if ischar(irqnumbers)
        irq=eval(irqnumbers);
    elseif isnumeric(irqnumbers)
        irq=irqnumbers;
    else
        irqMaskStr='N';
        return;
    end


    irqNum=numel(irq);
    if irqNum==1
        irqMaskStr=num2str(irq(1));
    else
        irqMaskStr='N';










    end


