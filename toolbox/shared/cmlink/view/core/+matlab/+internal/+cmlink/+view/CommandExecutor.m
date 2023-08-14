classdef CommandExecutor




    properties(Access=private)
        Channel='/cmlink/viewcommand';
    end

    methods(Access=public)
        function obj=CommandExecutor(channel)
            if(nargin>0)
                obj.Channel=channel;
            end
        end

        function run(obj,action,args)
            import matlab.lang.internal.uuid;
            invocationId=uuid();

            responseChannel=obj.Channel+"/r"+invocationId;
            responseContainer={};
            function nResponse(message)
                responseContainer{1}=message;
            end
            subscription=message.subscribe(responseChannel,@nResponse);

            payload=iPreparePayload(action,args,invocationId);
            message.publish(obj.Channel,payload)

            while(isempty(responseContainer))
                pause(0.1);
            end
            message.unsubscribe(subscription);
            iHandleResponse(responseContainer);
        end
    end
end
function iHandleResponse(responseContainer)
    responseData=responseContainer{1};
    if(~responseData.success)
        error("cmlink:actions:ExecutionFailure","%s",responseData.errorMessage);
    end
end
function payload=iPreparePayload(action,args,invocationId)
    payload=struct('action',action,'id',invocationId);
    if(~iscell(args))
        args={args};
    end
    payload.args=args;
end
