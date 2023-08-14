classdef RequestSubscriber<handle


    properties(SetAccess=protected)
        requestSubscription=[];
        courseModelData=struct();
    end

    properties(Constant)
        SUBSCRIBE_CHANNEL="/sltraining/slbridge/courseModelRequest";
        PUBLISH_CHANNEL="/sltraining/slbridge/courseModelData";
        REQUEST_DATA=struct("type","toolEventCode",...
        "message","ToolEventCodes.Simulink.RequestCourseModelData");
    end

    methods
        function obj=RequestSubscriber()
            obj.requestSubscription=message.subscribe(obj.SUBSCRIBE_CHANNEL,@(msg)obj.handleMessage(msg));
        end

        function obj=setCourseModelData(obj,courseModelData)
            obj.courseModelData=courseModelData;
        end

        function unsubscribe(obj)
            if~isempty(obj.requestSubscription)
                message.unsubscribe(obj.requestSubscription);
                obj.requestSubscription=[];
            end
        end
    end

    methods(Access=private)
        function handleMessage(obj,msg)
            if isequal(obj.REQUEST_DATA,msg)
                obj.sendCourseModelData();
            end
        end

        function sendCourseModelData(obj)
            message.publish(obj.PUBLISH_CHANNEL,obj.courseModelData);
        end
    end
end

