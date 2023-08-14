function EventClearStatus=getIrqEventClearStatus(ModelName,IrqName,EventName)





    if nargin<=2
        EventName='All';
    end

    EventClearStatus='';

    if~(isempty(EventName)||isequal(EventName,'None'))
        EventInfo=codertarget.interrupts.internal.getIrqEventInfo(ModelName,IrqName,EventName);
        if~isempty(EventInfo)
            if isequal(EventName,'All')
                for i=1:numel(EventInfo)
                    if~isempty(EventInfo(i).ClearEventStatus)
                        EventClearStatus=[EventClearStatus,EventInfo(i).ClearEventStatus,newline];%#ok<AGROW>
                    end
                end
            else
                EventClearStatus=EventInfo.ClearEventStatus;
            end
        end
    end
end
