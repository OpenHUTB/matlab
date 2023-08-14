classdef Event<handle





    properties(SetAccess='protected',GetAccess='public')
        Name(1,:)char='';
        EventStatus(1,:)char='';
        ClearEventStatus(1,:)char='';
    end

    methods
        function obj=Event(EvtName)


            obj.Name=EvtName;
        end

        function set.Name(obj,value)


            obj.Name=value;
        end

        function set.EventStatus(obj,value)


            obj.EventStatus=value;
        end

        function set.ClearEventStatus(obj,value)


            obj.ClearEventStatus=value;
        end

        function setEventStatus(obj,checkflag)
            obj.EventStatus=checkflag;
        end

        function setClearEventStatus(obj,clearEvt)
            obj.ClearEventStatus=clearEvt;
        end

        function EventStruct=getEventStruct(obj)
            props=properties(obj);
            for i=1:numel(props)
                EventStruct.(props{i})=obj.(props{i});
            end
        end
    end

    methods(Static)
        function convertEventStruct(eventStruct)
            props=properties(codertarget.interrupts.Event.empty);

            assert(isfield(eventStruct,'Name'),'Name field does not exist.');
            evt=codertarget.interrupts.Event(eventStruct.Name);
            for i=numel(props)
                if isfield(eventStruct,'EventStatus')
                    setEventStatus(evt,eventStruct.EventStatus);
                elseif isfield(eventStruct,'ClearEventStatus')
                    setClearEventStatus(evt,eventStruct.ClearEventStatus);
                end
            end
        end
    end
end

