


classdef MessageTopicWrapper<handle


    properties(SetAccess=immutable)
JavaObject
Id
Events
    end

    methods
        function this=MessageTopicWrapper(topic)
            if ischar(topic)
                [~,topic]=evalc(topic);
            end
            assert(isa(topic,'com.mathworks.toolbox.coder.mb.MessageTopic'));

            this.JavaObject=topic;
            this.Id=char(topic.getId());

            eventMethods=cell(topic.getSubscriberType().getDeclaredMethods());
            this.Events=cell(numel(eventMethods),1);

            for i=1:numel(eventMethods)
                this.Events{i}=char(eventMethods{i}.getName());
            end
        end

        function assertMessagingMethod(this,methodName)
            assert(~isempty(find(ismember(this.Events,methodName),1)));
        end

        function disp(this)
            com.mathworks.toolbox.coder.mb.impl.MessagingUtils.describeSubscriberType(this.JavaObject);
        end
    end
end

