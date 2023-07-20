classdef MessageServiceInterface<handle



    properties(SetAccess=protected)
        requestSubscription=[];
        dataSubscription=[];
        toolEventSubscription=[];
        requestChannel='/sltraining/slbridge/courseModelRequest';
        dataChannel='/sltraining/slbridge/courseModelData';
        toolEventChannel='/sltraining/slbridge/toolEventCodes';
    end

    methods
        function obj=MessageServiceInterface()
            obj.requestSubscription=message.subscribe(obj.requestChannel,@(msg)obj.handleCourseModelRequest(msg));
            obj.dataSubscription=message.subscribe(obj.dataChannel,@(msg)obj.handleCourseModelData(msg));
            obj.toolEventSubscription=message.subscribe(obj.toolEventChannel,@(msg)obj.handleToolEventCode(msg));
        end

        function delete(obj)
            obj.cleanup();
        end

        function cleanup(obj)
            if~isempty(obj.requestSubscription)
                message.unsubscribe(obj.requestSubscription);
                obj.requestSubscription=[];
            end

            if~isempty(obj.dataSubscription)
                message.unsubscribe(obj.dataSubscription);
                obj.dataSubscription=[];
            end

            if~isempty(obj.toolEventSubscription)
                message.unsubscribe(obj.toolEventSubscription);
                obj.toolEventSubscription=[];
            end
        end

        function handleCourseModelRequest(obj,msg)
            message.publish(obj.requestChannel,msg);
        end

        function handleCourseModelData(obj,msg)
            message.publish(obj.dataChannel,msg);
        end

        function handleToolEventCode(obj,msg)
            message.publish(obj.toolEventChannel,msg);
        end
    end
end
