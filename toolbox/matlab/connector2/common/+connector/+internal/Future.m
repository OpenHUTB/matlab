classdef(Hidden=true)Future<handle

    properties(Access=private)
Promise
ResultPromise
Callback
    end


    methods(Static)
        function future=makeReadyFuture(value)
            promise=connector.internal.Promise(value);
            future=promise.getFuture();
        end

        function future=makeFailedFuture(exception)
            promise=connector.internal.Promise(exception,true);
            future=promise.getFuture();
        end
    end


    methods
        function obj=Future(promise)
            if metaclass(promise)==?connector.internal.Promise
                obj.Promise=promise;
            else
                ex=MException('Connector:Framework:ExpectedPromise',...
                'Expected a promise as an argument');
                throw(ex);
            end
        end


        function future=then(obj,callback)
            if isempty(obj.Promise)
                ex=MException('Connector:Framework:AlreadyDelivered',...
                'The future value was already delivered.');
                throw ex;
            end

            obj.Callback=callback;
            obj.ResultPromise=connector.internal.Promise;
            future=obj.ResultPromise.getFuture();

            obj.Promise.notifyGet();
            obj.notifyFuture();
        end


        function value=get(obj)
            import connector.internal.Promise;

            if isempty(obj.Promise)
                ex=MException('Connector:Framework:AlreadyDelivered',...
                'The future value was already delivered.');
                throw(ex);
            end

            obj.Promise.notifyGet();


            while obj.Promise.State==connector.internal.PromiseState.Unresolved
                pause(.001);
                drawnow;
            end

            if obj.Promise.State==connector.internal.PromiseState.Resolved
                value=obj.Promise.Value;
                obj.Promise=[];
            else
                ex=obj.Promise.Value;
                obj.Promise=[];
                throw(ex);
            end
        end
    end


    methods(Access={?connector.internal.Promise})
        function notifyFuture(obj)
            import connector.internal.Promise;

            if~isempty(obj.Callback)&&~isempty(obj.Promise)
                if obj.Promise.State==connector.internal.PromiseState.Resolved||...
                    obj.Promise.State==connector.internal.PromiseState.Failed

                    try
                        result=obj.Callback(obj);
                        if~isempty(obj.ResultPromise)
                            obj.ResultPromise.setValue(result);
                        end
                    catch ex
                        if~isempty(obj.ResultPromise)
                            obj.ResultPromise.setException(ex);
                        end
                    end


                    obj.Promise=[];
                    obj.ResultPromise=[];
                    obj.Callback=[];
                end
            end
        end
    end
end
