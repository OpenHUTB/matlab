classdef Interrupt<codertarget.Info




    properties(SetAccess='protected',GetAccess='public')
        Name char=[];
        Number int32=[];
        Priority=0;
        EventsInfo codertarget.interrupts.Event=codertarget.interrupts.Event.empty;
        Maskable logical=true;
    end

    methods
        function obj=Interrupt(Name,Number,DefaultPriority)
            if nargin<3
                DefaultPriority=0;
            end
            obj.Name=Name;
            obj.Number=Number;
            obj.Priority=DefaultPriority;
        end

        function set.Name(obj,value)
            if~isvarname(value)
                error('codertarget:interrupts:InvalidISRName','Invalid ISR name.');
            end
            obj.Name=value;
        end

        function set.EventsInfo(obj,value)
            obj.EventsInfo=value;
        end

        function setPriority(obj,value)
            if ischar(value)||isstring(value)
                value=str2double(convertStringsToChars(value));
            end

            validateattributes(value,{'numeric'},{'nonempty','scalar'},'','Maskable');
            obj.Priority=value;
        end

        function evtret=addNewEvent(obj,EventName)

            evtnames=getEventNames(obj);
            if~isempty(evtnames)
                assert(isempty(intersect(evtnames,EventName)),'Event already exists');
            end
            evt=codertarget.interrupts.Event(EventName);

            obj.EventsInfo(end+1)=evt;
            evtret=obj.EventsInfo(end);
        end

        function evtret=addNewEventStruct(obj,EventStruct)
            props=properties(obj.EventsInfo);
            assert(isa(EventStruct,'struct'),'EventStruct is not a structure.');

            assert(isfield(EventStruct,'Name'),'Name field does not exist.');
            evtret=addNewEvent(obj,EventStruct.Name);
            for i=1:numel(props)
                if isequal(props{i},'EventStatus')&&isfield(EventStruct,'EventStatus')
                    setEventStatus(evtret,EventStruct.EventStatus);
                elseif isequal(props{i},'ClearEventStatus')&&isfield(EventStruct,'ClearEventStatus')
                    setClearEventStatus(evtret,EventStruct.ClearEventStatus);
                end
            end
        end

        function evtname=getEventNames(obj)
            evtname='';
            if~isempty(obj.EventsInfo)
                evtname={obj.EventsInfo.Name};
            end
        end

        function evt=getEvent(obj,EvtName)
            EvtName=convertStringsToChars(EvtName);
            allEvts=getEventNames(obj);
            EvtName=validatestring(EvtName,allEvts);

            evt=obj.EventsInfo(ismember(allEvts,EvtName));
        end

        function removeEvent(obj,EvtName)
            EvtName=convertStringsToChars(EvtName);
            allEvts=getEventNames(obj);
            EvtName=validatestring(EvtName,allEvts);

            obj.EventsInfo(ismember(allEvts,EvtName))=[];
        end

        function IrqStruct=getInterruptStruct(obj)
            props=properties(obj);
            for i=1:numel(props)
                if isequal(props{i},'EventsInfo')
                    if~isempty(obj.EventsInfo)
                        if~isfield(IrqStruct,props{i})
                            IrqStruct.(props{i})=getEventStruct(obj.EventsInfo(1));
                        end

                        for j=2:numel(obj.EventsInfo)
                            IrqStruct.EventsInfo(end+1)=getEventStruct(obj.EventsInfo(j));
                        end
                    else
                        IrqStruct.(props{i})=[];
                    end
                else
                    IrqStruct.(props{i})=obj.(props{i});
                end
            end
        end
    end

    methods(Hidden)
        function setMaskable(obj,value)
            if ischar(value)||isstring(value)
                if ismember(value,{'true','false'})
                    value=eval(value);
                else
                    value=str2double(convertStringsToChars(value));
                end
            end

            validateattributes(value,{'numeric','logical'},{'nonempty','binary','scalar'},'','Maskable');
            if islogical(value)
                obj.Maskable=value;
            else
                obj.Maskable=isequal(value,1);
            end
        end
    end
end


