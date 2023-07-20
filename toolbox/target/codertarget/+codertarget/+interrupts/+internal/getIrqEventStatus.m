function EventStatus=getIrqEventStatus(ModelName,IrqName,EventName)





    if nargin<=2
        EventName='All';
    end

    EventStatus='';
    if~(isempty(EventName)||isequal(EventName,'All')||isequal(EventName,'None'))
        EventInfo=codertarget.interrupts.internal.getIrqEventInfo(ModelName,IrqName,EventName);
        if~isempty(EventInfo)
            EventStatus=EventInfo.EventStatus;
        end
    end
end

