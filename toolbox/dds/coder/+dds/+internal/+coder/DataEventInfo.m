classdef DataEventInfo





    properties(Access=private)
dataEvents
dataEventDefaults
portParams
DDSEvents
dataEvent2DefaultEvent
        dataEvent2DDSEvent;
    end

    methods
        function h=DataEventInfo

            h.dataEvents={'simulink.event.InputWrite','simulink.event.InputWriteTimeout','simulink.event.InputWriteLost'};


            h.dataEventDefaults={'InputWrite','InputWriteTimeout','InputWriteLost'};


            h.DDSEvents={'onDataAvailable','onDataDeadlineMissed','onSampleLost'};


            h.dataEvent2DefaultEvent=containers.Map(h.dataEvents,h.dataEventDefaults);


            h.dataEvent2DDSEvent=containers.Map(h.dataEvents,h.DDSEvents);
        end

        function[eventType,eventNotification,inportIdx]=getEvent(h,inportInfos,modelName,eventName)
            auto_setting='Auto';
            eventType=[];
            eventNotification=[];

            for ii=1:length(inportInfos)
                portName=inportInfos(ii).graphicalName;
                inportIdx=ii;
                portFullName=strcat(modelName,'/',portName);

                constructedEventName=h.getConstructEventNameFromPortName(portFullName);
                dataEventArray=get_param(portFullName,'EventTriggers');

                for jj=1:numel(dataEventArray)
                    dataEventParam=dataEventArray{jj};
                    dataEventKind=class(dataEventParam);
                    if strcmp(dataEventParam.EventName,eventName)||...
                        strcmpi(dataEventParam.EventName,auto_setting)&&...
                        h.getIsDefaultEvent(constructedEventName,dataEventKind,eventName)
                        eventNotification=h.getEventNotification(modelName,portFullName);
                        try
                            eventType=h.getDDSEvent(class(dataEventParam));
                        catch ME
                            switch ME.identifier
                            case 'MATLAB:Containers:Map:NoKey'

                                error(message('dds:cgen:NotSupportedDataEvent',eventName));
                            otherwise
                                rethrow(ME);
                            end
                        end

                        return;
                    end
                end
            end
        end
    end

    methods(Access=private)
        function dataEvents=getDataEvents(h)
            dataEvents=h.dataEvents;
        end

        function DDSEvent=getDDSEvent(h,dataEvent)
            DDSEvent=h.dataEvent2DDSEvent(dataEvent);
        end

        function isDefaultEvent=getIsDefaultEvent(h,constructedEventName,dataEventKind,eventName)


            scopeAndEvent=strsplit(eventName,'.');
            isDefaultEvent=(numel(scopeAndEvent)>=2)&&...
            strcmp(scopeAndEvent{end-1},constructedEventName)&&...
            strcmp(scopeAndEvent{end},h.dataEvent2DefaultEvent(dataEventKind));
        end
    end

    methods(Static,Access=private)
        function constructedEventName=getConstructEventNameFromPortName(portFullName)



            isBEP=get_param(portFullName,'IsBusElementPort');
            if isBEP
                element=get_param(portFullName,'Element');
                constructedEventName=get_param(portFullName,'PortName');
                if~isempty(element)
                    flattenedElement=replace(element,'.','_');
                    constructedEventName=[constructedEventName,'_',flattenedElement];
                end
            else
                constructedEventName=portName;
            end
        end
    end
    methods(Static)

        function eventNotification=getEventNotification(modelName,blockName)
            mapping=Simulink.CodeMapping.getCurrentMapping(modelName);

            for k=1:length(mapping.Inports)
                if strcmp(mapping.Inports(k).Block,blockName)
                    eventNotification=mapping.Inports(k).MessageCustomization.EventNotification;
                    return;
                end
            end
        end
    end
end
