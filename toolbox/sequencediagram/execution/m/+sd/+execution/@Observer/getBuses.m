function buses=getBuses(~,triggers)



    if~isempty(triggers)
        buses(numel(triggers))=Simulink.Bus;
        for ti=1:length(triggers)
            trigger=triggers(ti);
            bus=buildBus(trigger);
            if isempty(trigger.ElementQN)
                bus.Description=trigger.BackEndId;
            else
                bus.Description=[trigger.BackEndId,'.',trigger.ElementQN];
            end
            buses(ti)=bus;
        end
    else
        buses=[];
    end
end

function bus=buildBus(trigger)

    elems(1)=Simulink.BusElement;
    elems(1).Name='OrigPayload';
    elems(1).Dimensions=double(trigger.Dimensions);
    elems(1).DimensionsMode=trigger.DimensionsMode;
    elems(1).DataType=trigger.DataType;
    elems(1).Complexity=trigger.Complexity;
    elems(1).Min=[];
    elems(1).Max=[];
    elems(1).DocUnits='';
    elems(1).Description='';

    elems(2)=Simulink.BusElement;
    elems(2).Name='Metadata';
    elems(2).Dimensions=1;
    elems(2).DimensionsMode='Fixed';
    elems(2).DataType='Bus: slTestEventMetadata';
    elems(2).Complexity='real';
    elems(2).Min=[];
    elems(2).Max=[];
    elems(2).DocUnits='';
    elems(2).Description='';
    bus=Simulink.Bus;
    bus.HeaderFile='';
    bus.Description='';
    bus.DataScope='Auto';
    bus.Alignment=-1;
    bus.PreserveElementDimensions=0;
    bus.Elements=elems;
    clear elems;
end
