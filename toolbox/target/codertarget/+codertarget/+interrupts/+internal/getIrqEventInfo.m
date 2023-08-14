function EventInfo=getIrqEventInfo(ModelName,IrqName,EventName)





    if nargin<=2
        EventName='All';
    end

    EventInfo=codertarget.interrupts.Event.empty;
    IrqInfo=codertarget.interrupts.internal.getIrqInfo(ModelName,IrqName);
    if~isempty(IrqInfo)
        if isequal(EventName,'None')
        elseif isequal(EventName,'All')
            EventInfo=IrqInfo.EventsInfo;
        else
            EventNames={IrqInfo.EventsInfo(:).Name};
            if ismember(EventName,EventNames)
                EventInfo=IrqInfo.EventsInfo(ismember(EventNames,EventName));
            end
        end
    end
end
