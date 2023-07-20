function EventName=getMappedTaskEventName(ModelName,MappedTaskName)





    EventName='All';

    IrqInfo=codertarget.interrupts.internal.getIrqInfo(ModelName,MappedTaskName);
    if~isempty(IrqInfo)&&~isempty(IrqInfo.EventsInfo)
        EventName=IrqInfo.EventsInfo(1).Name;
    end
    EventName='All';
end

