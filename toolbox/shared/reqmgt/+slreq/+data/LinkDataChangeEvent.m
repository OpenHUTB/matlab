classdef LinkDataChangeEvent<event.EventData




    properties
type
eventObj
        PropName='Unset';
        OldValue='N/A';
        NewValue='N/A';
    end

    methods
        function this=LinkDataChangeEvent(type,eventObj,changedInfo)




            if nargin>2
                this.PropName=changedInfo.propName;
                this.OldValue=changedInfo.oldValue;
                this.NewValue=changedInfo.newValue;
            end
            this.type=type;
            this.eventObj=eventObj;
















        end
    end

end

