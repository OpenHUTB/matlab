function ret=getEpilogueSoftwarePriority(ModelName,IrqNumber,IrqPriorityList)





    ret='';
    intdef=codertarget.interrupts.internal.getHardwareBoardInterruptInfo(ModelName);
    PriorityList=[IrqPriorityList.IrqPriorityList{:}];
    if intdef.SoftwareManagedPriority
        ret=feval(intdef.CallbackForPriorityManagement,IrqNumber,PriorityList,'Epilogue');
    end
end

