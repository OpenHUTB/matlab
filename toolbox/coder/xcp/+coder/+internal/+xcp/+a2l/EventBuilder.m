classdef EventBuilder<handle






    properties(Constant,Access=private)
        DirectionDefault='DAQ';
        MaxDaqListDefault=0xFF;
        PriorityDefault=0x00;
    end
    properties(SetAccess=immutable,GetAccess=public)
        SuppressWarnings=false;
    end

    methods
        function obj=EventBuilder(suppressWarnings)


            if nargin==0
                obj.SuppressWarnings=false;
            else
                obj.SuppressWarnings=suppressWarnings;
            end
        end

        function build(obj,eventChannelNumber,timeCycleInSeconds,event)


            className=mfilename('class');
            validateattributes(eventChannelNumber,{'numeric'},{'nonnegative','scalar'},className,'eventChannelNumber');
            validateattributes(timeCycleInSeconds,{'numeric'},{'nonnegative','scalar'},className,'timeCycleInSeconds');
            validateattributes(event,{'asam.mcd2mc.ifdata.xcp.EventInfo'},{},className,'event');

            eventRate=coder.internal.xcp.a2l.EventRate(timeCycleInSeconds,...
            obj.SuppressWarnings);
            event.ChannelName=eventRate.TimeCycleString;
            event.ChannelShortName=eventRate.TimeCycleString;
            event.ChannelNumber=eventChannelNumber;
            event.Direction=obj.DirectionDefault;
            event.MaxDaqList=obj.MaxDaqListDefault;
            event.EventChannelTimeCycle=eventRate.TimeCycleInUnits;
            event.EventChannelTimeUnit=eventRate.UnitEnumNum;
            event.EventChannelPriority=obj.PriorityDefault;
        end
    end
end