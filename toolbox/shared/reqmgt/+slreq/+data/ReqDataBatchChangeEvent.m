classdef ReqDataBatchChangeEvent<event.EventData




    properties
type
eventObjs
        PropName='Unset';
        OldValues={};
        NewValues={};
        EventCounter;
    end

    methods
        function this=ReqDataBatchChangeEvent(type,eventObjs,changedInfos)







            if nargin>2
                sz=numel(changedInfos);
                this.OldValues={};
                this.NewValues={};

                for i=1:sz
                    this.OldValues{end+1}=changedInfos{i}.oldValue;
                    this.NewValues{end+1}=changedInfos{i}.newValue;
                end
            end

            this.PropName=changedInfos{1}.propName;
            this.type=type;
            this.eventObjs=eventObjs;
        end


        function changeEvent=getChangeEvent(this,i)
            changeEvent=slreq.data.ReqDataChangeEvent(this.type,[]);
            changeEvent.PropName=this.PropName;
            if i<=numel(this.OldValues)
                changeEvent.OldValue=this.OldValues{i};
                changeEvent.NewValue=this.NewValues{i};
            end
        end
    end

end

